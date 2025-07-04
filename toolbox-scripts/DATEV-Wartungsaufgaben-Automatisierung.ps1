#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    DATEV Wartungsaufgaben-Automatisierung
    
.DESCRIPTION
    Automatisiert die Einrichtung von Windows-Aufgabenplanung fuer DATEV-Datenbankwartung
    gemaess Abschnitt 2.3.1 der DATEV-Dokumentation "Microsoft SQL Server (DATEV): Datenbanken optimieren"
    
.NOTES
    Version: 1.0
    Author: DATEV-Toolbox 2.0
    Requires: PowerShell 5.1, Administrative Rights, DATEV Installation
    
.EXAMPLE
    .\DATEV-Wartungsaufgaben-Automatisierung.ps1
#>

# ===================================================================================================
# GLOBALE VARIABLEN UND KONFIGURATION
# ===================================================================================================

$Global:LogPath = "$env:TEMP\DATEV-Wartungsaufgaben-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$Global:DATEVPath = $null
$Global:MaintenanceScripts = @()
$Global:TaskScheduler = $null

# ===================================================================================================
# LOGGING-FUNKTIONEN
# ===================================================================================================

function Write-DetailedLog {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet('INFO', 'WARNING', 'ERROR', 'SUCCESS')]
        [string]$Level = 'INFO'
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # In Datei schreiben
    Add-Content -Path $Global:LogPath -Value $logEntry -Encoding UTF8
    
    # In GUI-Log anzeigen (falls verfuegbar)
    if ($Global:MainWindow -and $Global:MainWindow.FindName('LogTextBox')) {
        $Global:MainWindow.FindName('LogTextBox').Dispatcher.Invoke([Action]{
            $Global:MainWindow.FindName('LogTextBox').AppendText("$logEntry`n")
            $Global:MainWindow.FindName('LogTextBox').ScrollToEnd()
        })
    }
    
    # Konsolen-Output mit Farben
    switch ($Level) {
        'ERROR' { Write-Host $logEntry -ForegroundColor Red }
        'WARNING' { Write-Host $logEntry -ForegroundColor Yellow }
        'SUCCESS' { Write-Host $logEntry -ForegroundColor Green }
        default { Write-Host $logEntry -ForegroundColor White }
    }
}

# ===================================================================================================
# DATEV-ERKENNUNGS-FUNKTIONEN
# ===================================================================================================

function Find-DATEVInstallation {
    Write-DetailedLog "Suche nach DATEV-Installation..."
    
    # DATEVPP Umgebungsvariable pruefen
    $datevPP = [Environment]::GetEnvironmentVariable('DATEVPP', 'Machine')
    if (-not $datevPP) {
        $datevPP = [Environment]::GetEnvironmentVariable('DATEVPP', 'User')
    }
    
    if ($datevPP -and (Test-Path $datevPP)) {
        Write-DetailedLog "DATEV-Installation gefunden: $datevPP" -Level 'SUCCESS'
        $Global:DATEVPath = $datevPP
        return $true
    }
    
    # Alternative Suchpfade
    $searchPaths = @(
        'C:\DATEV\PROGRAMM',
        'D:\DATEV\PROGRAMM',
        'C:\Program Files\DATEV',
        'C:\Program Files (x86)\DATEV'
    )
    
    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            Write-DetailedLog "DATEV-Installation gefunden: $path" -Level 'SUCCESS'
            $Global:DATEVPath = $path
            return $true
        }
    }
    
    Write-DetailedLog "Keine DATEV-Installation gefunden!" -Level 'ERROR'
    return $false
}

function Get-MaintenanceScripts {
    if (-not $Global:DATEVPath) {
        Write-DetailedLog "DATEV-Pfad nicht verfuegbar" -Level 'ERROR'
        return @()
    }
    
    Write-DetailedLog "Suche nach Wartungsskripten..."
    
    # SQL Server Editionen pruefen
    $editions = @(
        @{ Name = 'Express'; Path = 'B0000453\Maintenance' },
        @{ Name = 'Standard'; Path = 'B0000454\Maintenance' }
    )
    
    $scripts = @()
    
    foreach ($edition in $editions) {
        $maintenancePath = Join-Path $Global:DATEVPath "PROGRAMM\$($edition.Path)"
        
        if (Test-Path $maintenancePath) {
            Write-DetailedLog "Wartungsverzeichnis gefunden: $maintenancePath ($($edition.Name) Edition)" -Level 'SUCCESS'
            
            # Verfuegbare Skripte suchen
            $scriptFiles = @(
                @{ Name = 'RunMaintenanceWE.cmd'; Description = 'Woechentliche Wartung (empfohlen)'; Recommended = $true },
                @{ Name = 'RunMaintenance.cmd'; Description = 'Taegliche Wartung'; Recommended = $false }
            )
            
            foreach ($scriptFile in $scriptFiles) {
                $scriptPath = Join-Path $maintenancePath $scriptFile.Name
                if (Test-Path $scriptPath) {
                    $scripts += [PSCustomObject]@{
                        Edition = $edition.Name
                        Name = $scriptFile.Name
                        Description = $scriptFile.Description
                        Path = $scriptPath
                        Recommended = $scriptFile.Recommended
                    }
                    Write-DetailedLog "Skript gefunden: $($scriptFile.Name) ($($edition.Name))" -Level 'SUCCESS'
                }
            }
            
            # INI-Datei pruefen
            $iniPath = Join-Path $maintenancePath "scripte"
            if (Test-Path $iniPath) {
                Write-DetailedLog "Konfigurationsverzeichnis gefunden: $iniPath" -Level 'SUCCESS'
            }
        }
    }
    
    $Global:MaintenanceScripts = $scripts
    Write-DetailedLog "Insgesamt $($scripts.Count) Wartungsskripte gefunden"
    return $scripts
}

# ===================================================================================================
# AUFGABENPLANUNG-FUNKTIONEN
# ===================================================================================================

function Initialize-TaskScheduler {
    try {
        $Global:TaskScheduler = New-Object -ComObject Schedule.Service
        $Global:TaskScheduler.Connect()
        Write-DetailedLog "Task Scheduler erfolgreich initialisiert" -Level 'SUCCESS'
        return $true
    }
    catch {
        Write-DetailedLog "Fehler beim Initialisieren des Task Schedulers: $($_.Exception.Message)" -Level 'ERROR'
        return $false
    }
}

function Test-TaskScheduleConflicts {
    param(
        [Parameter(Mandatory=$true)]
        [DateTime]$ScheduledTime,
        
        [Parameter(Mandatory=$true)]
        [string]$Frequency
    )
    
    Write-DetailedLog "Pruefe Zeitplan-Konflikte fuer $ScheduledTime ($Frequency)..."
    
    $conflicts = @()
    
    # Typische Konfliktzeiten definieren
    $conflictTimes = @{
        'Sicherungslaeufe' = @(21, 22, 23, 0, 1)  # 21:00-01:00
        'Programmaktualisierung' = @(18, 19, 20, 21, 22)  # 18:00-22:00
        'Datenanpassung' = @(18, 19, 20, 21, 22, 23)  # 18:00-23:00
    }
    
    $scheduledHour = $ScheduledTime.Hour
    
    foreach ($conflictType in $conflictTimes.Keys) {
        if ($conflictTimes[$conflictType] -contains $scheduledHour) {
            $conflicts += $conflictType
        }
    }
    
    # Bestehende DATEV-Aufgaben pruefen
    try {
        $rootFolder = $Global:TaskScheduler.GetFolder('\')
        $datevFolder = $null
        
        try {
            $datevFolder = $rootFolder.GetFolder('\DATEV eG')
        }
        catch {
            # DATEV-Ordner existiert nicht
        }
        
        if ($datevFolder) {
            $existingTasks = $datevFolder.GetTasks(0)
            foreach ($task in $existingTasks) {
                $triggers = $task.Definition.Triggers
                foreach ($trigger in $triggers) {
                    if ($trigger.StartBoundary) {
                        $existingTime = [DateTime]::Parse($trigger.StartBoundary)
                        $timeDiff = [Math]::Abs(($ScheduledTime - $existingTime).TotalMinutes)
                        
                        if ($timeDiff -lt 60) {  # Weniger als 1 Stunde Abstand
                            $conflicts += "Bestehende DATEV-Aufgabe: $($task.Name)"
                        }
                    }
                }
            }
        }
    }
    catch {
        Write-DetailedLog "Warnung: Konnte bestehende Aufgaben nicht pruefen: $($_.Exception.Message)" -Level 'WARNING'
    }
    
    if ($conflicts.Count -gt 0) {
        Write-DetailedLog "Potentielle Konflikte erkannt: $($conflicts -join ', ')" -Level 'WARNING'
    } else {
        Write-DetailedLog "Keine Zeitplan-Konflikte erkannt" -Level 'SUCCESS'
    }
    
    return $conflicts
}

function New-DATEVMaintenanceTask {
    param(
        [Parameter(Mandatory=$true)]
        [string]$TaskName,
        
        [Parameter(Mandatory=$true)]
        [string]$Description,
        
        [Parameter(Mandatory=$true)]
        [string]$ScriptPath,
        
        [Parameter(Mandatory=$true)]
        [DateTime]$StartTime,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet('Daily', 'Weekly')]
        [string]$Frequency,
        
        [Parameter(Mandatory=$false)]
        [int]$DayOfWeek = 6  # Samstag als Standard
    )
    
    Write-DetailedLog "Erstelle Wartungsaufgabe: $TaskName"
    
    try {
        # DATEV eG Ordner erstellen/abrufen
        $rootFolder = $Global:TaskScheduler.GetFolder('\')
        $datevFolder = $null
        
        try {
            $datevFolder = $rootFolder.GetFolder('\DATEV eG')
            Write-DetailedLog "DATEV eG Ordner bereits vorhanden"
        }
        catch {
            $datevFolder = $rootFolder.CreateFolder('DATEV eG')
            Write-DetailedLog "DATEV eG Ordner erstellt" -Level 'SUCCESS'
        }
        
        # Task Definition erstellen
        $taskDefinition = $Global:TaskScheduler.NewTask(0)
        
        # Allgemeine Einstellungen
        $taskDefinition.RegistrationInfo.Description = $Description
        $taskDefinition.RegistrationInfo.Author = "DATEV-Toolbox 2.0"
        
        # Principal (Sicherheitskontext)
        $principal = $taskDefinition.Principal
        $principal.LogonType = 5  # TASK_LOGON_SERVICE_ACCOUNT
        $principal.RunLevel = 1   # TASK_RUNLEVEL_HIGHEST (hoechste Privilegien)
        $principal.UserId = "SYSTEM"
        
        # Settings
        $settings = $taskDefinition.Settings
        $settings.Enabled = $true
        $settings.StartWhenAvailable = $true
        $settings.ExecutionTimeLimit = "PT3H"  # 3 Stunden Timeout
        $settings.DisallowStartIfOnBatteries = $false
        $settings.StopIfGoingOnBatteries = $false
        $settings.WakeToRun = $false
        
        # Trigger erstellen
        $triggers = $taskDefinition.Triggers
        
        if ($Frequency -eq 'Daily') {
            $trigger = $triggers.Create(2)  # TASK_TRIGGER_DAILY
            $trigger.DaysInterval = 1
        } else {
            $trigger = $triggers.Create(3)  # TASK_TRIGGER_WEEKLY
            $trigger.WeeksInterval = 1
            $trigger.DaysOfWeek = [Math]::Pow(2, $DayOfWeek)  # Bitmaske fuer Wochentag
        }
        
        $trigger.StartBoundary = $StartTime.ToString("yyyy-MM-ddTHH:mm:ss")
        $trigger.Enabled = $true
        
        # Action erstellen
        $actions = $taskDefinition.Actions
        $action = $actions.Create(0)  # TASK_ACTION_EXEC
        $action.Path = $ScriptPath
        $action.WorkingDirectory = Split-Path $ScriptPath -Parent
        
        # Task registrieren
        $datevFolder.RegisterTaskDefinition(
            $TaskName,
            $taskDefinition,
            6,  # TASK_CREATE_OR_UPDATE
            $null,
            $null,
            5   # TASK_LOGON_SERVICE_ACCOUNT
        )
        
        Write-DetailedLog "Wartungsaufgabe '$TaskName' erfolgreich erstellt!" -Level 'SUCCESS'
        return $true
    }
    catch {
        Write-DetailedLog "Fehler beim Erstellen der Wartungsaufgabe: $($_.Exception.Message)" -Level 'ERROR'
        return $false
    }
}

# ===================================================================================================
# VALIDIERUNGS-FUNKTIONEN
# ===================================================================================================

function Test-Prerequisites {
    Write-DetailedLog "Pruefe Systemvoraussetzungen..."
    
    $issues = @()
    
    # Administrator-Rechte pruefen
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $issues += "Administrator-Rechte erforderlich"
    }
    
    # PowerShell-Version pruefen
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        $issues += "PowerShell 5.1 oder hoeher erforderlich"
    }
    
    # Task Scheduler Service pruefen
    $taskService = Get-Service -Name "Schedule" -ErrorAction SilentlyContinue
    if (-not $taskService -or $taskService.Status -ne 'Running') {
        $issues += "Task Scheduler Service nicht verfuegbar"
    }
    
    # DATEV-Installation pruefen
    if (-not (Find-DATEVInstallation)) {
        $issues += "DATEV-Installation nicht gefunden"
    }
    
    # Wartungsskripte pruefen
    $scripts = Get-MaintenanceScripts
    if ($scripts.Count -eq 0) {
        $issues += "Keine DATEV-Wartungsskripte gefunden"
    }
    
    if ($issues.Count -gt 0) {
        Write-DetailedLog "Systemvoraussetzungen nicht erfuellt:" -Level 'ERROR'
        foreach ($issue in $issues) {
            Write-DetailedLog "  - $issue" -Level 'ERROR'
        }
        return $false
    }
    
    Write-DetailedLog "Alle Systemvoraussetzungen erfuellt" -Level 'SUCCESS'
    return $true
}

# ===================================================================================================
# WPF-GUI DEFINITION
# ===================================================================================================

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="DATEV Wartungsaufgaben-Automatisierung"
        Height="700" Width="900"
        WindowStartupLocation="CenterScreen"
        ResizeMode="CanResize">
    
    <Window.Resources>
        <Style TargetType="GroupBox">
            <Setter Property="Margin" Value="5"/>
            <Setter Property="Padding" Value="10"/>
        </Style>
        <Style TargetType="Button">
            <Setter Property="Margin" Value="5"/>
            <Setter Property="Padding" Value="10,5"/>
            <Setter Property="MinWidth" Value="100"/>
        </Style>
        <Style TargetType="TextBox">
            <Setter Property="Margin" Value="5"/>
            <Setter Property="Padding" Value="5"/>
        </Style>
        <Style TargetType="ComboBox">
            <Setter Property="Margin" Value="5"/>
            <Setter Property="Padding" Value="5"/>
        </Style>
        <Style TargetType="CheckBox">
            <Setter Property="Margin" Value="5"/>
        </Style>
        <Style TargetType="RadioButton">
            <Setter Property="Margin" Value="5"/>
        </Style>
    </Window.Resources>
    
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="200"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        
        <!-- Header -->
        <Border Grid.Row="0" Background="#FF2E7D32" Padding="15">
            <StackPanel>
                <TextBlock Text="DATEV Wartungsaufgaben-Automatisierung" 
                          FontSize="20" FontWeight="Bold" Foreground="White" HorizontalAlignment="Center"/>
                <TextBlock Text="Automatisierte Einrichtung der Windows-Aufgabenplanung fuer DATEV-Datenbankwartung" 
                          FontSize="12" Foreground="White" HorizontalAlignment="Center" Margin="0,5,0,0"/>
            </StackPanel>
        </Border>
        
        <!-- Main Content -->
        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
            <StackPanel Margin="10">
                
                <!-- DATEV-Erkennung -->
                <GroupBox Header="DATEV-Installation" Name="DATEVGroup">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="150"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        
                        <TextBlock Grid.Row="0" Grid.Column="0" Text="Status:" VerticalAlignment="Center"/>
                        <TextBlock Grid.Row="0" Grid.Column="1" Name="DATEVStatusText" Text="Nicht geprueft" VerticalAlignment="Center"/>
                        <Button Grid.Row="0" Grid.Column="2" Name="ScanButton" Content="Scannen"/>
                        
                        <TextBlock Grid.Row="1" Grid.Column="0" Text="Installation:" VerticalAlignment="Center"/>
                        <TextBox Grid.Row="1" Grid.Column="1" Name="DATEVPathText" IsReadOnly="True"/>
                        
                        <TextBlock Grid.Row="2" Grid.Column="0" Text="Verfuegbare Skripte:" VerticalAlignment="Top" Margin="0,10,0,0"/>
                        <ListBox Grid.Row="2" Grid.Column="1" Name="ScriptsListBox" Height="80" Margin="5,10,5,5"/>
                    </Grid>
                </GroupBox>
                
                <!-- Aufgaben-Konfiguration -->
                <GroupBox Header="Aufgaben-Konfiguration" Name="ConfigGroup">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="150"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        
                        <TextBlock Grid.Row="0" Grid.Column="0" Text="Aufgabenname:" VerticalAlignment="Center"/>
                        <TextBox Grid.Row="0" Grid.Column="1" Name="TaskNameText"/>
                        
                        <TextBlock Grid.Row="1" Grid.Column="0" Text="Beschreibung:" VerticalAlignment="Center"/>
                        <TextBox Grid.Row="1" Grid.Column="1" Name="DescriptionText"/>
                        
                        <TextBlock Grid.Row="2" Grid.Column="0" Text="Wartungsskript:" VerticalAlignment="Center"/>
                        <ComboBox Grid.Row="2" Grid.Column="1" Name="ScriptComboBox"/>
                        
                        <CheckBox Grid.Row="3" Grid.Column="1" Name="HighestPrivilegesCheck" 
                                 Content="Mit hoechsten Privilegien ausfuehren" IsChecked="True"/>
                    </Grid>
                </GroupBox>
                
                <!-- Zeitplan -->
                <GroupBox Header="Zeitplan" Name="ScheduleGroup">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="150"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        
                        <TextBlock Grid.Row="0" Grid.Column="0" Text="Haeufigkeit:" VerticalAlignment="Center"/>
                        <StackPanel Grid.Row="0" Grid.Column="1" Orientation="Horizontal">
                            <RadioButton Name="WeeklyRadio" Content="Woechentlich (empfohlen)" IsChecked="True" GroupName="Frequency"/>
                            <RadioButton Name="DailyRadio" Content="Taeglich" GroupName="Frequency"/>
                        </StackPanel>
                        
                        <TextBlock Grid.Row="1" Grid.Column="0" Text="Wochentag:" VerticalAlignment="Center" Name="WeekdayLabel"/>
                        <ComboBox Grid.Row="1" Grid.Column="1" Name="WeekdayComboBox">
                            <ComboBoxItem Content="Sonntag" Tag="0"/>
                            <ComboBoxItem Content="Montag" Tag="1"/>
                            <ComboBoxItem Content="Dienstag" Tag="2"/>
                            <ComboBoxItem Content="Mittwoch" Tag="3"/>
                            <ComboBoxItem Content="Donnerstag" Tag="4"/>
                            <ComboBoxItem Content="Freitag" Tag="5"/>
                            <ComboBoxItem Content="Samstag" Tag="6" IsSelected="True"/>
                        </ComboBox>
                        
                        <TextBlock Grid.Row="2" Grid.Column="0" Text="Uhrzeit:" VerticalAlignment="Center"/>
                        <StackPanel Grid.Row="2" Grid.Column="1" Orientation="Horizontal">
                            <ComboBox Name="HourComboBox" Width="60"/>
                            <TextBlock Text=":" VerticalAlignment="Center" Margin="5,0"/>
                            <ComboBox Name="MinuteComboBox" Width="60"/>
                        </StackPanel>
                        
                        <TextBlock Grid.Row="3" Grid.Column="0" Text="Konflikte:" VerticalAlignment="Top" Margin="0,10,0,0"/>
                        <TextBlock Grid.Row="3" Grid.Column="1" Name="ConflictsText" TextWrapping="Wrap" 
                                  Foreground="Orange" Margin="5,10,5,5"/>
                        
                        <Button Grid.Row="4" Grid.Column="1" Name="CheckConflictsButton" Content="Konflikte pruefen"
                                HorizontalAlignment="Left"/>
                    </Grid>
                </GroupBox>
                
            </StackPanel>
        </ScrollViewer>
        
        <!-- Progress Bar -->
        <ProgressBar Grid.Row="2" Name="ProgressBar" Height="20" Margin="10" Visibility="Collapsed"/>
        
        <!-- Log Output -->
        <GroupBox Grid.Row="3" Header="Protokoll" Margin="10,0,10,10">
            <ScrollViewer VerticalScrollBarVisibility="Auto">
                <TextBox Name="LogTextBox" IsReadOnly="True" TextWrapping="Wrap" 
                        VerticalScrollBarVisibility="Auto" FontFamily="Consolas" FontSize="10"/>
            </ScrollViewer>
        </GroupBox>
        
        <!-- Action Buttons -->
        <Border Grid.Row="4" Background="#FFF5F5F5" Padding="10">
            <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                <Button Name="PreviewButton" Content="Vorschau"/>
                <Button Name="CreateButton" Content="Aufgabe erstellen"
                       Background="#FF4CAF50" Foreground="White"/>
                <Button Name="CancelButton" Content="Abbrechen"/>
            </StackPanel>
        </Border>
        
    </Grid>
</Window>
"@

# ===================================================================================================
# GUI-EVENT-HANDLER
# ===================================================================================================

function Initialize-GUI {
    Write-DetailedLog "Initialisiere GUI..."
    
    try {
        Add-Type -AssemblyName PresentationFramework
        Add-Type -AssemblyName PresentationCore
        Add-Type -AssemblyName WindowsBase
        
        # XAML laden
        $reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$xaml)
        $Global:MainWindow = [Windows.Markup.XamlReader]::Load($reader)
        
        # Event-Handler registrieren
        $Global:MainWindow.FindName('ScanButton').Add_Click({ ScanButton_Click })
        $Global:MainWindow.FindName('CheckConflictsButton').Add_Click({ CheckConflictsButton_Click })
        $Global:MainWindow.FindName('PreviewButton').Add_Click({ PreviewButton_Click })
        $Global:MainWindow.FindName('CreateButton').Add_Click({ CreateButton_Click })
        $Global:MainWindow.FindName('CancelButton').Add_Click({ CancelButton_Click })
        
        # Frequency Radio Button Events
        $Global:MainWindow.FindName('WeeklyRadio').Add_Checked({ FrequencyChanged })
        $Global:MainWindow.FindName('DailyRadio').Add_Checked({ FrequencyChanged })
        
        # ComboBoxen initialisieren
        Initialize-TimeComboBoxes
        Initialize-DefaultValues
        
        Write-DetailedLog "GUI erfolgreich initialisiert" -Level 'SUCCESS'
        return $true
    }
    catch {
        Write-DetailedLog "Fehler beim Initialisieren der GUI: $($_.Exception.Message)" -Level 'ERROR'
        return $false
    }
}

function Initialize-TimeComboBoxes {
    $hourCombo = $Global:MainWindow.FindName('HourComboBox')
    $minuteCombo = $Global:MainWindow.FindName('MinuteComboBox')
    
    # Stunden (0-23)
    for ($i = 0; $i -lt 24; $i++) {
        $hourCombo.Items.Add($i.ToString("00"))
    }
    $hourCombo.SelectedIndex = 2  # 02:00 als Standard
    
    # Minuten (0, 15, 30, 45)
    @(0, 15, 30, 45) | ForEach-Object {
        $minuteCombo.Items.Add($_.ToString("00"))
    }
    $minuteCombo.SelectedIndex = 0  # :00 als Standard
}

function Initialize-DefaultValues {
    $Global:MainWindow.FindName('TaskNameText').Text = "DATEV_Wartung_Woechentlich_$(Get-Date -Format 'yyyyMMdd')"
    $Global:MainWindow.FindName('DescriptionText').Text = "Automatische DATEV-Datenbankwartung (erstellt durch DATEV-Toolbox 2.0)"
}

function ScanButton_Click {
    Write-DetailedLog "Starte DATEV-Scan..."
    
    $statusText = $Global:MainWindow.FindName('DATEVStatusText')
    $pathText = $Global:MainWindow.FindName('DATEVPathText')
    $scriptsList = $Global:MainWindow.FindName('ScriptsListBox')
    $scriptCombo = $Global:MainWindow.FindName('ScriptComboBox')
    
    # UI zuruecksetzen
    $scriptsList.Items.Clear()
    $scriptCombo.Items.Clear()
    
    if (Find-DATEVInstallation) {
        $statusText.Text = "DATEV-Installation gefunden"
        $statusText.Foreground = [System.Windows.Media.Brushes]::Green
        $pathText.Text = $Global:DATEVPath
        
        $scripts = Get-MaintenanceScripts
        
        foreach ($script in $scripts) {
            $displayText = "$($script.Name) ($($script.Edition)) - $($script.Description)"
            if ($script.Recommended) {
                $displayText += " [EMPFOHLEN]"
            }
            
            $scriptsList.Items.Add($displayText)
            
            # ComboBoxItem mit Tag erstellen
            $comboItem = New-Object System.Windows.Controls.ComboBoxItem
            $comboItem.Content = $displayText
            $comboItem.Tag = $script
            $scriptCombo.Items.Add($comboItem)
            
            # Empfohlenes Skript vorauswaehlen
            if ($script.Recommended) {
                $scriptCombo.SelectedIndex = $scriptCombo.Items.Count - 1
            }
        }
        
        if ($scripts.Count -eq 0) {
            $statusText.Text = "Keine Wartungsskripte gefunden"
            $statusText.Foreground = [System.Windows.Media.Brushes]::Red
        } else {
            $statusText.Text = "$($scripts.Count) Wartungsskripte gefunden"
            $statusText.Foreground = [System.Windows.Media.Brushes]::Green
        }
    } else {
        $statusText.Text = "DATEV-Installation nicht gefunden"
        $statusText.Foreground = [System.Windows.Media.Brushes]::Red
        $pathText.Text = ""
    }
}

function FrequencyChanged {
    $weekdayLabel = $Global:MainWindow.FindName('WeekdayLabel')
    $weekdayCombo = $Global:MainWindow.FindName('WeekdayComboBox')
    $weeklyRadio = $Global:MainWindow.FindName('WeeklyRadio')
    
    if ($weeklyRadio.IsChecked) {
        $weekdayLabel.Visibility = 'Visible'
        $weekdayCombo.Visibility = 'Visible'
        
        # Aufgabenname anpassen
        $taskNameText = $Global:MainWindow.FindName('TaskNameText')
        $taskNameText.Text = "DATEV_Wartung_Woechentlich_$(Get-Date -Format 'yyyyMMdd')"
    } else {
        $weekdayLabel.Visibility = 'Collapsed'
        $weekdayCombo.Visibility = 'Collapsed'
        
        # Aufgabenname anpassen
        $taskNameText = $Global:MainWindow.FindName('TaskNameText')
        $taskNameText.Text = "DATEV_Wartung_Taeglich_$(Get-Date -Format 'yyyyMMdd')"
    }
}

function CheckConflictsButton_Click {
    Write-DetailedLog "Pruefe Zeitplan-Konflikte..."
    
    $hourCombo = $Global:MainWindow.FindName('HourComboBox')
    $minuteCombo = $Global:MainWindow.FindName('MinuteComboBox')
    $weeklyRadio = $Global:MainWindow.FindName('WeeklyRadio')
    $conflictsText = $Global:MainWindow.FindName('ConflictsText')
    
    if ($hourCombo.SelectedItem -eq $null -or $minuteCombo.SelectedItem -eq $null) {
        $conflictsText.Text = "Bitte waehlen Sie eine Uhrzeit aus."
        $conflictsText.Foreground = [System.Windows.Media.Brushes]::Red
        return
    }
    
    $hour = [int]$hourCombo.SelectedItem
    $minute = [int]$minuteCombo.SelectedItem
    $scheduledTime = Get-Date -Hour $hour -Minute $minute -Second 0
    
    $frequency = if ($weeklyRadio.IsChecked) { "Weekly" } else { "Daily" }
    
    $conflicts = Test-TaskScheduleConflicts -ScheduledTime $scheduledTime -Frequency $frequency
    
    if ($conflicts.Count -eq 0) {
        $conflictsText.Text = "Keine Konflikte erkannt"
        $conflictsText.Foreground = [System.Windows.Media.Brushes]::Green
    } else {
        $conflictsText.Text = "Potentielle Konflikte: $($conflicts -join ', ')"
        $conflictsText.Foreground = [System.Windows.Media.Brushes]::Orange
    }
}

function PreviewButton_Click {
    Write-DetailedLog "Erstelle Vorschau..."
    
    $config = Get-TaskConfiguration
    if (-not $config) {
        return
    }
    
    $previewText = @"
Aufgaben-Vorschau:
==================

Name: $($config.TaskName)
Beschreibung: $($config.Description)
Skript: $($config.ScriptPath)
Haeufigkeit: $($config.Frequency)
$(if ($config.Frequency -eq 'Weekly') { "Wochentag: $($config.DayOfWeekName)" })
Startzeit: $($config.StartTime.ToString('HH:mm'))
Hoechste Privilegien: $($config.HighestPrivileges)

Naechste Ausfuehrung: $($config.NextRun.ToString('dd.MM.yyyy HH:mm'))
"@
    
    [System.Windows.MessageBox]::Show($previewText, "Aufgaben-Vorschau", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
}

function CreateButton_Click {
    Write-DetailedLog "Starte Aufgabenerstellung..."
    
    $config = Get-TaskConfiguration
    if (-not $config) {
        return
    }
    
    # Progress Bar anzeigen
    $progressBar = $Global:MainWindow.FindName('ProgressBar')
    $progressBar.Visibility = 'Visible'
    $progressBar.IsIndeterminate = $true
    
    # Buttons deaktivieren
    Set-ButtonsEnabled $false
    
    try {
        # Task Scheduler initialisieren
        if (-not (Initialize-TaskScheduler)) {
            throw "Task Scheduler konnte nicht initialisiert werden"
        }
        
        # Aufgabe erstellen
        $success = New-DATEVMaintenanceTask -TaskName $config.TaskName -Description $config.Description -ScriptPath $config.ScriptPath -StartTime $config.StartTime -Frequency $config.Frequency -DayOfWeek $config.DayOfWeek
        
        if ($success) {
            Write-DetailedLog "Wartungsaufgabe erfolgreich erstellt!" -Level 'SUCCESS'
            [System.Windows.MessageBox]::Show("Die DATEV-Wartungsaufgabe wurde erfolgreich erstellt!`n`nName: $($config.TaskName)`nNaechste Ausfuehrung: $($config.NextRun.ToString('dd.MM.yyyy HH:mm'))", "Erfolg", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
        } else {
            throw "Aufgabenerstellung fehlgeschlagen"
        }
    }
    catch {
        Write-DetailedLog "Fehler bei der Aufgabenerstellung: $($_.Exception.Message)" -Level 'ERROR'
        [System.Windows.MessageBox]::Show("Fehler bei der Aufgabenerstellung:`n`n$($_.Exception.Message)", "Fehler", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    }
    finally {
        # Progress Bar ausblenden
        $progressBar.Visibility = 'Collapsed'
        $progressBar.IsIndeterminate = $false
        
        # Buttons wieder aktivieren
        Set-ButtonsEnabled $true
    }
}

function CancelButton_Click {
    Write-DetailedLog "Anwendung wird beendet..."
    $Global:MainWindow.Close()
}

function Get-TaskConfiguration {
    $taskNameText = $Global:MainWindow.FindName('TaskNameText')
    $descriptionText = $Global:MainWindow.FindName('DescriptionText')
    $scriptCombo = $Global:MainWindow.FindName('ScriptComboBox')
    $hourCombo = $Global:MainWindow.FindName('HourComboBox')
    $minuteCombo = $Global:MainWindow.FindName('MinuteComboBox')
    $weeklyRadio = $Global:MainWindow.FindName('WeeklyRadio')
    $weekdayCombo = $Global:MainWindow.FindName('WeekdayComboBox')
    $privilegesCheck = $Global:MainWindow.FindName('HighestPrivilegesCheck')
    
    # Validierung
    if ([string]::IsNullOrWhiteSpace($taskNameText.Text)) {
        [System.Windows.MessageBox]::Show("Bitte geben Sie einen Aufgabennamen ein.", "Validierungsfehler", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
        return $null
    }
    
    if ([string]::IsNullOrWhiteSpace($descriptionText.Text)) {
        [System.Windows.MessageBox]::Show("Bitte geben Sie eine Beschreibung ein.", "Validierungsfehler", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
        return $null
    }
    
    if ($scriptCombo.SelectedItem -eq $null) {
        [System.Windows.MessageBox]::Show("Bitte waehlen Sie ein Wartungsskript aus.", "Validierungsfehler", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
        return $null
    }
    
    if ($hourCombo.SelectedItem -eq $null -or $minuteCombo.SelectedItem -eq $null) {
        [System.Windows.MessageBox]::Show("Bitte waehlen Sie eine Uhrzeit aus.", "Validierungsfehler", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
        return $null
    }
    
    # Konfiguration zusammenstellen
    $hour = [int]$hourCombo.SelectedItem
    $minute = [int]$minuteCombo.SelectedItem
    $frequency = if ($weeklyRadio.IsChecked) { "Weekly" } else { "Daily" }
    $dayOfWeek = if ($weeklyRadio.IsChecked) { [int]$weekdayCombo.SelectedItem.Tag } else { 0 }
    $dayOfWeekName = if ($weeklyRadio.IsChecked) { $weekdayCombo.SelectedItem.Content } else { "" }
    
    $startTime = Get-Date -Hour $hour -Minute $minute -Second 0
    $nextRun = if ($frequency -eq "Weekly") {
        $daysUntilNext = ($dayOfWeek - [int](Get-Date).DayOfWeek + 7) % 7
        if ($daysUntilNext -eq 0 -and $startTime -lt (Get-Date)) { $daysUntilNext = 7 }
        (Get-Date).AddDays($daysUntilNext).Date.Add($startTime.TimeOfDay)
    } else {
        $nextDaily = (Get-Date).Date.Add($startTime.TimeOfDay)
        if ($nextDaily -lt (Get-Date)) { $nextDaily = $nextDaily.AddDays(1) }
        $nextDaily
    }
    
    return [PSCustomObject]@{
        TaskName = $taskNameText.Text
        Description = $descriptionText.Text
        ScriptPath = $scriptCombo.SelectedItem.Tag.Path
        StartTime = $startTime
        Frequency = $frequency
        DayOfWeek = $dayOfWeek
        DayOfWeekName = $dayOfWeekName
        HighestPrivileges = $privilegesCheck.IsChecked
        NextRun = $nextRun
    }
}

function Set-ButtonsEnabled {
    param([bool]$Enabled)
    
    $Global:MainWindow.FindName('ScanButton').IsEnabled = $Enabled
    $Global:MainWindow.FindName('CheckConflictsButton').IsEnabled = $Enabled
    $Global:MainWindow.FindName('PreviewButton').IsEnabled = $Enabled
    $Global:MainWindow.FindName('CreateButton').IsEnabled = $Enabled
}

# ===================================================================================================
# HAUPTPROGRAMM
# ===================================================================================================

function Start-MainApplication {
    Write-DetailedLog "DATEV Wartungsaufgaben-Automatisierung wird gestartet..." -Level 'SUCCESS'
    Write-DetailedLog "Version: 1.0 | PowerShell: $($PSVersionTable.PSVersion) | OS: $([Environment]::OSVersion.VersionString)"
    
    # Systemvoraussetzungen pruefen
    if (-not (Test-Prerequisites)) {
        Write-DetailedLog "Systemvoraussetzungen nicht erfuellt. Anwendung wird beendet." -Level 'ERROR'
        Read-Host "Druecken Sie Enter zum Beenden..."
        return
    }
    
    # Task Scheduler initialisieren
    if (-not (Initialize-TaskScheduler)) {
        Write-DetailedLog "Task Scheduler konnte nicht initialisiert werden. Anwendung wird beendet." -Level 'ERROR'
        Read-Host "Druecken Sie Enter zum Beenden..."
        return
    }
    
    # GUI initialisieren und anzeigen
    if (Initialize-GUI) {
        Write-DetailedLog "Starte GUI-Anwendung..."
        
        # Automatischer Scan beim Start
        ScanButton_Click
        
        # GUI anzeigen
        $Global:MainWindow.ShowDialog() | Out-Null
    } else {
        Write-DetailedLog "GUI konnte nicht initialisiert werden. Anwendung wird beendet." -Level 'ERROR'
        Read-Host "Druecken Sie Enter zum Beenden..."
    }
    
    Write-DetailedLog "Anwendung beendet."
    Write-DetailedLog "Protokoll gespeichert unter: $Global:LogPath"
}

# ===================================================================================================
# ANWENDUNGSSTART
# ===================================================================================================

# Fehlerbehandlung fuer unbehandelte Exceptions
$ErrorActionPreference = 'Stop'
trap {
    Write-DetailedLog "Unbehandelte Exception: $($_.Exception.Message)" -Level 'ERROR'
    Write-DetailedLog "Stack Trace: $($_.ScriptStackTrace)" -Level 'ERROR'
    Read-Host "Druecken Sie Enter zum Beenden..."
    exit 1
}

# Hauptanwendung starten
Start-MainApplication
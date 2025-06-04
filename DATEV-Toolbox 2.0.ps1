<#
.SYNOPSIS
    DATEV-Toolbox 2.0 - Eine WPF-basierte PowerShell-Anwendung

.DESCRIPTION
    Diese Anwendung stellt verschiedene Tools für DATEV-Umgebungen bereit.
    Features:
    - Tab-basierte WPF-GUI
    - Logging-System mit verschiedenen Log-Leveln
    - Persistente Einstellungsspeicherung
    - Dateimanagement-Funktionen

.NOTES
    Version:        2.0
    Autor:          Norman Zamponi
    PowerShell:     5.1+ (kompatibel)
    .NET Framework: 4.5+ (für WPF)
    
.LINK
    https://github.com/username/DATEV-Toolbox-2.0
#>

#Requires -Version 5.1

# DATEV-Toolbox 2.0

# Version und Update-Konfiguration
$script:AppVersion = "2.0.7"
$script:AppName = "DATEV-Toolbox 2.0"
$script:GitHubRepo = "Zdministrator/DATEV-Toolbox-2.0"
$script:UpdateCheckUrl = "https://github.com/$script:GitHubRepo/raw/main/version.json"
$script:ScriptDownloadUrl = "https://github.com/$script:GitHubRepo/raw/main/DATEV-Toolbox 2.0.ps1"

#region Administrator-Rechte-Prüfung
# Setup für Administratorrechte
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show("Dieses Skript benötigt Administratorrechte. Es wird jetzt mit erhöhten Rechten neu gestartet.", "Administratorrechte erforderlich", 'OK', 'Warning')
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'powershell.exe'
    $psi.Arguments = "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $psi.Verb = 'runas'
    [System.Diagnostics.Process]::Start($psi) | Out-Null
    exit
}
Write-Host "Script läuft mit Administratorrechten..." -ForegroundColor Green
#endregion

#region Initialisierung und GUI
# Konsole verstecken (funktioniert nur wenn als .ps1 ausgeführt)
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

# Konsole verstecken
$consolePtr = [Console.Window]::GetConsoleWindow()
if ($consolePtr -ne [System.IntPtr]::Zero) {
    [Console.Window]::ShowWindow($consolePtr, 0) | Out-Null
}

# Benötigte .NET-Assembly für WPF-GUI laden
Add-Type -AssemblyName PresentationFramework

# XAML-Definition für das Hauptfenster mit Tabs und Log-Bereich
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="DATEV-Toolbox 2 - Version v$script:AppVersion" Height="550" Width="420">    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="100"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>        <TabControl Grid.Row="0" Margin="10,10,10,0">            <TabItem Header="DATEV">
                <ScrollViewer VerticalScrollBarVisibility="Auto">
                    <StackPanel Orientation="Vertical" Margin="10">
                        <!-- DATEV Programme -->
                        <GroupBox Margin="5,5,5,10">
                            <GroupBox.Header>
                                <TextBlock Text="DATEV Programme" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>
                            <StackPanel Orientation="Vertical" Margin="10">
                                <Button Name="btnDATEVArbeitsplatz" Content="DATEV-Arbeitsplatz" Height="25" Margin="0,3,0,3"/>
                                <Button Name="btnInstallationsmanager" Content="Installationsmanager" Height="25" Margin="0,3,0,3"/>
                                <Button Name="btnServicetool" Content="Servicetool" Height="25" Margin="0,3,0,3"/>
                            </StackPanel>
                        </GroupBox>
                        
                        <!-- DATEV Tools -->
                        <GroupBox Margin="5,5,5,10">
                            <GroupBox.Header>
                                <TextBlock Text="DATEV Tools" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>
                            <StackPanel Orientation="Vertical" Margin="10">
                                <Button Name="btnKonfigDBTools" Content="KonfigDB-Tools" Height="25" Margin="0,3,0,3"/>
                                <Button Name="btnEODBconfig" Content="EODBconfig" Height="25" Margin="0,3,0,3"/>
                                <Button Name="btnEOAufgabenplanung" Content="EO Aufgabenplanung" Height="25" Margin="0,3,0,3"/>
                            </StackPanel>
                        </GroupBox>
                          <!-- Performance Tools -->
                        <GroupBox Margin="5,5,5,10">
                            <GroupBox.Header>
                                <TextBlock Text="Performance Tools" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>
                            <StackPanel Orientation="Vertical" Margin="10">
                                <Button Name="btnNGENALL40" Content="Native Images erzwingen" Height="25" Margin="0,3,0,3"/>
                                <Button Name="btnLeistungsindex" Content="Leistungsindex ermitteln" Height="25" Margin="0,3,0,3"/>
                            </StackPanel>
                        </GroupBox>
                    </StackPanel>
                </ScrollViewer>
            </TabItem>
            <TabItem Header="DATEV Online">
                <ScrollViewer VerticalScrollBarVisibility="Auto">
                    <StackPanel Orientation="Vertical" Margin="10">
                        <!-- Hilfe und Support -->
                        <GroupBox Margin="5,5,5,10">
                            <GroupBox.Header>
                                <TextBlock Text="Hilfe und Support" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>
                            <StackPanel Orientation="Vertical" Margin="10">
                                <Button Name="btnHilfeCenter" Content="DATEV Hilfe Center" Height="25" Margin="0,3,0,3"/>
                                <Button Name="btnServicekontakte" Content="Servicekontakte" Height="25" Margin="0,3,0,3"/>
                                <Button Name="btnMyUpdates" Content="DATEV myUpdates" Height="25" Margin="0,3,0,3"/>
                            </StackPanel>
                        </GroupBox>
                        
                        <!-- Cloud -->
                        <GroupBox Margin="5,5,5,10">
                            <GroupBox.Header>
                                <TextBlock Text="Cloud" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>
                            <StackPanel Orientation="Vertical" Margin="10">
                                <Button Name="btnMyDATEV" Content="myDATEV Portal" Height="25" Margin="0,3,0,3"/>
                                <Button Name="btnDUO" Content="DATEV Unternehmen Online" Height="25" Margin="0,3,0,3"/>
                                <Button Name="btnLAO" Content="Logistikauftrag Online" Height="25" Margin="0,3,0,3"/>
                                <Button Name="btnLizenzverwaltung" Content="Lizenzverwaltung Online" Height="25" Margin="0,3,0,3"/>
                                <Button Name="btnRechteraum" Content="DATEV Rechteraum Online" Height="25" Margin="0,3,0,3"/>
                                <Button Name="btnRVO" Content="DATEV Rechteverwaltung Online" Height="25" Margin="0,3,0,3"/>
                            </StackPanel>
                        </GroupBox>
                        
                        <!-- Verwaltung und Technik -->
                        <GroupBox Margin="5,5,5,10">
                            <GroupBox.Header>
                                <TextBlock Text="Verwaltung und Technik" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>
                            <StackPanel Orientation="Vertical" Margin="10">
                                <Button Name="btnSmartLogin" Content="SmartLogin Administration" Height="25" Margin="0,3,0,3"/>
                                <Button Name="btnBestandsmanagement" Content="myDATEV Bestandsmanagement" Height="25" Margin="0,3,0,3"/>
                                <Button Name="btnWeitereApps" Content="Weitere Cloud Anwendungen" Height="25" Margin="0,3,0,3"/>
                            </StackPanel>
                        </GroupBox>
                    </StackPanel>
                </ScrollViewer>
            </TabItem>            <TabItem Header="Downloads">
                <StackPanel Orientation="Vertical" Margin="10">
                    <GroupBox Margin="0,0,0,10">
                        <GroupBox.Header>
                            <StackPanel Orientation="Horizontal">
                                <TextBlock Text="Direkt Downloads" FontWeight="Bold" FontSize="12" VerticalAlignment="Center"/>
                                <TextBlock Name="btnUpdateDownloads" Text="🔄" FontSize="14" Margin="8,0,0,0" 
                                           ToolTip="Direkt-Downloads aktualisieren" VerticalAlignment="Center" 
                                           Cursor="Hand" Foreground="Black"/>
                            </StackPanel>
                        </GroupBox.Header>                        <StackPanel Orientation="Vertical" Margin="10">                            <ComboBox Name="cmbDirectDownloads" Margin="0,0,0,10" Height="25"/>
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="Auto"/>
                                </Grid.ColumnDefinitions>
                                <Button Name="btnDownload" Grid.Column="0" Content="Download starten" Height="25" 
                                        VerticalAlignment="Top" Margin="0,0,8,0" IsEnabled="False"/>
                                <TextBlock Name="btnOpenDownloadFolder" Grid.Column="1" Text="📁" FontSize="16" Margin="0,0,0,0" 
                                           ToolTip="Download-Ordner öffnen" VerticalAlignment="Center" 
                                           Cursor="Hand" Foreground="Black"/>
                            </Grid>                        </StackPanel>
                    </GroupBox>
                    
                    <!-- DATEV Online Downloads -->
                    <GroupBox Margin="0,0,0,10">
                        <GroupBox.Header>
                            <TextBlock Text="Downloads von datev.de" FontWeight="Bold" FontSize="12"/>
                        </GroupBox.Header>
                        <StackPanel Orientation="Vertical" Margin="10">
                            <Button Name="btnDATEVDownloadbereich" Content="DATEV Downloadbereich" Height="25" Margin="0,3,0,3"/>
                            <Button Name="btnDATEVSmartDocs" Content="DATEV Smart Docs" Height="25" Margin="0,3,0,3"/>
                            <Button Name="btnDatentraegerPortal" Content="Datenträger Download Portal" Height="25" Margin="0,3,0,3"/>
                        </StackPanel>
                    </GroupBox>                </StackPanel>
            </TabItem><TabItem Header="System">
                <ScrollViewer VerticalScrollBarVisibility="Auto">
                    <StackPanel Orientation="Vertical" Margin="10">
                        <!-- System Tools -->
                        <GroupBox Margin="5,5,5,10">
                            <GroupBox.Header>
                                <TextBlock Text="System Tools" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>
                            <StackPanel Orientation="Vertical" Margin="10">
                                <Button Name="btnTaskManager" Content="Task-Manager" Height="25" Margin="0,3,0,3"/>
                                <Button Name="btnResourceMonitor" Content="Ressourcenmonitor" Height="25" Margin="0,3,0,3"/>
                                <Button Name="btnEventViewer" Content="Ereignisanzeige" Height="25" Margin="0,3,0,3"/>
                                <Button Name="btnServices" Content="Dienste" Height="25" Margin="0,3,0,3"/>
                                <Button Name="btnMsconfig" Content="Systemkonfiguration" Height="25" Margin="0,3,0,3"/>
                                <Button Name="btnDiskCleanup" Content="Datenträgerbereinigung" Height="25" Margin="0,3,0,3"/>
                            </StackPanel>
                        </GroupBox>
                    </StackPanel>
                </ScrollViewer>
            </TabItem><TabItem Header="Einstellungen">
                <ScrollViewer VerticalScrollBarVisibility="Auto">
                    <StackPanel Orientation="Vertical" Margin="10">
                        <!-- Einstellungen -->
                        <GroupBox Margin="5,5,5,10">
                            <GroupBox.Header>
                                <TextBlock Text="DATEV-Toolbox Einstellungen" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>                            <StackPanel Orientation="Vertical" Margin="10">
                                <Button Name="btnOpenFolder" Content="Toolbox Ordner öffnen" Height="25" Margin="0,3,0,3"/>
                                <Button Name="btnCheckUpdate" Content="Nach Script Updates suchen" Height="25" Margin="0,3,0,3"/>
                                <!-- Hier können zukünftig Einstellungen ergänzt werden -->
                            </StackPanel>
                        </GroupBox>
                          <!-- Anstehende Update-Termine -->
                        <GroupBox Margin="5,5,5,10">
                            <GroupBox.Header>
                                <StackPanel Orientation="Horizontal">
                                    <TextBlock Text="Anstehende Update-Termine" FontWeight="Bold" FontSize="12" VerticalAlignment="Center"/>
                                    <TextBlock Name="btnUpdateDates" Text="🔄" FontSize="14" Margin="8,0,0,0" 
                                               ToolTip="Update-Termine aktualisieren" VerticalAlignment="Center" 
                                               Cursor="Hand" Foreground="Black"/>
                                </StackPanel>
                            </GroupBox.Header>                            <StackPanel Orientation="Vertical" Margin="10">
                                <StackPanel Name="spUpdateDates" Orientation="Vertical" Margin="0,0,0,0">
                                    <TextBlock Text="Klicken Sie auf 'Update-Termine aktualisieren'." 
                                               FontStyle="Italic" Foreground="Gray"/>
                                </StackPanel>
                            </StackPanel>
                        </GroupBox>
                    </StackPanel>
                </ScrollViewer>
            </TabItem>
        </TabControl>        <TextBox Name="txtLog" Grid.Row="1" Margin="10,5,10,5" 
                 VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto"
                 IsReadOnly="True" TextWrapping="Wrap" FontSize="10"/>
        <TextBlock Grid.Row="2" Text="Norman Zamponi | HEES GmbH | © 2025" 
                   HorizontalAlignment="Center" VerticalAlignment="Center"
                   FontSize="10" Foreground="Gray" Margin="10,2,10,5"/>
    </Grid>
</Window>
"@

# XAML parsen und Fenster-Objekt erzeugen mit Fehlerbehandlung
try {
    $reader = New-Object System.Xml.XmlNodeReader $xaml
    $window = [Windows.Markup.XamlReader]::Load($reader)
}
catch {
    Write-Error "Fehler beim Laden der GUI: $($_.Exception.Message)"
    exit 1
}

# Referenz auf das Log-Textfeld holen
$txtLog = $window.FindName("txtLog")

# Referenzen auf DATEV Cloud Elemente holen
$cmbDirectDownloads = $window.FindName("cmbDirectDownloads")
$btnDownload = $window.FindName("btnDownload")
$btnUpdateDownloads = $window.FindName("btnUpdateDownloads")
$btnOpenDownloadFolder = $window.FindName("btnOpenDownloadFolder")

# Referenzen auf DATEV Online Downloads Buttons holen
$btnDATEVDownloadbereich = $window.FindName("btnDATEVDownloadbereich")
$btnDATEVSmartDocs = $window.FindName("btnDATEVSmartDocs")
$btnDatentraegerPortal = $window.FindName("btnDatentraegerPortal")

# Referenzen auf DATEV Tools Elemente holen
$spUpdateDates = $window.FindName("spUpdateDates")
$btnUpdateDates = $window.FindName("btnUpdateDates")

# Referenzen auf DATEV Programme Buttons holen
$btnDATEVArbeitsplatz = $window.FindName("btnDATEVArbeitsplatz")
$btnInstallationsmanager = $window.FindName("btnInstallationsmanager")
$btnServicetool = $window.FindName("btnServicetool")

# Referenzen auf DATEV Tools Buttons holen
$btnKonfigDBTools = $window.FindName("btnKonfigDBTools")
$btnEODBconfig = $window.FindName("btnEODBconfig")
$btnEOAufgabenplanung = $window.FindName("btnEOAufgabenplanung")

# Referenzen auf DATEV Performance Tools Buttons holen
$btnNGENALL40 = $window.FindName("btnNGENALL40")
$btnLeistungsindex = $window.FindName("btnLeistungsindex")

# Referenzen auf System Tools Buttons holen
$btnTaskManager = $window.FindName("btnTaskManager")
$btnResourceMonitor = $window.FindName("btnResourceMonitor")
$btnEventViewer = $window.FindName("btnEventViewer")
$btnServices = $window.FindName("btnServices")
$btnMsconfig = $window.FindName("btnMsconfig")
$btnDiskCleanup = $window.FindName("btnDiskCleanup")
#endregion

#region Logging-Funktion
# Funktion zum Schreiben von Log-Einträgen in das Log-Feld
function Write-Log {
    param(
        [Parameter(Mandatory = $true)][string]$Message,
        [ValidateSet('INFO', 'WARN', 'ERROR')][string]$Level = 'INFO'
    )
    
    try {
        $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        switch ($Level) {
            'INFO' { $prefix = '[INFO] ' }
            'WARN' { $prefix = '[WARNUNG] ' }
            'ERROR' { $prefix = '[FEHLER] ' }
        }
        $logEntry = "$timestamp $prefix$Message`r`n"
        
        if ($null -ne $txtLog) {
            $txtLog.AppendText($logEntry) # Log-Eintrag anhängen
            $txtLog.ScrollToEnd()         # Automatisch nach unten scrollen
        }
        
        # Warnungen und Fehler zusätzlich in Error-Log.txt speichern
        if ($Level -eq 'WARN' -or $Level -eq 'ERROR') {
            $logDir = Join-Path $env:APPDATA 'DATEV-Toolbox 2.0'
            if (-not (Test-Path $logDir)) {
                New-Item -Path $logDir -ItemType Directory -Force | Out-Null
            }
            $logFile = Join-Path $logDir 'Error-Log.txt'
            Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
        }
    }
    catch {
        # Fallback wenn Logging fehlschlägt
        Write-Host "LOGGING-FEHLER: $($_.Exception.Message)" -ForegroundColor Red
    }
}
#endregion

#endregion

#region DATEV-Tools Funktionen
# DATEV-Pfad-Definitionen
$script:DATEVProgramPaths = @{
    'DATEVArbeitsplatz' = @(
        '%DATEVPP%\PROGRAMM\K0005000\Arbeitsplatz.exe'
    )
    'Installationsmanager' = @(
        '%DATEVPP%\PROGRAMM\INSTALL\DvInesInstMan.exe'
    )
    'Servicetool' = @(
        '%DATEVPP%\PROGRAMM\SRVTOOL\Srvtool.exe'
    )
    'KonfigDBTools' = @(
        '%DATEVPP%\PROGRAMM\B0001502\cdbtool.exe'
    )
    'EODBconfig' = @(
        '%DATEVPP%\PROGRAMM\EODB\EODBConfig.exe'
    )
    'EOAufgabenplanung' = @(
        '%DATEVPP%\PROGRAMM\I0000085\EOControl.exe'
    )
    'NGENALL40' = @(
        '%DATEVPP%\Programm\B0001508\ngenall40.cmd'
    )
    'Leistungsindex' = @(
        '%DATEVPP%\PROGRAMM\RWAPPLIC\irw.exe'
    )
}

# Funktion zum Finden und Starten von DATEV-Programmen
function Start-DATEVProgram {
    param(
        [Parameter(Mandatory = $true)][string]$ProgramName,
        [Parameter(Mandatory = $true)][array]$PossiblePaths,
        [string]$Description = $ProgramName
    )
    
    try {
        Write-Log -Message "Suche nach $Description..." -Level 'INFO'
        
        $foundPath = $null
        foreach ($path in $PossiblePaths) {
            # %DATEVPP% durch tatsächlichen DATEV-Pfad ersetzen
            $expandedPath = $path -replace '%DATEVPP%', $env:DATEVPP
            if ([string]::IsNullOrEmpty($env:DATEVPP)) {
                # Fallback: Standard DATEV-Pfade durchsuchen
                $standardPaths = @(
                    'C:\DATEV',
                    'D:\DATEV',
                    'E:\DATEV',
                    "${env:ProgramFiles(x86)}\DATEV",
                    "${env:ProgramFiles}\DATEV"
                )
                
                foreach ($basePath in $standardPaths) {
                    $testPath = $path -replace '%DATEVPP%', $basePath
                    if (Test-Path $testPath) {
                        $foundPath = $testPath
                        break
                    }
                }
            }
            else {
                if (Test-Path $expandedPath) {
                    $foundPath = $expandedPath
                    break
                }
            }
            
            if ($foundPath) { break }
        }
        
        if ($foundPath) {
            Write-Log -Message "Starte $Description von: $foundPath" -Level 'INFO'
            Start-Process -FilePath $foundPath
        }
        else {
            Write-Log -Message "$Description wurde nicht gefunden. Überprüfen Sie die DATEV-Installation." -Level 'WARN'
            [System.Windows.MessageBox]::Show(
                "$Description wurde auf diesem System nicht gefunden.`n`nMögliche Ursachen:`n• DATEV nicht installiert`n• DATEVPP-Umgebungsvariable nicht gesetzt`n• Programm in anderem Pfad installiert`n• Fehlende Berechtigung",
                "DATEV-Programm nicht gefunden",
                [System.Windows.MessageBoxButton]::OK,
                [System.Windows.MessageBoxImage]::Warning
            )
        }
    }
    catch {
        Write-Log -Message "Fehler beim Starten von $Description`: $($_.Exception.Message)" -Level 'ERROR'
        [System.Windows.MessageBox]::Show(
            "Fehler beim Starten von $Description`:`n$($_.Exception.Message)",
            "Fehler",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error
        )
    }
}

# Spezielle Funktion für den Leistungsindex (startet das Programm 2x mit unterschiedlichen Parametern)
function Start-Leistungsindex {
    try {
        Write-Log -Message "Suche nach Leistungsindex (irw.exe)..." -Level 'INFO'
        
        $foundPath = $null
        $possiblePaths = $script:DATEVProgramPaths['Leistungsindex']
        
        foreach ($path in $possiblePaths) {
            # %DATEVPP% durch tatsächlichen DATEV-Pfad ersetzen
            $expandedPath = $path -replace '%DATEVPP%', $env:DATEVPP
            if ([string]::IsNullOrEmpty($env:DATEVPP)) {
                # Fallback: Standard DATEV-Pfade durchsuchen
                $standardPaths = @(
                    'C:\DATEV',
                    'D:\DATEV',
                    'E:\DATEV',
                    "${env:ProgramFiles(x86)}\DATEV",
                    "${env:ProgramFiles}\DATEV"
                )
                
                foreach ($basePath in $standardPaths) {
                    $testPath = $path -replace '%DATEVPP%', $basePath
                    if (Test-Path $testPath) {
                        $foundPath = $testPath
                        break
                    }
                }
            }
            else {
                if (Test-Path $expandedPath) {
                    $foundPath = $expandedPath
                    break
                }
            }
            
            if ($foundPath) { break }
        }
        
        if ($foundPath) {
            Write-Log -Message "Starte Leistungsindex von: $foundPath" -Level 'INFO'
            Write-Log -Message "Erster Durchlauf: -ap:PerfIndex -d:IRW20011 -c" -Level 'INFO'
            Start-Process -FilePath $foundPath -ArgumentList "-ap:PerfIndex -d:IRW20011 -c" -Wait
            
            Write-Log -Message "Zweiter Durchlauf: -ap:PerfIndex -d:IRW20011" -Level 'INFO'
            Start-Process -FilePath $foundPath -ArgumentList "-ap:PerfIndex -d:IRW20011" -Wait
            
            Write-Log -Message "Leistungsindex-Messungen abgeschlossen" -Level 'INFO'
        }
        else {
            Write-Log -Message "Leistungsindex (irw.exe) wurde nicht gefunden. Überprüfen Sie die DATEV-Installation." -Level 'WARN'
            [System.Windows.MessageBox]::Show(
                "Leistungsindex (irw.exe) wurde auf diesem System nicht gefunden.`n`nMögliche Ursachen:`n• DATEV nicht installiert`n• DATEVPP-Umgebungsvariable nicht gesetzt`n• Programm in anderem Pfad installiert`n• Fehlende Berechtigung",
                "DATEV-Programm nicht gefunden",
                [System.Windows.MessageBoxButton]::OK,
                [System.Windows.MessageBoxImage]::Warning
            )
        }
    }
    catch {
        Write-Log -Message "Fehler beim Starten des Leistungsindex: $($_.Exception.Message)" -Level 'ERROR'
        [System.Windows.MessageBox]::Show(
            "Fehler beim Starten des Leistungsindex:`n$($_.Exception.Message)",
            "Fehler",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error
        )
    }
}
#endregion

#region System-Tools Funktionen
# Funktion zum Starten von System-Tools
function Start-SystemTool {
    param(
        [Parameter(Mandatory = $true)][string]$Command,
        [string]$Arguments = "",
        [string]$Description = $Command
    )
    
    try {
        Write-Log -Message "Starte $Description..." -Level 'INFO'
        
        if ([string]::IsNullOrEmpty($Arguments)) {
            Start-Process -FilePath $Command
        }
        else {
            Start-Process -FilePath $Command -ArgumentList $Arguments
        }
    }
    catch {
        Write-Log -Message "Fehler beim Starten von $Description`: $($_.Exception.Message)" -Level 'ERROR'
        [System.Windows.MessageBox]::Show(
            "Fehler beim Starten von $Description`:`n$($_.Exception.Message)",
            "Fehler",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error
        )
    }
}
#endregion

#region Einstellungen-Funktion
# Funktion zum Speichern von Einstellungen in settings.json im AppData-Ordner
function Set-Settings {
    param(
        [Parameter(Mandatory = $true)][hashtable]$Settings
    )
    
    try {
        $settingsDir = Join-Path $env:APPDATA 'DATEV-Toolbox 2.0'
        if (-not (Test-Path $settingsDir)) {
            New-Item -Path $settingsDir -ItemType Directory -Force | Out-Null
        }
        $settingsFile = Join-Path $settingsDir 'settings.json'
        $json = $Settings | ConvertTo-Json -Depth 5
        Set-Content -Path $settingsFile -Value $json -Encoding UTF8
        Write-Log -Message "Einstellungen erfolgreich gespeichert" -Level 'INFO'
    }
    catch {
        Write-Log -Message "Fehler beim Speichern der Einstellungen: $($_.Exception.Message)" -Level 'ERROR'
    }
}

# Funktion zum Laden von Einstellungen aus settings.json
function Get-Settings {
    try {
        $settingsFile = Join-Path (Join-Path $env:APPDATA 'DATEV-Toolbox 2.0') 'settings.json'
        if (Test-Path $settingsFile) {
            $json = Get-Content -Path $settingsFile -Raw -Encoding UTF8
            $settings = $json | ConvertFrom-Json
            Write-Log -Message "Einstellungen erfolgreich geladen" -Level 'INFO'
            return $settings
        }
        else {
            Write-Log -Message "Keine Einstellungsdatei gefunden, verwende Standardwerte" -Level 'INFO'
            return @{}
        }
    }
    catch {
        Write-Log -Message "Fehler beim Laden der Einstellungen: $($_.Exception.Message)" -Level 'ERROR'        return @{}
    }
}
#endregion

#region Update-Check-Funktionen
# Funktion zum Bereinigen alter Update-Backups (behält nur die letzten 5)
function Clear-OldUpdateBackups {
    try {
        $updateDir = Join-Path (Join-Path $env:APPDATA 'DATEV-Toolbox 2.0') 'Updates'
        if (-not (Test-Path $updateDir)) {
            return
        }
        
        # Alle Backup-Dateien finden und nach Datum sortieren
        $backupFiles = Get-ChildItem -Path $updateDir -Filter "*.backup" | Sort-Object CreationTime -Descending
        
        # Nur die letzten 5 behalten, den Rest löschen
        if ($backupFiles.Count -gt 5) {
            $filesToDelete = $backupFiles | Select-Object -Skip 5
            foreach ($file in $filesToDelete) {
                try {
                    Remove-Item $file.FullName -Force
                    Write-Log -Message "Altes Backup gelöscht: $($file.Name)" -Level 'INFO'
                }
                catch {
                    Write-Log -Message "Konnte altes Backup nicht löschen: $($file.Name) - $($_.Exception.Message)" -Level 'WARN'
                }
            }
        }
    }
    catch {
        Write-Log -Message "Fehler beim Bereinigen alter Backups: $($_.Exception.Message)" -Level 'WARN'
    }
}

# Funktion zum Abrufen der aktuellen lokalen Version
function Get-CurrentVersion {
    return $script:AppVersion
}

# Funktion zum Vergleichen von Versionen (Semantic Versioning)
function Compare-Version {
    param(
        [Parameter(Mandatory = $true)][string]$Version1,
        [Parameter(Mandatory = $true)][string]$Version2
    )
    
    try {
        $v1Parts = $Version1 -split '\.' | ForEach-Object { [int]$_ }
        $v2Parts = $Version2 -split '\.' | ForEach-Object { [int]$_ }
        
        # Sicherstellen dass beide Arrays die gleiche Länge haben
        $maxLength = [Math]::Max($v1Parts.Length, $v2Parts.Length)
        while ($v1Parts.Length -lt $maxLength) { $v1Parts += 0 }
        while ($v2Parts.Length -lt $maxLength) { $v2Parts += 0 }
        
        for ($i = 0; $i -lt $maxLength; $i++) {
            if ($v1Parts[$i] -lt $v2Parts[$i]) { return -1 }
            if ($v1Parts[$i] -gt $v2Parts[$i]) { return 1 }
        }
        return 0
    }
    catch {
        Write-Log -Message "Fehler beim Vergleichen der Versionen: $($_.Exception.Message)" -Level 'ERROR'
        return 0
    }
}

# Funktion zum Prüfen auf verfügbare Updates
function Test-ForUpdates {
    param(
        [switch]$Silent
    )
    
    try {
        if (-not $Silent) {
            Write-Log -Message "Prüfe auf verfügbare Updates..." -Level 'INFO'
        }
        
        # TLS 1.2 für sichere Downloads erzwingen
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        
        # Version.json von GitHub laden
        $versionInfo = Invoke-RestMethod -Uri $script:UpdateCheckUrl -TimeoutSec 10 -UseBasicParsing
        
        $currentVersion = Get-CurrentVersion
        $remoteVersion = $versionInfo.version
        
        Write-Log -Message "Aktuelle Version: $currentVersion, Verfügbare Version: $remoteVersion" -Level 'INFO'
        
        $comparison = Compare-Version -Version1 $currentVersion -Version2 $remoteVersion
        
        if ($comparison -lt 0) {
            # Update verfügbar
            if (-not $Silent) {
                Write-Log -Message "Update verfügbar: Version $remoteVersion" -Level 'INFO'
            }
            return @{
                UpdateAvailable = $true
                CurrentVersion = $currentVersion
                NewVersion = $remoteVersion
                VersionInfo = $versionInfo
            }
        }
        else {
            if (-not $Silent) {
                Write-Log -Message "Sie verwenden bereits die neueste Version" -Level 'INFO'
            }
            return @{
                UpdateAvailable = $false
                CurrentVersion = $currentVersion
                NewVersion = $remoteVersion
                VersionInfo = $versionInfo
            }
        }
    }
    catch {
        Write-Log -Message "Fehler beim Prüfen auf Updates: $($_.Exception.Message)" -Level 'ERROR'
        return @{
            UpdateAvailable = $false
            Error = $_.Exception.Message
        }
    }
}

# Funktion zum Anzeigen des Update-Dialogs
function Show-UpdateDialog {
    param(
        [Parameter(Mandatory = $true)][hashtable]$UpdateInfo
    )
    
    try {
        $changelog = if ($UpdateInfo.VersionInfo.changelog) { 
            "`n`nÄnderungen:`n" + ($UpdateInfo.VersionInfo.changelog -join "`n• ")
        } else { "" }
        
        $message = "Ein Update ist verfügbar!`n`n" +
                  "Aktuelle Version: $($UpdateInfo.CurrentVersion)`n" +
                  "Neue Version: $($UpdateInfo.NewVersion)`n" +
                  "Erscheinungsdatum: $($UpdateInfo.VersionInfo.releaseDate)" +
                  $changelog +
                  "`n`nMöchten Sie jetzt aktualisieren?"
        
        $result = [System.Windows.MessageBox]::Show(
            $message,
            "Update verfügbar - $script:AppName",
            [System.Windows.MessageBoxButton]::YesNo,
            [System.Windows.MessageBoxImage]::Question
        )
        
        return $result -eq [System.Windows.MessageBoxResult]::Yes
    }
    catch {
        Write-Log -Message "Fehler beim Anzeigen des Update-Dialogs: $($_.Exception.Message)" -Level 'ERROR'
        return $false
    }
}

# Funktion zum Herunterladen und Anwenden eines Updates
function Start-UpdateProcess {
    param(
        [Parameter(Mandatory = $true)][hashtable]$UpdateInfo
    )
    
    try {
        Write-Log -Message "Starte Update-Prozess für Version $($UpdateInfo.NewVersion)..." -Level 'INFO'
        
        # AppData-Verzeichnis für Updates erstellen
        $appDataDir = Join-Path $env:APPDATA 'DATEV-Toolbox 2.0'
        $updateDir = Join-Path $appDataDir 'Updates'
        if (-not (Test-Path $updateDir)) {
            New-Item -Path $updateDir -ItemType Directory -Force | Out-Null
            Write-Log -Message "Update-Verzeichnis erstellt: $updateDir" -Level 'INFO'
        }
        
        # Aktuellen Skript-Pfad ermitteln
        $currentScriptPath = $MyInvocation.ScriptName
        if ([string]::IsNullOrEmpty($currentScriptPath)) {
            $currentScriptPath = $PSCommandPath
        }
        
        if ([string]::IsNullOrEmpty($currentScriptPath)) {
            throw "Kann den aktuellen Skript-Pfad nicht ermitteln"
        }
        
        # Pfade im AppData-Ordner definieren
        $timestamp = (Get-Date).ToString('yyyyMMdd-HHmmss')
        $backupPath = Join-Path $updateDir "DATEV-Toolbox-$timestamp.backup"
        $tempUpdatePath = Join-Path $updateDir "DATEV-Toolbox-$($UpdateInfo.NewVersion).download"
        $updateBatchPath = Join-Path $updateDir "Update-$timestamp.bat"
        
        Write-Log -Message "Update-Pfade: Backup=$backupPath, Download=$tempUpdatePath, Batch=$updateBatchPath" -Level 'INFO'
          # TLS 1.2 für sichere Downloads erzwingen
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        
        # Neue Version herunterladen
        Write-Log -Message "Lade neue Version herunter nach: $tempUpdatePath" -Level 'INFO'
        Invoke-WebRequest -Uri $UpdateInfo.VersionInfo.downloadUrl -OutFile $tempUpdatePath -UseBasicParsing -TimeoutSec 30
        
        # Erweiterte Integrität prüfen
        $downloadedFile = Get-Item $tempUpdatePath
        if ($downloadedFile.Length -lt 1000) {
            throw "Heruntergeladene Datei ist zu klein ($($downloadedFile.Length) Bytes) und möglicherweise beschädigt"
        }
        
        # PowerShell-Syntax-Check der heruntergeladenen Datei
        try {
            $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $tempUpdatePath -Raw), [ref]$null)
            Write-Log -Message "PowerShell-Syntax-Prüfung der heruntergeladenen Datei erfolgreich" -Level 'INFO'
        }
        catch {
            throw "Heruntergeladene Datei hat ungültige PowerShell-Syntax: $($_.Exception.Message)"
        }
        
        Write-Log -Message "Download erfolgreich ($($downloadedFile.Length) Bytes). Erstelle Backup und Update-Skript..." -Level 'INFO'
          # Batch-Skript für verzögertes Update erstellen
        $batchContent = @"
@echo off
echo ===============================================
echo DATEV-Toolbox 2.0 Update-Installation
echo Version: $($UpdateInfo.NewVersion)
echo ===============================================
echo.

echo [1/5] Warte auf Beendigung der DATEV-Toolbox...
timeout /t 3 /nobreak >nul

echo [2/5] Erstelle Backup der aktuellen Version...
copy "$currentScriptPath" "$backupPath" >nul
if errorlevel 1 (
    echo FEHLER: Backup konnte nicht erstellt werden!
    echo Aktuelle Datei: $currentScriptPath
    echo Backup-Ziel: $backupPath
    pause
    exit /b 1
)
echo Backup erfolgreich erstellt: $backupPath

echo [3/5] Installiere neue Version...
copy "$tempUpdatePath" "$currentScriptPath" >nul
if errorlevel 1 (
    echo FEHLER: Installation der neuen Version fehlgeschlagen!
    echo Stelle Backup wieder her...
    copy "$backupPath" "$currentScriptPath" >nul
    if errorlevel 1 (
        echo KRITISCHER FEHLER: Rollback fehlgeschlagen!
        echo Backup manuell wiederherstellen: $backupPath
        pause
        exit /b 2
    )
    echo Rollback erfolgreich.
    pause
    exit /b 1
)
echo Installation erfolgreich.

echo [4/5] Bereinige temporäre Dateien...
del "$tempUpdatePath" >nul 2>&1

echo [5/5] Starte DATEV-Toolbox neu...
echo.
echo Update auf Version $($UpdateInfo.NewVersion) erfolgreich installiert!

REM Versuche zuerst pwsh.exe (PowerShell 7+), dann powershell.exe (PowerShell 5.1)
where pwsh.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo Starte mit PowerShell 7+ ^(pwsh.exe^)...
    start "" pwsh.exe -File "$currentScriptPath"
) else (
    echo PowerShell 7+ nicht gefunden, verwende PowerShell 5.1 ^(powershell.exe^)...
    start "" powershell.exe -File "$currentScriptPath"
)

echo.
echo Bereinige Update-Skript in 5 Sekunden...
timeout /t 5 /nobreak >nul
del "%~f0" >nul 2>&1
"@
          Set-Content -Path $updateBatchPath -Value $batchContent -Encoding ASCII
        
        Write-Log -Message "Update wird angewendet. Anwendung wird neu gestartet..." -Level 'INFO'
        Write-Log -Message "Backup wird erstellt unter: $backupPath" -Level 'INFO'          # Update-Einstellungen speichern (PSObject sicher in Hashtable konvertieren)
        $settingsHash = @{}
        if ($settings -is [PSCustomObject]) {
            foreach ($property in $settings.PSObject.Properties) {
                $settingsHash[$property.Name] = $property.Value
            }
        }
        else {
            $settingsHash = $settings
        }
        $settingsHash.lastUpdateCheck = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
        $settingsHash.lastInstalledVersion = $UpdateInfo.NewVersion
        $settingsHash.lastBackupPath = $backupPath
        $settingsHash.updateHistory = if ($settingsHash.updateHistory) { $settingsHash.updateHistory } else { @() }
        $settingsHash.updateHistory += @{
            version = $UpdateInfo.NewVersion
            date = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
            backupPath = $backupPath
        }
        Set-Settings -Settings $settingsHash
        
        # Alte Backups bereinigen (behält nur die letzten 5)
        Clear-OldUpdateBackups
          # Batch-Skript ausführen und Anwendung beenden
        Write-Log -Message "Starte Update-Batch-Skript: $updateBatchPath" -Level 'INFO'
        Start-Process -FilePath $updateBatchPath -WindowStyle Normal
        
        # Kurz warten und dann Fenster schließen
        Start-Sleep -Milliseconds 500
        $window.Close()
        
        return $true
    }
    catch {
        Write-Log -Message "Fehler beim Update-Prozess: $($_.Exception.Message)" -Level 'ERROR'
        
        # Aufräumen bei Fehler - alle temporären Dateien im AppData-Ordner
        $filesToCleanup = @($tempUpdatePath, $updateBatchPath)
        foreach ($file in $filesToCleanup) {
            if (Test-Path $file) {
                try {
                    Remove-Item $file -Force -ErrorAction Stop
                    Write-Log -Message "Temporäre Datei bereinigt: $file" -Level 'INFO'
                }
                catch {
                    Write-Log -Message "Konnte temporäre Datei nicht bereinigen: $file - $($_.Exception.Message)" -Level 'WARN'
                }
            }
        }
        
        [System.Windows.MessageBox]::Show(
            "Fehler beim Update-Prozess:`n$($_.Exception.Message)",
            "Update fehlgeschlagen",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error
        )
        
        return $false
    }
}

# Funktion für automatischen Update-Check beim Start
function Initialize-UpdateCheck {
    try {
        # Einstellungen laden
        $settings = Get-Settings
        $checkInterval = 24 # Stunden
        
        # Letzten Check-Zeitpunkt prüfen
        $lastCheck = $null
        if ($settings.lastUpdateCheck) {
            try {
                $lastCheck = [DateTime]::Parse($settings.lastUpdateCheck)
            }
            catch {
                Write-Log -Message "Ungültiger lastUpdateCheck Wert, setze zurück" -Level 'WARN'
            }
        }
        
        $shouldCheck = $false
        if ($null -eq $lastCheck) {
            $shouldCheck = $true
            Write-Log -Message "Erster Update-Check wird durchgeführt" -Level 'INFO'
        }
        elseif ($lastCheck.AddHours($checkInterval) -lt (Get-Date)) {
            $shouldCheck = $true
            Write-Log -Message "Update-Check-Intervall erreicht (alle $checkInterval Stunden)" -Level 'INFO'
        }
          if ($shouldCheck) {            # Stillen Update-Check durchführen
            $updateInfo = Test-ForUpdates -Silent
            
            if ($updateInfo.UpdateAvailable) {
                Write-Log -Message "Update verfügbar: Version $($updateInfo.NewVersion)" -Level 'INFO'
                
                # Update-Dialog anzeigen
                $userWantsUpdate = Show-UpdateDialog -UpdateInfo $updateInfo
                
                if ($userWantsUpdate) {
                    Start-UpdateProcess -UpdateInfo $updateInfo
                }
                else {
                    Write-Log -Message "Benutzer hat Update abgelehnt" -Level 'INFO'
                }
            }
            
            # Letzten Check-Zeitpunkt aktualisieren (PSObject in Hashtable konvertieren)
            $settingsHash = @{}
            if ($settings -is [PSCustomObject]) {
                foreach ($property in $settings.PSObject.Properties) {
                    $settingsHash[$property.Name] = $property.Value
                }
            }
            else {
                $settingsHash = $settings
            }
            $settingsHash.lastUpdateCheck = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
            Set-Settings -Settings $settingsHash
        }
        else {
            Write-Log -Message "Update-Check übersprungen (letzter Check: $($lastCheck.ToString('yyyy-MM-dd HH:mm')))" -Level 'INFO'
        }
    }
    catch {
        Write-Log -Message "Fehler beim automatischen Update-Check: $($_.Exception.Message)" -Level 'ERROR'
    }
}

# Funktion für manuellen Update-Check
function Start-ManualUpdateCheck {
    try {
        Write-Log -Message "Manueller Update-Check gestartet..." -Level 'INFO'
        
        $updateInfo = Test-ForUpdates
        
        if ($updateInfo.UpdateAvailable) {
            $userWantsUpdate = Show-UpdateDialog -UpdateInfo $updateInfo
            
            if ($userWantsUpdate) {
                Start-UpdateProcess -UpdateInfo $updateInfo
            }
        }
        else {
            [System.Windows.MessageBox]::Show(
                "Sie verwenden bereits die neueste Version ($($updateInfo.CurrentVersion)).",
                "Kein Update verfügbar",
                [System.Windows.MessageBoxButton]::OK,
                [System.Windows.MessageBoxImage]::Information
            )
        }
    }
    catch {
        Write-Log -Message "Fehler beim manuellen Update-Check: $($_.Exception.Message)" -Level 'ERROR'
    }
}
#endregion

#region DATEV Downloads-Funktion
# Funktion zum Laden der DATEV Downloads aus datev-downloads.json
function Get-DATEVDownloads {
    try {
        # Nur im AppData-Ordner suchen
        $appDataFile = Join-Path (Join-Path $env:APPDATA 'DATEV-Toolbox 2.0') 'datev-downloads.json'
        
        if (Test-Path $appDataFile) {
            $json = Get-Content -Path $appDataFile -Raw -Encoding UTF8
            $downloadsData = $json | ConvertFrom-Json
            Write-Log -Message "DATEV Downloads erfolgreich aus AppData geladen" -Level 'INFO'
            return $downloadsData.downloads
        }
        else {
            Write-Log -Message "Keine datev-downloads.json im AppData-Ordner gefunden. Bitte erst aktualisieren." -Level 'WARN'
            return @()
        }
    }
    catch {
        Write-Log -Message "Fehler beim Laden der DATEV Downloads: $($_.Exception.Message)" -Level 'ERROR'
        return @()
    }
}

# Funktion zum Aktualisieren der datev-downloads.json aus GitHub
function Update-DATEVDownloads {
    $downloadsUrl = "https://github.com/Zdministrator/DATEV-Toolbox-2.0/raw/refs/heads/main/datev-downloads.json"
    $localFile = Join-Path (Join-Path $env:APPDATA 'DATEV-Toolbox 2.0') 'datev-downloads.json'
    
    Write-Log -Message "Benutzeraktion: Direkt-Downloads aktualisieren geklickt. Lade JSON von $downloadsUrl" -Level 'INFO'
    
    try {
        # Verzeichnis erstellen falls es nicht existiert
        $downloadsDir = Join-Path $env:APPDATA 'DATEV-Toolbox 2.0'
        if (-not (Test-Path $downloadsDir)) {
            New-Item -Path $downloadsDir -ItemType Directory -Force | Out-Null
            Write-Log -Message "Downloads-Verzeichnis erstellt: $downloadsDir" -Level 'INFO'
        }
        
        # Button während Download deaktivieren
        if ($null -ne $btnUpdateDownloads) {
            $btnUpdateDownloads.IsEnabled = $false
        }
        
        # TLS 1.2 für sichere Downloads erzwingen
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        
        # JSON-Datei herunterladen
        Invoke-WebRequest -Uri $downloadsUrl -OutFile $localFile -UseBasicParsing -TimeoutSec 15
        
        Write-Log -Message "Downloads-JSON erfolgreich aktualisiert: $localFile" -Level 'INFO'
        
        # ComboBox neu initialisieren mit aktualisierten Daten
        Initialize-DownloadsComboBox
        
        Write-Log -Message "Downloads-Liste erfolgreich aktualisiert" -Level 'INFO'
    }
    catch {
        Write-Log -Message "Fehler beim Aktualisieren der Downloads-JSON: $($_.Exception.Message)" -Level 'ERROR'
    }
    finally {
        # Button wieder aktivieren
        if ($null -ne $btnUpdateDownloads) {
            $btnUpdateDownloads.IsEnabled = $true
        }
    }
}

# Funktion zum Befüllen der Dropdown-Liste
function Initialize-DownloadsComboBox {
    try {
        $downloads = Get-DATEVDownloads
        $cmbDirectDownloads.Items.Clear()
        
        # Platzhalter-Element hinzufügen
        $placeholderItem = New-Object System.Windows.Controls.ComboBoxItem
        $placeholderItem.Content = "Download auswählen..."
        $placeholderItem.IsEnabled = $false
        $placeholderItem.Foreground = "Gray"
        $cmbDirectDownloads.Items.Add($placeholderItem) | Out-Null
        
        foreach ($download in $downloads) {
            $item = New-Object System.Windows.Controls.ComboBoxItem
            $item.Content = $download.name
            $item.Tag = @{
                url         = $download.url
                description = $download.description
            }
            $cmbDirectDownloads.Items.Add($item) | Out-Null
        }
        
        # Platzhalter als Standardauswahl setzen
        $cmbDirectDownloads.SelectedIndex = 0
        
        if ($cmbDirectDownloads.Items.Count -gt 1) {
            Write-Log -Message "$($cmbDirectDownloads.Items.Count - 1) Downloads geladen" -Level 'INFO'
        }
    }
    catch {
        Write-Log -Message "Fehler beim Initialisieren der Downloads-Liste: $($_.Exception.Message)" -Level 'ERROR'
    }
}

# Funktion zum Herunterladen einer Datei im Hintergrund
function Start-BackgroundDownload {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][string]$FileName
    )
    
    try {
        # Download-Ordner erstellen
        $downloadFolder = Join-Path ([Environment]::GetFolderPath("UserProfile")) "Downloads\DATEV-Toolbox"
        if (-not (Test-Path $downloadFolder)) {
            New-Item -Path $downloadFolder -ItemType Directory -Force | Out-Null
            Write-Log -Message "Download-Ordner erstellt: $downloadFolder" -Level 'INFO'
        }
        
        $filePath = Join-Path $downloadFolder $FileName
        
        # Prüfen ob Datei bereits existiert
        if (Test-Path $filePath) {
            $result = [System.Windows.MessageBox]::Show(
                "Die Datei '$FileName' existiert bereits im Download-Ordner.`n`nMöchten Sie die Datei überschreiben?", 
                "Datei bereits vorhanden", 
                [System.Windows.MessageBoxButton]::YesNo, 
                [System.Windows.MessageBoxImage]::Question
            )
            
            if ($result -eq [System.Windows.MessageBoxResult]::No) {
                Write-Log -Message "Download abgebrochen - Datei existiert bereits: $FileName" -Level 'INFO'
                return
            }
            else {
                Write-Log -Message "Datei wird überschrieben: $FileName" -Level 'INFO'
            }
        }
        
        # Download-Button während Download deaktivieren
        $btnDownload.IsEnabled = $false
        Write-Log -Message "Download gestartet: $FileName" -Level 'INFO'
        
        # TLS 1.2 für sichere Downloads erzwingen
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        
        # WebClient für Download erstellen
        $webClient = New-Object System.Net.WebClient
        
        # Event-Handler für Download-Completion
        $webClient.add_DownloadFileCompleted({
                param($s, $e)
                # Dateiname aus UserState oder aus der lokalen Variable extrahieren
                $currentFileName = if ($e.UserState) { $e.UserState } else { $FileName }
            
                if ($null -eq $e.Error -and -not $e.Cancelled) {
                    Write-Log -Message "Download erfolgreich abgeschlossen: $currentFileName" -Level 'INFO'
                }
                else {
                    Write-Log -Message "Download fehlgeschlagen: $($e.Error.Message)" -Level 'ERROR'
                }
            
                # UI zurücksetzen
                $btnDownload.IsEnabled = $true
            
                # WebClient sicher entsorgen
                try {
                    if ($null -ne $s -and $s -is [System.Net.WebClient]) {
                        $s.Dispose()
                    }
                }
                catch {
                    Write-Log -Message "Fehler beim Entsorgen des WebClients: $($_.Exception.Message)" -Level 'WARN'
                }
            })
        
        # Asynchronen Download starten mit Dateiname als UserState
        $webClient.DownloadFileAsync($Url, $filePath, $FileName)
        
    }
    catch {
        Write-Log -Message "Fehler beim Starten des Downloads: $($_.Exception.Message)" -Level 'ERROR'
        $btnDownload.IsEnabled = $true
    }
}
#endregion

#region Download-Ordner-Funktionen
# Funktion zum Öffnen des Download-Ordners im Explorer
function Open-DownloadFolder {
    try {
        $downloadFolder = Join-Path ([Environment]::GetFolderPath("UserProfile")) "Downloads\DATEV-Toolbox"
        
        # Ordner erstellen falls er nicht existiert
        if (-not (Test-Path $downloadFolder)) {
            New-Item -Path $downloadFolder -ItemType Directory -Force | Out-Null
            Write-Log -Message "Download-Ordner erstellt: $downloadFolder" -Level 'INFO'
        }
        
        # Ordner im Explorer öffnen
        Start-Process explorer.exe $downloadFolder
        Write-Log -Message "Download-Ordner im Explorer geöffnet: $downloadFolder" -Level 'INFO'
    }
    catch {
        Write-Log -Message "Fehler beim Öffnen des Download-Ordners: $($_.Exception.Message)" -Level 'ERROR'
    }
}
#endregion

#region Update-Termine-Funktionen
# Funktion zum Anzeigen der nächsten DATEV Update-Termine aus ICS-Datei
function Show-NextUpdateDates {
    Write-Log -Message "Lese Update-Termine aus ICS-Datei..." -Level 'INFO'
    $icsFile = Join-Path (Join-Path $env:APPDATA 'DATEV-Toolbox 2.0') 'Jahresplanung_2025.ics'
    
    if ($null -eq $spUpdateDates) {
        Write-Log -Message "Update-Termine Container nicht gefunden" -Level 'WARN'
        return
    }
    
    $spUpdateDates.Children.Clear()
    
    if (-not (Test-Path $icsFile)) {
        Write-Log -Message "Keine lokale ICS-Datei gefunden: $icsFile" -Level 'WARN'
        $tb = New-Object System.Windows.Controls.TextBlock
        $tb.Text = "Keine lokale ICS-Datei gefunden. Bitte erst aktualisieren."
        $tb.FontStyle = 'Italic'
        $tb.Foreground = 'Red'
        $spUpdateDates.Children.Add($tb) | Out-Null
        return
    }
    
    try {
        $icsContent = Get-Content $icsFile -Raw -Encoding UTF8
        $lines = $icsContent -split "`n"
        $events = @()
        $currentEvent = @{}
        $lastKey = $null
        
        foreach ($lineRaw in $lines) {
            $line = $lineRaw.TrimEnd("`r", "`n")
            if ($line -eq "BEGIN:VEVENT") { 
                $currentEvent = @{}
                $lastKey = $null 
            }
            elseif ($line -eq "END:VEVENT") {
                if ($currentEvent.DTSTART -and $currentEvent.SUMMARY) {
                    $events += [PSCustomObject]@{
                        DTSTART     = $currentEvent.DTSTART
                        SUMMARY     = $currentEvent.SUMMARY
                        DESCRIPTION = $currentEvent.DESCRIPTION
                    }
                }
                $currentEvent = @{}
                $lastKey = $null
            }
            elseif ($line -match "^([A-Z]+).*:(.*)$") {
                $key = $matches[1]
                $val = $matches[2]
                $lastKey = $key
                if ($key -eq "DTSTART") { $currentEvent.DTSTART = $val }
                elseif ($key -eq "SUMMARY") { $currentEvent.SUMMARY = $val }
                elseif ($key -eq "DESCRIPTION") { $currentEvent.DESCRIPTION = $val }
            }
            elseif ($line -match "^[ \t](.*)$" -and $lastKey) {
                # Fortgesetzte Zeile (folded line)
                $continued = $matches[1]
                if ($lastKey -eq "DESCRIPTION") {
                    $currentEvent.DESCRIPTION += [Environment]::NewLine + $continued
                }
                elseif ($lastKey -eq "SUMMARY") {
                    $currentEvent.SUMMARY += $continued
                }
            }
        }
        
        Write-Log -Message "ICS: $($events.Count) VEVENTs gefunden" -Level 'INFO'
        $now = Get-Date
        $upcoming = $events | Where-Object {
            $date = $_.DTSTART
            try {
                if ($date.Length -eq 8) { 
                    $parsedDate = [datetime]::ParseExact($date, 'yyyyMMdd', $null) 
                }
                elseif ($date.Length -ge 15) { 
                    $parsedDate = [datetime]::ParseExact($date.Substring(0, 8), 'yyyyMMdd', $null) 
                }
                else { 
                    $parsedDate = $null 
                }
                $parsedDate -and $parsedDate -ge $now.Date
            }
            catch {
                $false
            }
        } | Sort-Object {
            try {
                if ($_.DTSTART.Length -eq 8) { 
                    [datetime]::ParseExact($_.DTSTART, 'yyyyMMdd', $null) 
                }
                elseif ($_.DTSTART.Length -ge 15) { 
                    [datetime]::ParseExact($_.DTSTART.Substring(0, 8), 'yyyyMMdd', $null) 
                }
                else { 
                    $null 
                }
            }
            catch {
                $null
            }
        } | Select-Object -First 3
        
        Write-Log -Message "$($upcoming.Count) anstehende Termine werden angezeigt" -Level 'INFO'
        
        if ($upcoming.Count -eq 0) {
            Write-Log -Message "Keine anstehenden Termine gefunden" -Level 'INFO'
            $tb = New-Object System.Windows.Controls.TextBlock
            $tb.Text = "Keine anstehenden Termine gefunden."
            $tb.FontStyle = 'Italic'
            $tb.Foreground = 'Gray'
            $spUpdateDates.Children.Add($tb) | Out-Null
        }
        else {
            foreach ($ev in $upcoming) {
                $date = $ev.DTSTART
                try {
                    if ($date.Length -eq 8) { 
                        $parsedDate = [datetime]::ParseExact($date, 'yyyyMMdd', $null) 
                    }
                    elseif ($date.Length -ge 15) { 
                        $parsedDate = [datetime]::ParseExact($date.Substring(0, 8), 'yyyyMMdd', $null) 
                    }
                    else { 
                        $parsedDate = $null 
                    }
                    
                    if ($parsedDate) {
                        $tb = New-Object System.Windows.Controls.TextBlock
                        $tb.Text = "{0:dd.MM.yyyy} - {1}" -f $parsedDate, $ev.SUMMARY
                        if ($ev.DESCRIPTION) { 
                            $tb.ToolTip = $ev.DESCRIPTION 
                        }
                        $tb.FontSize = 12
                        $tb.Margin = '2'
                        $spUpdateDates.Children.Add($tb) | Out-Null
                        Write-Log -Message "Termin: $($parsedDate.ToString('dd.MM.yyyy')) - $($ev.SUMMARY)" -Level 'INFO'
                    }
                }
                catch {
                    Write-Log -Message "Fehler beim Parsen des Datums: $date" -Level 'WARN'
                }
            }
        }
    }
    catch {
        Write-Log -Message "Fehler beim Laden oder Parsen der ICS-Datei: $($_.Exception.Message)" -Level 'ERROR'
        $tb = New-Object System.Windows.Controls.TextBlock
        $tb.Text = "Fehler beim Laden der Termine."
        $tb.FontStyle = 'Italic'
        $tb.Foreground = 'Red'
        $spUpdateDates.Children.Add($tb) | Out-Null
    }
}

# Funktion zum automatischen Laden der Update-Termine beim Start (falls .ics-Datei vorhanden)
function Initialize-UpdateDates {
    $icsFile = Join-Path (Join-Path $env:APPDATA 'DATEV-Toolbox 2.0') 'Jahresplanung_2025.ics'
    
    if (Test-Path $icsFile) {
        Write-Log -Message "Vorhandene ICS-Datei gefunden. Lade Update-Termine automatisch..." -Level 'INFO'
        Show-NextUpdateDates
    }
    else {
        Write-Log -Message "Keine lokale ICS-Datei gefunden. Update-Termine können manuell aktualisiert werden." -Level 'INFO'
        if ($null -ne $spUpdateDates) {
            $spUpdateDates.Children.Clear()
            $tb = New-Object System.Windows.Controls.TextBlock
            $tb.Text = "Klicken Sie auf 'Update-Termine aktualisieren'."
            $tb.FontStyle = 'Italic'
            $tb.Foreground = 'Gray'
            $spUpdateDates.Children.Add($tb) | Out-Null
        }
    }
}

# Funktion zum Laden der ICS-Datei von DATEV
function Update-UpdateDates {
    $icsUrl = "https://apps.datev.de/myupdates/assets/files/Jahresplanung_2025.ics"
    $icsFile = Join-Path (Join-Path $env:APPDATA 'DATEV-Toolbox 2.0') 'Jahresplanung_2025.ics'
    
    if ($null -eq $spUpdateDates) {
        Write-Log -Message "Update-Termine Container nicht gefunden" -Level 'WARN'
        return
    }
    
    $spUpdateDates.Children.Clear()
    $tb = New-Object System.Windows.Controls.TextBlock
    $tb.Text = "Lade ICS-Datei..."
    $tb.FontStyle = 'Italic'
    $tb.Foreground = 'Blue'
    $spUpdateDates.Children.Add($tb) | Out-Null
    
    Write-Log -Message "Benutzeraktion: Update-Termine aktualisieren geklickt. Lade ICS von $icsUrl" -Level 'INFO'
    
    try {
        # TLS 1.2 für sichere Downloads erzwingen
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        
        Invoke-WebRequest -Uri $icsUrl -OutFile $icsFile -UseBasicParsing -TimeoutSec 15
        
        $spUpdateDates.Children.Clear()
        $tb = New-Object System.Windows.Controls.TextBlock
        $tb.Text = "ICS-Datei geladen. Lese Termine..."
        $tb.FontStyle = 'Italic'
        $tb.Foreground = 'Blue'
        $spUpdateDates.Children.Add($tb) | Out-Null
        
        Write-Log -Message "ICS-Datei erfolgreich geladen: $icsFile" -Level 'INFO'
        Show-NextUpdateDates
    }
    catch {
        $spUpdateDates.Children.Clear()
        $tb = New-Object System.Windows.Controls.TextBlock
        $tb.Text = "Fehler beim Laden der ICS-Datei."
        $tb.FontStyle = 'Italic'
        $tb.Foreground = 'Red'
        $spUpdateDates.Children.Add($tb) | Out-Null
        Write-Log -Message "Fehler beim Laden der ICS-Datei: $($_.Exception.Message)" -Level 'ERROR'
    }
}
#endregion

#region Fenster anzeigen
# Funktion zum Öffnen von URLs im Standard-Browser
function Open-Url {
    param([string]$Url)
    try {
        Start-Process $Url
        Write-Log -Message "URL geöffnet: $Url" -Level 'INFO'
    }
    catch {
        Write-Log -Message "Fehler beim Öffnen der URL $Url`: $($_.Exception.Message)" -Level 'ERROR'
    }
}

# Event-Handler für DATEV Online Buttons
# Hilfe und Support
$btnHilfeCenter = $window.FindName("btnHilfeCenter")
if ($null -ne $btnHilfeCenter) {
    $btnHilfeCenter.Add_Click({ Open-Url -Url "https://apps.datev.de/help-center/" })
}

$btnServicekontakte = $window.FindName("btnServicekontakte")
if ($null -ne $btnServicekontakte) {
    $btnServicekontakte.Add_Click({ Open-Url -Url "https://apps.datev.de/servicekontakt-online/contacts" })
}

$btnMyUpdates = $window.FindName("btnMyUpdates")
if ($null -ne $btnMyUpdates) {
    $btnMyUpdates.Add_Click({ Open-Url -Url "https://apps.datev.de/myupdates/home" })
}

# Cloud
$btnMyDATEV = $window.FindName("btnMyDATEV")
if ($null -ne $btnMyDATEV) {
    $btnMyDATEV.Add_Click({ Open-Url -Url "https://apps.datev.de/mydatev" })
}

$btnDUO = $window.FindName("btnDUO")
if ($null -ne $btnDUO) {
    $btnDUO.Add_Click({ Open-Url -Url "https://duo.datev.de/" })
}

$btnLAO = $window.FindName("btnLAO")
if ($null -ne $btnLAO) {
    $btnLAO.Add_Click({ Open-Url -Url "https://apps.datev.de/lao" })
}

$btnLizenzverwaltung = $window.FindName("btnLizenzverwaltung")
if ($null -ne $btnLizenzverwaltung) {
    $btnLizenzverwaltung.Add_Click({ Open-Url -Url "https://apps.datev.de/lizenzverwaltung" })
}

$btnRechteraum = $window.FindName("btnRechteraum")
if ($null -ne $btnRechteraum) {
    $btnRechteraum.Add_Click({ Open-Url -Url "https://apps.datev.de/rechteraum" })
}

$btnRVO = $window.FindName("btnRVO")
if ($null -ne $btnRVO) {
    $btnRVO.Add_Click({ Open-Url -Url "https://apps.datev.de/rvo-administration" })
}

# Verwaltung und Technik
$btnSmartLogin = $window.FindName("btnSmartLogin")
if ($null -ne $btnSmartLogin) {
    $btnSmartLogin.Add_Click({ Open-Url -Url "https://go.datev.de/smartlogin-administration" })
}

$btnBestandsmanagement = $window.FindName("btnBestandsmanagement")
if ($null -ne $btnBestandsmanagement) {
    $btnBestandsmanagement.Add_Click({ Open-Url -Url "https://apps.datev.de/mydata/" })
}

$btnWeitereApps = $window.FindName("btnWeitereApps")
if ($null -ne $btnWeitereApps) {
    $btnWeitereApps.Add_Click({ Open-Url -Url "https://www.datev.de/web/de/mydatev/datev-cloud-anwendungen/" })
}

# Referenz auf den Button zum Öffnen des Ordners holen (vor ShowDialog!)
$btnOpenFolder = $window.FindName("btnOpenFolder")
if ($null -ne $btnOpenFolder) {
    $btnOpenFolder.Add_Click({
            try {
                $folder = Join-Path $env:APPDATA 'DATEV-Toolbox 2.0'
                if (-not (Test-Path $folder)) {
                    New-Item -Path $folder -ItemType Directory -Force | Out-Null
                }
                Start-Process explorer.exe $folder
                Write-Log -Message "Ordner im Explorer geöffnet: $folder" -Level 'INFO'
            }
            catch {
                Write-Log -Message "Fehler beim Öffnen des Ordners: $($_.Exception.Message)" -Level 'ERROR'
            }
        })
}
else {
    Write-Log -Message "Button 'btnOpenFolder' konnte nicht gefunden werden" -Level 'WARN'
}

# Event-Handler für Update-Check-Button
$btnCheckUpdate = $window.FindName("btnCheckUpdate")
if ($null -ne $btnCheckUpdate) {
    $btnCheckUpdate.Add_Click({
            Start-ManualUpdateCheck
        })
}
else {
    Write-Log -Message "Button 'btnCheckUpdate' konnte nicht gefunden werden" -Level 'WARN'
}

# Event-Handler für Update-Termine-Button (TextBlock)
if ($null -ne $btnUpdateDates) {
    $btnUpdateDates.Add_MouseLeftButtonDown({
            Update-UpdateDates
        })
}
else {
    Write-Log -Message "TextBlock 'btnUpdateDates' konnte nicht gefunden werden" -Level 'WARN'
}

# Event-Handler für DATEV Downloads ComboBox
if ($null -ne $cmbDirectDownloads) {
    $cmbDirectDownloads.Add_SelectionChanged({
            if ($null -ne $cmbDirectDownloads.SelectedItem -and 
                $cmbDirectDownloads.SelectedIndex -gt 0 -and 
                $null -ne $cmbDirectDownloads.SelectedItem.Tag) {
                $btnDownload.IsEnabled = $true
                $selectedItem = $cmbDirectDownloads.SelectedItem
                Write-Log -Message "Download ausgewählt: $($selectedItem.Content)" -Level 'INFO'
            }
            else {
                $btnDownload.IsEnabled = $false
            }
        })
}
else {
    Write-Log -Message "ComboBox 'cmbDirectDownloads' konnte nicht gefunden werden" -Level 'WARN'
}

# Event-Handler für Download-Button
if ($null -ne $btnDownload) {
    $btnDownload.Add_Click({
            try {
                if ($null -ne $cmbDirectDownloads.SelectedItem -and 
                    $cmbDirectDownloads.SelectedIndex -gt 0 -and 
                    $null -ne $cmbDirectDownloads.SelectedItem.Tag) {
                    $selectedItem = $cmbDirectDownloads.SelectedItem
                    $downloadInfo = $selectedItem.Tag
                
                    # Dateiname aus URL extrahieren
                    $uri = [System.Uri]$downloadInfo.url
                    $fileName = Split-Path $uri.LocalPath -Leaf
                    if ([string]::IsNullOrEmpty($fileName)) {
                        $fileName = "download_$(Get-Date -Format 'yyyyMMdd_HHmmss').exe"
                    }
                
                    Start-BackgroundDownload -Url $downloadInfo.url -FileName $fileName
                }
            }
            catch {
                Write-Log -Message "Fehler beim Starten des Downloads: $($_.Exception.Message)" -Level 'ERROR'
            }
        })
}
else {
    Write-Log -Message "Button 'btnDownload' konnte nicht gefunden werden" -Level 'WARN'
}

# Event-Handler für Update-Downloads-Button (TextBlock)
if ($null -ne $btnUpdateDownloads) {
    $btnUpdateDownloads.Add_MouseLeftButtonDown({
            Update-DATEVDownloads
        })
}
else {
    Write-Log -Message "TextBlock 'btnUpdateDownloads' konnte nicht gefunden werden" -Level 'WARN'
}

# Event-Handler für Download-Ordner-Icon (TextBlock)
if ($null -ne $btnOpenDownloadFolder) {
    $btnOpenDownloadFolder.Add_MouseLeftButtonDown({
            Open-DownloadFolder
        })
}
else {
    Write-Log -Message "TextBlock 'btnOpenDownloadFolder' konnte nicht gefunden werden" -Level 'WARN'
}

# Event-Handler für DATEV Online Downloads Buttons
if ($null -ne $btnDATEVDownloadbereich) {
    $btnDATEVDownloadbereich.Add_Click({
        Open-Url -Url "https://www.datev.de/download/"
    })
}

if ($null -ne $btnDATEVSmartDocs) {
    $btnDATEVSmartDocs.Add_Click({
        Open-Url -Url "https://www.datev.de/web/de/service-und-support/software-bereitstellung/download-bereich/it-loesungen-und-security/datev-smartdocs-skripte-zur-analyse-oder-reparatur/"
    })
}

if ($null -ne $btnDatentraegerPortal) {
    $btnDatentraegerPortal.Add_Click({
        Open-Url -Url "https://www.datev.de/web/de/service-und-support/software-bereitstellung/datentraeger-portal/"
    })
}

# Downloads-ComboBox initialisieren
Initialize-DownloadsComboBox

# Update-Termine beim Start laden (falls vorhanden)
Initialize-UpdateDates

# Automatischen Update-Check durchführen
Initialize-UpdateCheck

# Event-Handler für DATEV Programme Buttons
if ($null -ne $btnDATEVArbeitsplatz) {
    $btnDATEVArbeitsplatz.Add_Click({
        Start-DATEVProgram -ProgramName 'DATEVArbeitsplatz' -PossiblePaths $script:DATEVProgramPaths['DATEVArbeitsplatz'] -Description 'DATEV-Arbeitsplatz'
    })
}

if ($null -ne $btnInstallationsmanager) {
    $btnInstallationsmanager.Add_Click({
        Start-DATEVProgram -ProgramName 'Installationsmanager' -PossiblePaths $script:DATEVProgramPaths['Installationsmanager'] -Description 'Installationsmanager'
    })
}

if ($null -ne $btnServicetool) {
    $btnServicetool.Add_Click({
        Start-DATEVProgram -ProgramName 'Servicetool' -PossiblePaths $script:DATEVProgramPaths['Servicetool'] -Description 'Servicetool'
    })
}

# Event-Handler für DATEV Tools Buttons
if ($null -ne $btnKonfigDBTools) {
    $btnKonfigDBTools.Add_Click({
        Start-DATEVProgram -ProgramName 'KonfigDBTools' -PossiblePaths $script:DATEVProgramPaths['KonfigDBTools'] -Description 'KonfigDB-Tools'
    })
}

if ($null -ne $btnEODBconfig) {
    $btnEODBconfig.Add_Click({
        Start-DATEVProgram -ProgramName 'EODBconfig' -PossiblePaths $script:DATEVProgramPaths['EODBconfig'] -Description 'EODBconfig'
    })
}

if ($null -ne $btnEOAufgabenplanung) {
    $btnEOAufgabenplanung.Add_Click({
        Start-DATEVProgram -ProgramName 'EOAufgabenplanung' -PossiblePaths $script:DATEVProgramPaths['EOAufgabenplanung'] -Description 'EO Aufgabenplanung'
    })
}

# Event-Handler für DATEV Performance Tools Button
if ($null -ne $btnNGENALL40) {
    $btnNGENALL40.Add_Click({
        Start-DATEVProgram -ProgramName 'NGENALL40' -PossiblePaths $script:DATEVProgramPaths['NGENALL40'] -Description 'NGENALL 4.0'
    })
}

if ($null -ne $btnLeistungsindex) {
    $btnLeistungsindex.Add_Click({
        Start-Leistungsindex
    })
}

# Event-Handler für System Tools Buttons
if ($null -ne $btnTaskManager) {
    $btnTaskManager.Add_Click({
        Start-SystemTool -Command 'taskmgr.exe' -Description 'Task-Manager'
    })
}

if ($null -ne $btnResourceMonitor) {
    $btnResourceMonitor.Add_Click({
        Start-SystemTool -Command 'resmon.exe' -Description 'Ressourcenmonitor'
    })
}

if ($null -ne $btnEventViewer) {
    $btnEventViewer.Add_Click({
        Start-SystemTool -Command 'eventvwr.msc' -Description 'Ereignisanzeige'
    })
}

if ($null -ne $btnServices) {
    $btnServices.Add_Click({
        Start-SystemTool -Command 'services.msc' -Description 'Dienste'
    })
}

if ($null -ne $btnMsconfig) {
    $btnMsconfig.Add_Click({
        Start-SystemTool -Command 'msconfig.exe' -Description 'Systemkonfiguration'
    })
}

if ($null -ne $btnDiskCleanup) {
    $btnDiskCleanup.Add_Click({
        Start-SystemTool -Command 'cleanmgr.exe' -Description 'Datenträgerbereinigung'
    })
}

# Startup-Log schreiben
Write-Log -Message "DATEV-Toolbox 2.0 gestartet" -Level 'INFO'

# GUI anzeigen und auf Benutzerinteraktion warten
$window.ShowDialog() | Out-Null
#endregion

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

#region Initialisierung und GUI
# Benötigte .NET-Assembly für WPF-GUI laden
Add-Type -AssemblyName PresentationFramework

# XAML-Definition für das Hauptfenster mit Tabs und Log-Bereich
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="DATEV-Toolbox 2.0" Height="550" Width="400">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="100"/>
        </Grid.RowDefinitions>
        <TabControl Grid.Row="0" Margin="10,10,10,0">
            <TabItem Header="DATEV Tools">
                <Grid>

                </Grid>
            </TabItem>            <TabItem Header="DATEV Cloud">
                <Grid>                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    <Label Grid.Row="0" Content="Direkt Downloads" FontWeight="Bold" Margin="10,10,10,5"/>
                    <ComboBox Name="cmbDirectDownloads" Grid.Row="1" Margin="10,0,10,10" Height="25"/>
                    <Button Name="btnDownload" Grid.Row="2" Content="Download starten" Height="30" 
                            VerticalAlignment="Top" Margin="10,0,10,10" IsEnabled="False"/>
                </Grid>
            </TabItem>
            <TabItem Header="Einstellungen">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>
                    <Button Name="btnOpenFolder" Content="Einstellungen öffnen" Height="30"
                            Grid.Column="0" HorizontalAlignment="Stretch" VerticalAlignment="Top" Margin="10,10,10,0"/>
                    <!-- Hier können zukünftig Einstellungen ergänzt werden -->
                </Grid>
            </TabItem>
        </TabControl>
        <TextBox Name="txtLog" Grid.Row="1" Margin="10,5,10,10" 
                 VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto"
                 IsReadOnly="True" TextWrapping="Wrap"/>
    </Grid>
</Window>
"@

# XAML parsen und Fenster-Objekt erzeugen mit Fehlerbehandlung
try {
    $reader = New-Object System.Xml.XmlNodeReader $xaml
    $window = [Windows.Markup.XamlReader]::Load($reader)
} catch {
    Write-Error "Fehler beim Laden der GUI: $($_.Exception.Message)"
    exit 1
}

# Referenz auf das Log-Textfeld holen
$txtLog = $window.FindName("txtLog")

# Referenzen auf DATEV Cloud Elemente holen
$cmbDirectDownloads = $window.FindName("cmbDirectDownloads")
$btnDownload = $window.FindName("btnDownload")
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
    } catch {
        # Fallback wenn Logging fehlschlägt
        Write-Host "LOGGING-FEHLER: $($_.Exception.Message)" -ForegroundColor Red
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
    } catch {
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
        } else {
            Write-Log -Message "Keine Einstellungsdatei gefunden, verwende Standardwerte" -Level 'INFO'
            return @{}
        }
    } catch {
        Write-Log -Message "Fehler beim Laden der Einstellungen: $($_.Exception.Message)" -Level 'ERROR'        return @{}
    }
}
#endregion

#region DATEV Downloads-Funktion
# Funktion zum Laden der DATEV Downloads aus datev-downloads.json
function Get-DATEVDownloads {
    try {
        $downloadsFile = Join-Path $PSScriptRoot 'datev-downloads.json'
        if (Test-Path $downloadsFile) {
            $json = Get-Content -Path $downloadsFile -Raw -Encoding UTF8
            $downloadsData = $json | ConvertFrom-Json
            Write-Log -Message "DATEV Downloads erfolgreich geladen" -Level 'INFO'
            return $downloadsData.downloads
        } else {
            Write-Log -Message "Datei 'datev-downloads.json' nicht gefunden" -Level 'WARN'
            return @()
        }
    } catch {
        Write-Log -Message "Fehler beim Laden der DATEV Downloads: $($_.Exception.Message)" -Level 'ERROR'
        return @()
    }
}

# Funktion zum Befüllen der Dropdown-Liste
function Initialize-DownloadsComboBox {
    try {
        $downloads = Get-DATEVDownloads
        $cmbDirectDownloads.Items.Clear()
        
        foreach ($download in $downloads) {
            $item = New-Object System.Windows.Controls.ComboBoxItem
            $item.Content = $download.name
            $item.Tag = @{
                url = $download.url
                description = $download.description
            }
            $cmbDirectDownloads.Items.Add($item) | Out-Null
        }
        
        if ($cmbDirectDownloads.Items.Count -gt 0) {
            Write-Log -Message "$($cmbDirectDownloads.Items.Count) Downloads geladen" -Level 'INFO'
        }    } catch {
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
            } else {
                Write-Log -Message "Datei wird überschrieben: $FileName" -Level 'INFO'
            }
        }
        
        # Download-Button während Download deaktivieren
        $btnDownload.IsEnabled = $false
        
        Write-Log -Message "Download gestartet: $FileName" -Level 'INFO'
          # WebClient für Download erstellen
        $webClient = New-Object System.Net.WebClient
        
        # Event-Handler für Download-Completion
        $webClient.add_DownloadFileCompleted({
            param($s, $e)
            # Dateiname aus UserState oder aus der lokalen Variable extrahieren
            $currentFileName = if ($e.UserState) { $e.UserState } else { $FileName }
            
            if ($null -eq $e.Error -and -not $e.Cancelled) {
                Write-Log -Message "Download erfolgreich abgeschlossen: $currentFileName" -Level 'INFO'
            } else {
                Write-Log -Message "Download fehlgeschlagen: $($e.Error.Message)" -Level 'ERROR'
            }
            
            # UI zurücksetzen
            $btnDownload.IsEnabled = $true
            
            # WebClient sicher entsorgen
            try {
                if ($null -ne $s -and $s -is [System.Net.WebClient]) {
                    $s.Dispose()
                }
            } catch {
                Write-Log -Message "Fehler beim Entsorgen des WebClients: $($_.Exception.Message)" -Level 'WARN'
            }
        })
        
        # Asynchronen Download starten mit Dateiname als UserState
        $webClient.DownloadFileAsync($Url, $filePath, $FileName)
        
    } catch {
        Write-Log -Message "Fehler beim Starten des Downloads: $($_.Exception.Message)" -Level 'ERROR'
        $btnDownload.IsEnabled = $true
    }
}
#endregion

#region Fenster anzeigen
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
        } catch {
            Write-Log -Message "Fehler beim Öffnen des Ordners: $($_.Exception.Message)" -Level 'ERROR'
        }
    })
} else {
    Write-Log -Message "Button 'btnOpenFolder' konnte nicht gefunden werden" -Level 'WARN'
}

# Event-Handler für DATEV Downloads ComboBox
if ($null -ne $cmbDirectDownloads) {
    $cmbDirectDownloads.Add_SelectionChanged({
        if ($cmbDirectDownloads.SelectedItem -ne $null) {
            $btnDownload.IsEnabled = $true
            $selectedItem = $cmbDirectDownloads.SelectedItem
            Write-Log -Message "Download ausgewählt: $($selectedItem.Content)" -Level 'INFO'
        } else {
            $btnDownload.IsEnabled = $false
        }
    })
} else {
    Write-Log -Message "ComboBox 'cmbDirectDownloads' konnte nicht gefunden werden" -Level 'WARN'
}

# Event-Handler für Download-Button
if ($null -ne $btnDownload) {
    $btnDownload.Add_Click({
        try {
            if ($cmbDirectDownloads.SelectedItem -ne $null) {
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
        } catch {
            Write-Log -Message "Fehler beim Starten des Downloads: $($_.Exception.Message)" -Level 'ERROR'
        }
    })
} else {
    Write-Log -Message "Button 'btnDownload' konnte nicht gefunden werden" -Level 'WARN'
}

# Downloads-ComboBox initialisieren
Initialize-DownloadsComboBox

# Startup-Log schreiben
Write-Log -Message "DATEV-Toolbox 2.0 gestartet" -Level 'INFO'

# GUI anzeigen und auf Benutzerinteraktion warten
$window.ShowDialog() | Out-Null
#endregion

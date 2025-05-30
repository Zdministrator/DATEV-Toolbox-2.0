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
        Title="DATEV-Toolbox 2.0" Height="550" Width="400">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="100"/>
        </Grid.RowDefinitions>        <TabControl Grid.Row="0" Margin="10,10,10,0">            <TabItem Header="DATEV Tools">
                <ScrollViewer VerticalScrollBarVisibility="Auto">
                    <StackPanel Orientation="Vertical" Margin="10">
                        <!-- Hier können zukünftige DATEV Tools hinzugefügt werden -->
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
                                <Button Name="btnHilfeCenter" Content="DATEV Hilfe Center" Height="30" Margin="0,3,0,3"/>
                                <Button Name="btnServicekontakte" Content="Servicekontakte" Height="30" Margin="0,3,0,3"/>
                                <Button Name="btnMyUpdates" Content="DATEV myUpdates" Height="30" Margin="0,3,0,3"/>
                            </StackPanel>
                        </GroupBox>
                        
                        <!-- Cloud -->
                        <GroupBox Margin="5,5,5,10">
                            <GroupBox.Header>
                                <TextBlock Text="Cloud" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>
                            <StackPanel Orientation="Vertical" Margin="10">
                                <Button Name="btnMyDATEV" Content="myDATEV Portal" Height="30" Margin="0,3,0,3"/>
                                <Button Name="btnDUO" Content="DATEV Unternehmen Online" Height="30" Margin="0,3,0,3"/>
                                <Button Name="btnLAO" Content="Logistikauftrag Online" Height="30" Margin="0,3,0,3"/>
                                <Button Name="btnLizenzverwaltung" Content="Lizenzverwaltung Online" Height="30" Margin="0,3,0,3"/>
                                <Button Name="btnRechteraum" Content="DATEV Rechteraum Online" Height="30" Margin="0,3,0,3"/>
                                <Button Name="btnRVO" Content="DATEV Rechteverwaltung Online" Height="30" Margin="0,3,0,3"/>
                            </StackPanel>
                        </GroupBox>
                        
                        <!-- Verwaltung und Technik -->
                        <GroupBox Margin="5,5,5,10">
                            <GroupBox.Header>
                                <TextBlock Text="Verwaltung und Technik" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>
                            <StackPanel Orientation="Vertical" Margin="10">
                                <Button Name="btnSmartLogin" Content="SmartLogin Administration" Height="30" Margin="0,3,0,3"/>
                                <Button Name="btnBestandsmanagement" Content="myDATEV Bestandsmanagement" Height="30" Margin="0,3,0,3"/>
                                <Button Name="btnWeitereApps" Content="Weitere Cloud Anwendungen" Height="30" Margin="0,3,0,3"/>
                            </StackPanel>
                        </GroupBox>
                    </StackPanel>
                </ScrollViewer>
            </TabItem>
            <TabItem Header="Downloads">
                <Grid>
                    <GroupBox Margin="10">
                        <GroupBox.Header>
                            <TextBlock Text="Direkt Downloads" FontWeight="Bold" FontSize="12"/>
                        </GroupBox.Header>                        <Grid Margin="10">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="*"/>
                            </Grid.RowDefinitions>
                            <Button Name="btnUpdateDownloads" Grid.Row="0" Content="Direkt-Downloads aktualisieren" Height="20" 
                                    Margin="0,0,0,10"/>
                            <ComboBox Name="cmbDirectDownloads" Grid.Row="1" Margin="0,0,0,10" Height="25"/>
                            <Button Name="btnDownload" Grid.Row="2" Content="Download starten" Height="30" 
                                    VerticalAlignment="Top" Margin="0,0,0,0" IsEnabled="False"/>
                        </Grid>
                    </GroupBox>
                </Grid>
            </TabItem>            <TabItem Header="Einstellungen">
                <ScrollViewer VerticalScrollBarVisibility="Auto">
                    <StackPanel Orientation="Vertical" Margin="10">
                        <!-- Einstellungen -->
                        <GroupBox Margin="5,5,5,10">
                            <GroupBox.Header>
                                <TextBlock Text="Einstellungen" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>
                            <StackPanel Orientation="Vertical" Margin="10">
                                <Button Name="btnOpenFolder" Content="Einstellungen öffnen" Height="30" Margin="0,3,0,3"/>
                                <!-- Hier können zukünftig Einstellungen ergänzt werden -->
                            </StackPanel>
                        </GroupBox>
                        
                        <!-- Anstehende Update-Termine -->
                        <GroupBox Margin="5,5,5,10">
                            <GroupBox.Header>
                                <TextBlock Text="Anstehende Update-Termine" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>
                            <StackPanel Orientation="Vertical" Margin="10">
                                <Button Name="btnUpdateDates" Content="Update-Termine aktualisieren" Height="20" Margin="0,3,0,3"/>
                                <StackPanel Name="spUpdateDates" Orientation="Vertical" Margin="0,10,0,0">
                                    <TextBlock Text="Klicken Sie auf 'Update-Termine aktualisieren'." 
                                               FontStyle="Italic" Foreground="Gray"/>
                                </StackPanel>
                            </StackPanel>
                        </GroupBox>
                    </StackPanel>
                </ScrollViewer>
            </TabItem>
        </TabControl>
        <TextBox Name="txtLog" Grid.Row="1" Margin="10,5,10,10" 
                 VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto"
                 IsReadOnly="True" TextWrapping="Wrap" FontSize="10"/>
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

# Referenzen auf DATEV Tools Elemente holen
$spUpdateDates = $window.FindName("spUpdateDates")
$btnUpdateDates = $window.FindName("btnUpdateDates")
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

# Event-Handler für Update-Termine-Button
if ($null -ne $btnUpdateDates) {
    $btnUpdateDates.Add_Click({
            Update-UpdateDates
        })
}
else {
    Write-Log -Message "Button 'btnUpdateDates' konnte nicht gefunden werden" -Level 'WARN'
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

# Event-Handler für Update-Downloads-Button
if ($null -ne $btnUpdateDownloads) {
    $btnUpdateDownloads.Add_Click({
            Update-DATEVDownloads
        })
}
else {
    Write-Log -Message "Button 'btnUpdateDownloads' konnte nicht gefunden werden" -Level 'WARN'
}

# Downloads-ComboBox initialisieren
Initialize-DownloadsComboBox

# Startup-Log schreiben
Write-Log -Message "DATEV-Toolbox 2.0 gestartet" -Level 'INFO'

# GUI anzeigen und auf Benutzerinteraktion warten
$window.ShowDialog() | Out-Null
#endregion

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
    Version:        2.3.0
    Autor:          Norman Zamponi
    PowerShell:     5.1+ (kompatibel)
    .NET Framework: 4.5+ (für WPF)
    
.LINK
    https://github.com/Zdministrator/DATEV-Toolbox-2.0
#>

#Requires -Version 5.1

# DATEV-Toolbox 2.0

# Version und Update-Konfiguration
$script:AppVersion = "2.3.0"
$script:AppName = "DATEV-Toolbox 2.0"
$script:GitHubRepo = "Zdministrator/DATEV-Toolbox-2.0"
$script:UpdateCheckUrl = "https://github.com/$script:GitHubRepo/raw/main/version.json"
$script:ScriptDownloadUrl = "https://github.com/$script:GitHubRepo/raw/main/DATEV-Toolbox 2.0.ps1"

#region Zentrale Konfiguration
# DATEV-Pfad-Definitionen (müssen vor ButtonMappings definiert werden)
$script:DATEVProgramPaths = @{
    'DATEVArbeitsplatz'    = @(
        '%DATEVPP%\PROGRAMM\K0005000\Arbeitsplatz.exe'
    )
    'Installationsmanager' = @(
        '%DATEVPP%\PROGRAMM\INSTALL\DvInesInstMan.exe'
    )
    'Servicetool'          = @(
        '%DATEVPP%\PROGRAMM\SRVTOOL\Srvtool.exe'
    )
    'KonfigDBTools'        = @(
        '%DATEVPP%\PROGRAMM\B0001502\cdbtool.exe'
    )
    'EODBconfig'           = @(
        '%DATEVPP%\PROGRAMM\EODB\EODBConfig.exe'
    )
    'EOAufgabenplanung'    = @(
        '%DATEVPP%\PROGRAMM\I0000085\EOControl.exe'
    )
    'DvServerChange'       = @(
        '%DATEVPP%\PROGRAMM\B0001502\DvServerChange.exe'
    )
    'NGENALL40'            = @(
        '%DATEVPP%\Programm\B0001508\ngenall40.cmd'
    )
    'Leistungsindex'       = @(
        '%DATEVPP%\PROGRAMM\RWAPPLIC\irw.exe'
    )
}

# Alle URLs, Pfade und Konfigurationswerte zentral verwaltet
$script:Config = @{
    URLs           = @{
        GitHub = @{
            Repository      = "https://github.com/$script:GitHubRepo"
            VersionCheck    = $script:UpdateCheckUrl
            ScriptDownload  = $script:ScriptDownloadUrl
            DownloadsConfig = "https://github.com/$script:GitHubRepo/raw/refs/heads/main/datev-downloads.json"
        }
        DATEV  = @{
            # Online-Services
            HelpCenter           = "https://apps.datev.de/help-center/"
            ServiceKontakte      = "https://apps.datev.de/servicekontakt-online/contacts"
            MyUpdates            = "https://apps.datev.de/myupdates/home"
            Community            = "https://www.datev-community.de/"
            MyDATEV              = "https://apps.datev.de/mydatev"
            DUO                  = "https://duo.datev.de/"
            LAO                  = "https://apps.datev.de/lao"
            Lizenzverwaltung     = "https://apps.datev.de/lizenzverwaltung"
            Rechteraum           = "https://apps.datev.de/rechteraum"
            RVO                  = "https://apps.datev.de/rvo-administration"
            SmartLogin           = "https://go.datev.de/smartlogin-administration"
            Bestandsmanagement   = "https://apps.datev.de/mydata/"
            Vertragsuebersichten = "https://apps.datev.de/vertragsuebersichten-online"
            WeitereApps          = "https://www.datev.de/web/de/mydatev/datev-cloud-anwendungen/"
            
            # Download-Bereiche
            Downloadbereich      = "https://apps.datev.de/myupdates/download-v2/lists/products/"
            SmartDocs            = "https://www.datev.de/web/de/service-und-support/software-bereitstellung/download-bereich/it-loesungen-und-security/datev-smartdocs-skripte-zur-analyse-oder-reparatur/"
            DatentraegerPortal   = "https://www.datev.de/web/de/service-und-support/software-bereitstellung/datentraeger-portal/"
            
            # Update-Termine
            Jahresplanung        = "https://apps.datev.de/myupdates/assets/files/Jahresplanung_2025.ics"
        }
    }
    
    Timeouts       = @{
        UpdateCheck     = 10
        DownloadJSON    = 15
        FileDownload    = 30
        ICSDownload     = 15
        UpdateInterval  = 24  # Stunden
        GpupdateTimeout = 2  # Minuten
    }
    
    Downloads      = @{
        FSLogix = @{
            Url         = "https://aka.ms/fslogix-latest"
            FileName    = "FSLogix_Apps_Latest.zip"
            Description = "Microsoft FSLogix Apps - Profile Container, Office Container und weitere Tools für virtuelle Umgebungen"
        }
    }
    
    Paths          = @{
        AppData       = Join-Path $env:APPDATA 'DATEV-Toolbox 2.0'
        Downloads     = Join-Path $env:USERPROFILE "Downloads\DATEV-Toolbox"
        Updates       = Join-Path (Join-Path $env:APPDATA 'DATEV-Toolbox 2.0') 'Updates'
        SettingsFile  = Join-Path (Join-Path $env:APPDATA 'DATEV-Toolbox 2.0') 'settings.json'
        ErrorLog      = Join-Path (Join-Path $env:APPDATA 'DATEV-Toolbox 2.0') 'Error-Log.txt'
        DownloadsJSON = Join-Path (Join-Path $env:APPDATA 'DATEV-Toolbox 2.0') 'datev-downloads.json'
        ICSFile       = Join-Path (Join-Path $env:APPDATA 'DATEV-Toolbox 2.0') 'Jahresplanung_2025.ics'
    }
    
    Limits         = @{
        MaxBackups       = 5
        MinFileSize      = 1000  # Bytes für Download-Validierung
        MaxUpdateRetries = 3
    }
    
    SystemTools    = @{
        TaskManager     = @{ Command = 'taskmgr.exe'; Description = 'Task-Manager' }
        ResourceMonitor = @{ Command = 'resmon.exe'; Description = 'Ressourcenmonitor' }
        EventViewer     = @{ Command = 'eventvwr.msc'; Description = 'Ereignisanzeige' }
        Services        = @{ Command = 'services.msc'; Description = 'Dienste' }
        MSConfig        = @{ Command = 'msconfig.exe'; Description = 'Systemkonfiguration' }
        DiskCleanup     = @{ Command = 'cleanmgr.exe'; Description = 'Datenträgerbereinigung' }
        TaskScheduler   = @{ Command = 'taskschd.msc'; Description = 'Aufgabenplanung' }
        Gpupdate        = @{ Command = 'gpupdate.exe'; Arguments = '/force'; Description = 'Gruppenrichtlinien-Update' }
    }
    
    # Button-zu-Aktion-Mapping für vereinfachte Event-Handler-Registrierung
    ButtonMappings = @{
        # DATEV Online Services - Hilfe und Support (URL-Handler)
        'btnHilfeCenter'          = @{ Type = 'URL'; UrlKey = 'HelpCenter' }
        'btnServicekontakte'      = @{ Type = 'URL'; UrlKey = 'ServiceKontakte' }
        'btnMyUpdates'            = @{ Type = 'URL'; UrlKey = 'MyUpdates' }
        'btnCommunity'            = @{ Type = 'URL'; UrlKey = 'Community' }
        
        # DATEV Online Services - Cloud (URL-Handler)
        'btnMyDATEV'              = @{ Type = 'URL'; UrlKey = 'MyDATEV' }
        'btnDUO'                  = @{ Type = 'URL'; UrlKey = 'DUO' }
        'btnLAO'                  = @{ Type = 'URL'; UrlKey = 'LAO' }
        'btnLizenzverwaltung'     = @{ Type = 'URL'; UrlKey = 'Lizenzverwaltung' }
        'btnRechteraum'           = @{ Type = 'URL'; UrlKey = 'Rechteraum' }
        'btnRVO'                  = @{ Type = 'URL'; UrlKey = 'RVO' }
        'btnSmartLogin'           = @{ Type = 'URL'; UrlKey = 'SmartLogin' }
        'btnBestandsmanagement'   = @{ Type = 'URL'; UrlKey = 'Bestandsmanagement' }
        'btnVertragsuebersichten' = @{ Type = 'URL'; UrlKey = 'Vertragsuebersichten' }
        'btnWeitereApps'          = @{ Type = 'URL'; UrlKey = 'WeitereApps' }
        
        # DATEV Online Downloads (URL-Handler)
        'btnDATEVDownloadbereich' = @{ Type = 'URL'; UrlKey = 'Downloadbereich' }
        'btnDATEVSmartDocs'       = @{ Type = 'URL'; UrlKey = 'SmartDocs' }
        'btnDatentraegerPortal'   = @{ Type = 'URL'; UrlKey = 'DatentraegerPortal' }
        
        # Sonstige nützliche Downloads (Download-Handler)
        'btnFSLogix'              = @{ Type = 'Download'; DownloadKey = 'FSLogix' }
        
        # DATEV Programme (DATEV-Handler)
        'btnDATEVArbeitsplatz'    = @{ Type = 'DATEV'; ProgramName = 'DATEVArbeitsplatz'; Description = 'DATEV-Arbeitsplatz' }
        'btnInstallationsmanager' = @{ Type = 'DATEV'; ProgramName = 'Installationsmanager'; Description = 'Installationsmanager' }
        'btnServicetool'          = @{ Type = 'DATEV'; ProgramName = 'Servicetool'; Description = 'Servicetool' }
        'btnKonfigDBTools'        = @{ Type = 'DATEV'; ProgramName = 'KonfigDBTools'; Description = 'KonfigDB-Tools' }
        'btnEODBconfig'           = @{ Type = 'DATEV'; ProgramName = 'EODBconfig'; Description = 'EODBconfig' }
        'btnEOAufgabenplanung'    = @{ Type = 'DATEV'; ProgramName = 'EOAufgabenplanung'; Description = 'EO Aufgabenplanung' }
        'btnDvServerChange'       = @{ Type = 'DATEV'; ProgramName = 'DvServerChange'; Description = 'Server-Anpassungs-Assistent' }
        'btnNGENALL40'            = @{ Type = 'DATEV'; ProgramName = 'NGENALL40'; Description = 'NGENALL 4.0' }
        
        # System Tools (SystemTool-Handler)
        'btnTaskManager'          = @{ Type = 'SystemTool'; Command = 'taskmgr.exe'; Description = 'Task-Manager' }
        'btnResourceMonitor'      = @{ Type = 'SystemTool'; Command = 'resmon.exe'; Description = 'Ressourcenmonitor' }
        'btnEventViewer'          = @{ Type = 'SystemTool'; Command = 'eventvwr.msc'; Description = 'Ereignisanzeige' }
        'btnServices'             = @{ Type = 'SystemTool'; Command = 'services.msc'; Description = 'Dienste' }
        'btnMsconfig'             = @{ Type = 'SystemTool'; Command = 'msconfig.exe'; Description = 'Systemkonfiguration' }
        'btnDiskCleanup'          = @{ Type = 'SystemTool'; Command = 'cleanmgr.exe'; Description = 'Datenträgerbereinigung' }
        'btnTaskScheduler'        = @{ Type = 'SystemTool'; Command = 'taskschd.msc'; Description = 'Aufgabenplanung' }
        
        # Funktions-Handler (Function-Handler)
        'btnLeistungsindex'       = @{ Type = 'Function'; FunctionName = 'Start-Leistungsindex' }
        'btnGpupdate'             = @{ Type = 'Function'; FunctionName = 'Start-Gpupdate' }
        'btnWindowsUpdates'       = @{ Type = 'Function'; FunctionName = 'Start-WindowsUpdates' }
        
        # TextBlock-Handler (verwenden MouseLeftButtonDown statt Add_Click)
        'btnUpdateDownloads'      = @{ Type = 'TextBlock'; FunctionName = 'Update-DATEVDownloads' }
        'btnOpenDownloadFolder'   = @{ Type = 'TextBlock'; FunctionName = 'Open-DownloadFolder' }
        'btnUpdateDates'          = @{ Type = 'TextBlock'; FunctionName = 'Update-UpdateDates' }
        'btnRefreshDocuments'     = @{ Type = 'TextBlock'; FunctionName = 'Refresh-DocumentsList' }
        'txtEmailLink'            = @{ Type = 'Hyperlink'; FunctionName = 'Open-EmailClient' }
        
        # Einstellungs-Handler (jetzt auch zentral verwaltet)
        'btnCheckUpdate'          = @{ Type = 'Function'; FunctionName = 'Start-UpdateCheck' }
        'btnDownload'             = @{ Type = 'Function'; FunctionName = 'Start-DirectDownload' }
        'btnOpenFolder'           = @{ Type = 'Function'; FunctionName = 'Open-AppDataFolder' }
        'btnShowChangelog'        = @{ Type = 'Function'; FunctionName = 'Show-ChangelogDialog' }
    }
}
#endregion

#region Anwendungs-Initialisierung
# Administrator-Rechte-Prüfung und grundlegende Initialisierung
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

# Benötigte .NET-Assemblies für WPF-GUI und System-Tray laden
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
#endregion

#region Einstellungs-Management
# Benutzereinstellungen verwalten (Laden, Speichern, Zugriff)
$script:Settings = $null

# Performance-Optimierung: Cache-Variablen
$script:IsDebugEnabled = $false
$script:LogStringBuilder = New-Object System.Text.StringBuilder
$script:SettingsCache = @{}
$script:SettingsDirty = $false
$script:SettingsSaveTimer = $null
$script:CachedDATEVPaths = @{}
$script:PathCacheExpiry = @{}

# Event-Handler Memory Leak Prevention
$script:ComboBoxEventRegistered = $false
$script:ComboBoxHandler = $null

# Thread-Safety für Settings-Timer
$script:SettingsLock = New-Object System.Object

# Performance-Optimierung: Runspace-Pool für asynchrone Operationen
$script:RunspacePool = $null
$script:ActiveJobs = @{}

function Initialize-Settings {
    <#
    .SYNOPSIS
    Initialisiert die Benutzereinstellungen mit Performance-Caching
    #>
    try {
        $settingsPath = $script:Config.Paths.SettingsFile
        
        if (Test-Path $settingsPath) {
            Write-Log -Message "Lade Einstellungen von: $settingsPath" -Level 'DEBUG'
            $json = Get-Content $settingsPath -Raw | ConvertFrom-Json
            
            # PSObject zu Hashtable konvertieren (gemäß Instructions)
            $script:Settings = @{}
            $json.PSObject.Properties | ForEach-Object {
                $script:Settings[$_.Name] = $_.Value
            }
            Write-Log -Message "Einstellungen erfolgreich geladen" -Level 'DEBUG'
        }
        else {
            Write-Log -Message "Keine settings.json gefunden, verwende Standard-Einstellungen" -Level 'INFO'
            $script:Settings = Get-DefaultSettings
            Save-Settings
        }
        
        # Performance-Cache für häufig verwendete Settings
        $script:IsDebugEnabled = $script:Settings['ShowDebugLogs']
        $script:SettingsNeedSave = $false
        
        Write-Log -Message "Einstellungen initialisiert (Debug: $script:IsDebugEnabled)" -Level 'INFO'
    }
    catch {
        Write-Log -Message "Fehler beim Laden der Einstellungen: $($_.Exception.Message)" -Level 'ERROR'
        $script:Settings = Get-DefaultSettings
        $script:IsDebugEnabled = $false
    }
}

function Get-DefaultSettings {
    <#
    .SYNOPSIS
    Liefert die Standard-Einstellungen zurück
    #>
    return @{
        DownloadPath      = Join-Path $env:USERPROFILE "Downloads\DATEV-Toolbox"
        AutoUpdate        = $true
        ShowDebugLogs     = $false
        LogLevel          = "INFO"
        MinimizeToTray    = $true
        ShowNotifications = $true
        WindowPosition    = @{
            Left = 100
            Top  = 100
        }
        LastUpdateCheck   = (Get-Date).AddDays(-1).ToString("yyyy-MM-dd")
    }
}

function Save-Settings {
    <#
    .SYNOPSIS
    Speichert Settings sofort (thread-sichere interne Funktion)
    #>
    try {
        $settingsPath = $script:Config.Paths.SettingsFile
        $settingsDir = Split-Path $settingsPath -Parent
        
        if (-not (Test-Path $settingsDir)) {
            New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
        }
        
        # Thread-sichere Settings-Serialisierung
        # Hinweis: Diese Funktion wird nur innerhalb des Monitor-Locks aufgerufen
        $script:Settings | ConvertTo-Json -Depth 3 | Set-Content $settingsPath -Encoding UTF8
        $script:SettingsNeedSave = $false
        Write-Log -Message "Einstellungen gespeichert: $settingsPath" -Level 'DEBUG'
    }
    catch {
        Write-Log -Message "Fehler beim Speichern der Einstellungen: $($_.Exception.Message)" -Level 'ERROR'
        throw
    }
}

function Get-Setting {
    <#
    .SYNOPSIS
    Liefert einen Einstellungswert zurück (Performance-optimiert)
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Key,
        [object]$DefaultValue = $null
    )
    
    if ($null -eq $script:Settings) {
        Initialize-Settings
    }
    
    # Häufig verwendete Settings aus Cache
    switch ($Key) {
        'ShowDebugLogs' { return $script:IsDebugEnabled }
        default {
            if ($script:Settings.ContainsKey($Key)) {
                return $script:Settings[$Key]
            }
            return $DefaultValue
        }
    }
}

function Set-Setting {
    <#
    .SYNOPSIS
    Setzt einen Einstellungswert (mit thread-sicherem verzögertem Speichern)
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Key,
        [Parameter(Mandatory = $true)]
        [object]$Value
    )
    
    if ($null -eq $script:Settings) {
        Initialize-Settings
    }
    
    # Thread-sichere Settings-Verwaltung
    [System.Threading.Monitor]::Enter($script:SettingsLock)
    try {
        $oldValue = $script:Settings[$Key]
        $script:Settings[$Key] = $Value
        
        # Cache-Update für Performance-kritische Settings
        if ($Key -eq 'ShowDebugLogs') {
            $script:IsDebugEnabled = $Value
        }
        
        # Verzögertes Speichern markieren
        $script:SettingsNeedSave = $true
        
        # Thread-sichere Timer-Erstellung/Verwaltung
        if ($null -eq $script:SettingsSaveTimer) {
            $script:SettingsSaveTimer = New-Object System.Windows.Threading.DispatcherTimer
            $script:SettingsSaveTimer.Interval = [TimeSpan]::FromSeconds(2)
            $script:SettingsSaveTimer.Add_Tick({
                    # Timer-Tick-Handler ist auch thread-sicher
                    [System.Threading.Monitor]::Enter($script:SettingsLock)
                    try {
                        if ($script:SettingsNeedSave) {
                            Save-Settings
                        }
                        $script:SettingsSaveTimer.Stop()
                        $script:SettingsSaveTimer = $null
                    }
                    catch {
                        Write-Log -Message "Fehler beim Settings-Timer-Tick: $($_.Exception.Message)" -Level 'ERROR'
                    }
                    finally {
                        [System.Threading.Monitor]::Exit($script:SettingsLock)
                    }
                })
            $script:SettingsSaveTimer.Start()
            Write-Log -Message "Settings-Timer erstellt und gestartet (thread-sicher)" -Level 'DEBUG'
        }
        else {
            # Timer bereits aktiv, nur neu starten
            $script:SettingsSaveTimer.Stop()
            $script:SettingsSaveTimer.Start()
            Write-Log -Message "Settings-Timer neu gestartet (thread-sicher)" -Level 'DEBUG'
        }
        
        Write-Log -Message "Einstellung '$Key' gesetzt: $Value (war: $oldValue)" -Level 'DEBUG'
    }
    catch {
        Write-Log -Message "Fehler beim Setzen der Einstellung '$Key': $($_.Exception.Message)" -Level 'ERROR'
        throw
    }
    finally {
        # Lock IMMER freigeben (auch bei Exceptions)
        [System.Threading.Monitor]::Exit($script:SettingsLock)
    }
}

# Performance-Hilfsfunktionen für Cache-Management
function Clear-DATEVPathCache {
    <#
    .SYNOPSIS
    Leert den DATEV-Pfad-Cache (nützlich bei Installationsänderungen)
    #>
    $script:CachedDATEVPaths.Clear()
    $script:PathCacheExpiry.Clear()
    Write-Log -Message "DATEV-Pfad-Cache geleert" -Level 'INFO'
}

function Initialize-RunspacePool {
    <#
    .SYNOPSIS
    Initialisiert den Runspace-Pool für bessere Performance bei asynchronen Operationen
    #>
    try {
        if ($null -eq $script:RunspacePool) {
            $script:RunspacePool = [runspacefactory]::CreateRunspacePool(1, 3)
            $script:RunspacePool.Open()
            Write-Log -Message "Runspace-Pool initialisiert (1-3 Threads)" -Level 'DEBUG'
        }
    }
    catch {
        Write-Log -Message "Fehler beim Initialisieren des Runspace-Pools: $($_.Exception.Message)" -Level 'ERROR'
    }
}

function Close-RunspacePool {
    <#
    .SYNOPSIS
    Schließt den Runspace-Pool ordnungsgemäß
    #>
    try {
        if ($null -ne $script:RunspacePool) {
            # Aktive Jobs beenden
            foreach ($jobId in $script:ActiveJobs.Keys) {
                $job = $script:ActiveJobs[$jobId]
                if ($job.PowerShell -and -not $job.AsyncResult.IsCompleted) {
                    $job.PowerShell.Stop()
                }
                if ($job.PowerShell) {
                    $job.PowerShell.Dispose()
                }
            }
            $script:ActiveJobs.Clear()
            
            $script:RunspacePool.Close()
            $script:RunspacePool.Dispose()
            $script:RunspacePool = $null
            Write-Log -Message "Runspace-Pool ordnungsgemäß geschlossen" -Level 'DEBUG'
        }
    }
    catch {
        Write-Log -Message "Fehler beim Schließen des Runspace-Pools: $($_.Exception.Message)" -Level 'WARN'
    }
}
#endregion

#region XAML-Definition und GUI-Setup
# XAML-Definition für das Hauptfenster mit Tabs und Log-Bereich
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="DATEV-Toolbox 2 - Version v$script:AppVersion" 
        Height="700" Width="480" 
        MinHeight="500" MinWidth="400"
        WindowStartupLocation="CenterScreen"
        ResizeMode="CanResize">    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="120" MinHeight="100"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions><TabControl Grid.Row="0" Margin="10,10,10,0">            <TabItem Header="DATEV">
                <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                    <StackPanel Orientation="Vertical" Margin="10">
                        <!-- DATEV Programme -->
                        <GroupBox Margin="3,3,3,5">
                            <GroupBox.Header>
                                <TextBlock Text="DATEV Programme 🖥️" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>                            <StackPanel Orientation="Vertical" Margin="8">
                                <Button Name="btnDATEVArbeitsplatz" Content="DATEV-Arbeitsplatz" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Startet den DATEV-Arbeitsplatz mit maximiertem Fenster"/>
                                <Button Name="btnInstallationsmanager" Content="Installationsmanager" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Öffnet den DATEV Installationsmanager für Software-Updates"/>
                                <Button Name="btnServicetool" Content="Servicetool" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Startet das DATEV Servicetool für Systemdiagnose"/>
                            </StackPanel>
                        </GroupBox>
                        
                        <!-- DATEV Tools -->
                        <GroupBox Margin="3,3,3,5">
                            <GroupBox.Header>
                                <TextBlock Text="DATEV Admin-Tools 🔧" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>                            <StackPanel Orientation="Vertical" Margin="8">
                                <Button Name="btnKonfigDBTools" Content="KonfigDB-Tools" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Öffnet die DATEV Konfigurations-Datenbank Tools"/>
                                <Button Name="btnEODBconfig" Content="EODBconfig" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Startet die DATEV Enterprise Objects Datenbank-Konfiguration"/>
                                <Button Name="btnEOAufgabenplanung" Content="EO Aufgabenplanung" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Öffnet die DATEV Enterprise Objects Aufgabenplanung"/>
                                <Button Name="btnDvServerChange" Content="Server-Anpassungs-Assistent" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Startet den DATEV Server-Anpassungs-Assistenten"/>
                            </StackPanel>
                        </GroupBox>
                          <!-- Performance Tools -->
                        <GroupBox Margin="3,3,3,5">
                            <GroupBox.Header>
                                <TextBlock Text="Performance Tools ⚡" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>                            <StackPanel Orientation="Vertical" Margin="8">
                                <Button Name="btnLeistungsindex" Content="Leistungsindex ermitteln" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Führt eine Leistungsanalyse der DATEV-Installation durch (2 Durchläufe)"/>
                                <Button Name="btnNGENALL40" Content="Native Images erzwingen" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Erzwingt die Neuerstellung der .NET Native Images für bessere Performance"/>
                            </StackPanel>
                        </GroupBox>
                    </StackPanel>
                </ScrollViewer>
            </TabItem>            <TabItem Header="DATEV Online">
                <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                    <StackPanel Orientation="Vertical" Margin="10">
                        <!-- Hilfe und Support -->
                        <GroupBox Margin="3,3,3,5">
                            <GroupBox.Header>
                                <TextBlock Text="Hilfe und Support" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>                            <StackPanel Orientation="Vertical" Margin="8">
                                <Button Name="btnHilfeCenter" Content="❓ DATEV Hilfe Center" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Öffnet das DATEV Hilfe Center im Browser"/>
                                <Button Name="btnServicekontakte" Content="✉ Servicekontakte" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Zeigt DATEV Servicekontakte und Support-Informationen an"/>
                                <Button Name="btnMyUpdates" Content="DATEV myUpdates" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Öffnet das DATEV myUpdates Portal für aktuelle Informationen"/>
                                <Button Name="btnCommunity" Content="👥 DATEV Community" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Öffnet die DATEV Community für Erfahrungsaustausch und Diskussionen"/>
                            </StackPanel>
                        </GroupBox>
                        
                        <!-- Cloud -->
                        <GroupBox Margin="3,3,3,5">
                            <GroupBox.Header>
                                <TextBlock Text="Cloud" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>                            <StackPanel Orientation="Vertical" Margin="8">
                                <Button Name="btnMyDATEV" Content="myDATEV Portal" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Öffnet das zentrale myDATEV Portal"/>
                                <Button Name="btnDUO" Content="DATEV Unternehmen Online" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Startet DATEV Unternehmen Online (DUO) für Buchhaltung und mehr"/>
                                <Button Name="btnLAO" Content="Logistikauftrag Online" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Öffnet den Logistikauftrag Online Service"/>
                                <Button Name="btnLizenzverwaltung" Content="Lizenzverwaltung Online" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Verwaltet DATEV Lizenzen und Berechtigungen online"/>
                                <Button Name="btnRechteraum" Content="DATEV Rechteraum Online" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Öffnet den DATEV Rechteraum für Benutzerrechte-Verwaltung"/>
                                <Button Name="btnRVO" Content="DATEV Rechteverwaltung Online" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Startet die DATEV Rechteverwaltung Online"/>
                            </StackPanel>
                        </GroupBox>
                        
                        <!-- Verwaltung und Technik -->
                        <GroupBox Margin="3,3,3,5">
                            <GroupBox.Header>
                                <TextBlock Text="Verwaltung und Technik" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>                            <StackPanel Orientation="Vertical" Margin="8">
                                <Button Name="btnSmartLogin" Content="SmartLogin Administration" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Verwaltet DATEV SmartLogin Einstellungen und Benutzer"/>
                                <Button Name="btnBestandsmanagement" Content="myDATEV Bestandsmanagement" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Öffnet das myDATEV Bestandsmanagement für Kundenverwaltung"/>
                                <Button Name="btnVertragsuebersichten" Content="Vertragsübersichten Online" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Öffnet die DATEV Vertragsübersichten Online für Verwaltung von Verträgen und Lizenzen"/>
                                <Button Name="btnWeitereApps" Content="Weitere Cloud Anwendungen" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Zeigt weitere verfügbare DATEV Cloud-Anwendungen"/>
                            </StackPanel>
                        </GroupBox>
                    </StackPanel>
                </ScrollViewer>
            </TabItem>            <TabItem Header="Downloads">
                <StackPanel Orientation="Vertical" Margin="10">
                    <GroupBox Margin="0,0,0,5">
                        <GroupBox.Header>
                            <StackPanel Orientation="Horizontal">
                                <TextBlock Text="DATEV Direkt Downloads" FontWeight="Bold" FontSize="12" VerticalAlignment="Center"/>
                                <TextBlock Name="btnUpdateDownloads" Text="🔄" FontSize="14" Margin="8,0,0,0" 
                                           ToolTip="Direkt-Downloads aktualisieren" VerticalAlignment="Center" 
                                           Cursor="Hand" Foreground="Black"/>
                            </StackPanel>
                        </GroupBox.Header>                        <StackPanel Orientation="Vertical" Margin="8">                            <ComboBox Name="cmbDirectDownloads" Margin="0,0,0,10" Height="25"/>
                            
                            <!-- Beschreibung für ausgewählten Download -->
                            <Border Name="borderDownloadDescription" BorderBrush="LightGray" BorderThickness="1" 
                                    Background="#E8F5E8" Margin="0,0,0,10" Padding="8" CornerRadius="3" 
                                    Visibility="Collapsed">
                                <Grid>
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="Auto"/>
                                        <ColumnDefinition Width="*"/>
                                    </Grid.ColumnDefinitions>
                                    
                                    <TextBlock Grid.Column="0" Text="💡" FontSize="14" VerticalAlignment="Top" Margin="0,0,8,0"/>
                                    <TextBlock Name="txtDownloadDescription" Grid.Column="1" FontSize="11" 
                                               VerticalAlignment="Top" Foreground="#333333" TextWrapping="Wrap">
                                        <TextBlock.Inlines>
                                            <!-- Inlines werden dynamisch hinzugefügt -->
                                        </TextBlock.Inlines>
                                    </TextBlock>
                                </Grid>
                            </Border>
                            
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="Auto"/>
                                </Grid.ColumnDefinitions>                                <Button Name="btnDownload" Grid.Column="0" Content="Download starten" Height="25" 
                                        VerticalAlignment="Top" Margin="0,0,8,0" IsEnabled="False" 
                                        ToolTip="Lädt die ausgewählte DATEV-Software herunter"/>
                                <TextBlock Name="btnOpenDownloadFolder" Grid.Column="1" Text="📁" FontSize="16" Margin="0,0,0,0" 
                                           ToolTip="Download-Ordner öffnen" VerticalAlignment="Center" 
                                           Cursor="Hand" Foreground="Black"/>
                            </Grid>                        </StackPanel>
                    </GroupBox>
                    
                    <!-- DATEV Online Downloads -->
                    <GroupBox Margin="0,0,0,5">
                        <GroupBox.Header>
                            <TextBlock Text="Downloads von datev.de" FontWeight="Bold" FontSize="12"/>
                        </GroupBox.Header>
                        <StackPanel Orientation="Vertical" Margin="8">                            <Button Name="btnDATEVDownloadbereich" Content="DATEV Downloadbereich" Height="25" Margin="0,3,0,3"
                                    ToolTip="Öffnet den zentralen DATEV Downloadbereich für Updates und Tools"/>
                            <Button Name="btnDATEVSmartDocs" Content="DATEV Smart Docs" Height="25" Margin="0,3,0,3"
                                    ToolTip="Zugang zu DATEV Smart Docs für Dokumentation und Anleitungen"/>
                            <Button Name="btnDatentraegerPortal" Content="Datenträger Download Portal" Height="25" Margin="0,3,0,3"
                                    ToolTip="Portal für DVD/CD-ROM Downloads und Datenträger-Bestellungen"/>
                        </StackPanel>
                    </GroupBox>
                    
                    <!-- Sonstige nützliche Downloads -->
                    <GroupBox Margin="0,0,0,5">
                        <GroupBox.Header>
                            <TextBlock Text="Sonstige nützliche Downloads" FontWeight="Bold" FontSize="12"/>
                        </GroupBox.Header>
                        <StackPanel Orientation="Vertical" Margin="8">
                            <Button Name="btnFSLogix" Content="📥 FSLogix (latest)" Height="25" Margin="0,3,0,3"
                                    ToolTip="Lädt die neueste Version von Microsoft FSLogix herunter (Profile Container, Office Container)"/>
                        </StackPanel>
                    </GroupBox>                </StackPanel>
            </TabItem>
            
            <TabItem Header="Dokumente">
                <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                    <StackPanel Orientation="Vertical" Margin="10">
                        <!-- DATEV Dokumente und Anleitungen -->
                        <GroupBox Margin="3,3,3,5">
                            <GroupBox.Header>
                                <StackPanel Orientation="Horizontal">
                                    <TextBlock Text="DATEV Dokumente und Anleitungen" FontWeight="Bold" FontSize="12" VerticalAlignment="Center"/>
                                    <TextBlock Name="btnRefreshDocuments" Text="🔄" FontSize="14" Margin="8,0,0,0" 
                                               ToolTip="Dokumente aktualisieren" VerticalAlignment="Center" 
                                               Cursor="Hand" Foreground="Black"/>
                                </StackPanel>
                            </GroupBox.Header>
                            <StackPanel Orientation="Vertical" Margin="8">
                                <!-- Aktualisierungsdatum -->
                                <Border BorderBrush="LightBlue" BorderThickness="1" Background="#E8F4FD" 
                                        Margin="0,0,0,10" Padding="6" CornerRadius="3">
                                    <StackPanel Orientation="Horizontal">
                                        <TextBlock Text="📅" FontSize="12" VerticalAlignment="Center" Margin="0,0,6,0"/>
                                        <TextBlock Text="Letzte Aktualisierung: " FontSize="10" FontWeight="Bold" VerticalAlignment="Center"/>
                                        <TextBlock Name="txtDocumentsLastUpdated" Text="Wird geladen..." FontSize="10" VerticalAlignment="Center" Foreground="#666"/>
                                    </StackPanel>
                                </Border>
                                
                                <StackPanel Name="spDocumentsList" Orientation="Vertical" Margin="0,0,0,0">
                                    <TextBlock Text="Lade Dokumente..." 
                                               FontStyle="Italic" Foreground="Gray"/>
                                </StackPanel>
                                
                                <!-- Hinweis für weitere Dokument-Vorschläge -->
                                <Border BorderBrush="LightGray" BorderThickness="1" Background="#E8F5E8" 
                                        Margin="0,10,0,0" Padding="8" CornerRadius="3">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="Auto"/>
                                            <ColumnDefinition Width="*"/>
                                        </Grid.ColumnDefinitions>
                                        
                                        <TextBlock Grid.Column="0" Text="💡" FontSize="14" VerticalAlignment="Top" Margin="0,0,8,0"/>
                                        <TextBlock Grid.Column="1" FontSize="11" VerticalAlignment="Top" Foreground="#333333" TextWrapping="Wrap">
                                            <Run Text="Weitere Dokument-Vorschläge können Sie gerne an "/>
                                            <Hyperlink Name="txtEmailLink" 
                                                       Foreground="Blue" 
                                                       ToolTip="E-Mail senden"
                                                       TextDecorations="Underline">
                                                <Run Text="norman.zamponi@hees.de"/>
                                            </Hyperlink>
                                            <Run Text=" senden."/>
                                        </TextBlock>
                                    </Grid>
                                </Border>
                            </StackPanel>
                        </GroupBox>
                    </StackPanel>
                </ScrollViewer>
            </TabItem>
            
            <TabItem Header="System">
                <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                    <StackPanel Orientation="Vertical" Margin="10">
                        <!-- Aktionen -->
                        <GroupBox Margin="3,3,3,5">
                            <GroupBox.Header>
                                <TextBlock Text="Aktionen" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>
                            <StackPanel Orientation="Vertical" Margin="8">
                                <Button Name="btnGpupdate" Content="🔄 Gruppenrichtlinien aktualisieren" Height="25" Margin="0,3,0,3"
                                        ToolTip="Führt gpupdate /force aus um Gruppenrichtlinien sofort zu aktualisieren"/>
                                <Button Name="btnWindowsUpdates" Content="🔄 Windows Updates" Height="25" Margin="0,3,0,3"
                                        ToolTip="Öffnet die Windows Update-Einstellungen für verfügbare System-Updates"/>
                            </StackPanel>
                        </GroupBox>
                        
                        <!-- System Tools -->
                        <GroupBox Margin="3,3,3,5">
                            <GroupBox.Header>
                                <TextBlock Text="System Tools" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>
                            <StackPanel Orientation="Vertical" Margin="8">                                <Button Name="btnTaskManager" Content="Task-Manager" Height="25" Margin="0,3,0,3"
                                        ToolTip="Öffnet den Windows Task-Manager zur Prozessverwaltung"/>
                                <Button Name="btnResourceMonitor" Content="Ressourcenmonitor" Height="25" Margin="0,3,0,3"
                                        ToolTip="Startet den Windows Ressourcenmonitor für detaillierte Systemanalyse"/>
                                <Button Name="btnEventViewer" Content="Ereignisanzeige" Height="25" Margin="0,3,0,3"
                                        ToolTip="Öffnet die Windows Ereignisanzeige zur Fehlerdiagnose"/>
                                <Button Name="btnServices" Content="Dienste" Height="25" Margin="0,3,0,3"
                                        ToolTip="Verwaltet Windows-Dienste (services.msc)"/>
                                <Button Name="btnMsconfig" Content="Systemkonfiguration" Height="25" Margin="0,3,0,3"
                                        ToolTip="Öffnet die Windows Systemkonfiguration (msconfig.exe)"/>
                                <Button Name="btnDiskCleanup" Content="Datenträgerbereinigung" Height="25" Margin="0,3,0,3"
                                        ToolTip="Startet die Windows Datenträgerbereinigung für mehr freien Speicher"/>
                                <Button Name="btnTaskScheduler" Content="Aufgabenplanung" Height="25" Margin="0,3,0,3"
                                        ToolTip="Öffnet die Windows Aufgabenplanung (taskschd.msc)"/>
                            </StackPanel>
                        </GroupBox>
                    </StackPanel>
                </ScrollViewer>            </TabItem><TabItem Header="Einstellungen">
                <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                    <StackPanel Orientation="Vertical" Margin="10">
                        <!-- Einstellungen -->
                        <GroupBox Margin="3,3,3,5">
                            <GroupBox.Header>
                                <TextBlock Text="DATEV-Toolbox Einstellungen" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>                            <StackPanel Orientation="Vertical" Margin="8">                                <Button Name="btnOpenFolder" Content="Toolbox Ordner öffnen" Height="25" Margin="0,3,0,3"
                                        ToolTip="Öffnet den AppData-Ordner der DATEV-Toolbox mit Einstellungen und Logs"/>
                                <Button Name="btnCheckUpdate" Content="Nach Script Updates suchen" Height="25" Margin="0,3,0,3"
                                        ToolTip="Prüft GitHub auf verfügbare Updates für die DATEV-Toolbox"/>
                                <Button Name="btnShowChangelog" Content="Changelog anzeigen" Height="25" Margin="0,3,0,3"
                                        ToolTip="Zeigt das Changelog der aktuellen Version und der letzten Updates an"/>
                                <CheckBox Name="chkShowDebugLogs" Content="Debug-Meldungen im Log anzeigen" Margin="0,10,0,3"
                                          ToolTip="Zeigt detaillierte Debug-Informationen im Log-Fenster an"/>
                            </StackPanel>                        </GroupBox>
                        
                          <!-- Anstehende Update-Termine -->
                        <GroupBox Margin="3,3,3,5">
                            <GroupBox.Header>
                                <StackPanel Orientation="Horizontal">
                                    <TextBlock Text="Anstehende DATEV Update-Termine" FontWeight="Bold" FontSize="12" VerticalAlignment="Center"/>
                                    <TextBlock Name="btnUpdateDates" Text="🔄" FontSize="14" Margin="8,0,0,0" 
                                               ToolTip="Update-Termine aktualisieren" VerticalAlignment="Center" 
                                               Cursor="Hand" Foreground="Black"/>
                                </StackPanel>
                            </GroupBox.Header>                            <StackPanel Orientation="Vertical" Margin="8">
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

# Referenzen auf DATEV Tools Elemente holen
$spUpdateDates = $window.FindName("spUpdateDates")

# Referenz auf Einstellungs-Checkbox holen
$chkShowDebugLogs = $window.FindName("chkShowDebugLogs")
#endregion

#region Hilfsfunktionen und Utilities
# Log-Rotation (automatische Archivierung großer Log-Dateien)
function Rotate-LogFile {
    <#
    .SYNOPSIS
    Rotiert Log-Dateien wenn sie eine bestimmte Größe überschreiten
    .DESCRIPTION
    Archiviert große Log-Dateien mit Zeitstempel, behält die letzten 5 Archive
    #>
    param(
        [Parameter(Mandatory = $true)][string]$LogFilePath,
        [int]$MaxSizeInMB = 5,
        [int]$MaxArchives = 5
    )
    
    try {
        if (-not (Test-Path $LogFilePath)) {
            return
        }
        
        $logFile = Get-Item $LogFilePath -ErrorAction SilentlyContinue
        if ($null -eq $logFile) {
            return
        }
        
        $maxSizeBytes = $MaxSizeInMB * 1MB
        
        if ($logFile.Length -gt $maxSizeBytes) {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $archivePath = "$LogFilePath.$timestamp.old"
            
            # Log-Datei archivieren
            Move-Item -Path $LogFilePath -Destination $archivePath -Force
            
            # Alte Archive aufräumen (nur die letzten X behalten)
            $logDir = Split-Path $LogFilePath -Parent
            $logName = Split-Path $LogFilePath -Leaf
            $archives = Get-ChildItem -Path $logDir -Filter "$logName.*.old" | 
                        Sort-Object LastWriteTime -Descending
            
            if ($archives.Count -gt $MaxArchives) {
                $archives | Select-Object -Skip $MaxArchives | Remove-Item -Force
            }
            
            Write-Host "[Log-Rotation] $logName archiviert ($([math]::Round($logFile.Length / 1MB, 2)) MB)" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "[Log-Rotation] Fehler: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Logging-System (Performance-optimiert mit automatischer Rotation)
function Write-Log {
    <#
    .SYNOPSIS
    Zentrale Logging-Funktion für die Anwendung (Performance-optimiert)
    #>
    param(
        [Parameter(Mandatory = $true)][string]$Message,
        [ValidateSet('INFO', 'WARN', 'ERROR', 'DEBUG')][string]$Level = 'INFO'
    )
    
    # Früher Exit für Debug-Meldungen (Performance-kritisch)
    if ($Level -eq 'DEBUG' -and -not $script:IsDebugEnabled) {
        return
    }
    
    try {
        # StringBuilder für bessere String-Performance
        $null = $script:LogStringBuilder.Clear()
        $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        
        switch ($Level) {
            'INFO' { $prefix = '[INFO] ' }
            'WARN' { $prefix = '[WARNUNG] ' }
            'ERROR' { $prefix = '[FEHLER] ' }
            'DEBUG' { $prefix = '[DEBUG] ' }
        }
        
        $null = $script:LogStringBuilder.Append($timestamp).Append(' ').Append($prefix).Append($Message).Append("`r`n")
        $logEntry = $script:LogStringBuilder.ToString()
        
        # UI-Update nur wenn TextBox verfügbar
        if ($null -ne $txtLog) {
            $txtLog.AppendText($logEntry)
            $txtLog.ScrollToEnd()
        }
        
        # Fehler-Log nur bei WARN/ERROR
        if ($Level -eq 'WARN' -or $Level -eq 'ERROR') {
            $logFile = $script:Config.Paths.ErrorLog
            $logDir = Split-Path $logFile -Parent
            if (-not (Test-Path $logDir)) {
                New-Item -Path $logDir -ItemType Directory -Force | Out-Null
            }
            
            # Log-Rotation prüfen (nur bei jedem 10. Schreibvorgang für Performance)
            if (-not $script:LogRotationCounter) { $script:LogRotationCounter = 0 }
            $script:LogRotationCounter++
            if ($script:LogRotationCounter -ge 10) {
                Rotate-LogFile -LogFilePath $logFile -MaxSizeInMB 5 -MaxArchives 5
                $script:LogRotationCounter = 0
            }
            
            Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
        }
    }
    catch {
        # Fallback wenn Logging fehlschlägt
        Write-Host "LOGGING-FEHLER: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# URL-Öffnungs-Funktion
function Open-Url {
    <#
    .SYNOPSIS
    Öffnet eine URL im Standard-Browser mit Fehlerbehandlung
    #>
    param(
        [Parameter(Mandatory = $true)][string]$Url
    )
    
    try {
        Write-Log -Message "Öffne URL: $Url" -Level 'INFO'
        Start-Process $Url
    }
    catch {
        Write-Log -Message "Fehler beim Öffnen der URL '$Url': $($_.Exception.Message)" -Level 'ERROR'
        [System.Windows.MessageBox]::Show(
            "Fehler beim Öffnen der URL:`n$Url`n`n$($_.Exception.Message)",
            "Fehler",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error
        )
    }
}

# Hilfsfunktionen für Event-Handler (PowerShell 5.1-kompatibel ohne Closures)
function Register-UrlHandler {
    param($Button, $Url)
    $Button.Tag = $Url
    $Button.Add_Click({
            $url = $this.Tag
            Write-Log -Message "URL-Button '$($this.Name)' geklickt - öffne: $url" -Level 'INFO'
            Open-Url -Url $url
        })
}

function Register-DATEVHandler {
    param($Button, $ProgramName, $PossiblePaths, $Description)
    $Button.Tag = @{
        ProgramName   = $ProgramName
        PossiblePaths = $PossiblePaths
        Description   = $Description
    }
    $Button.Add_Click({
            $config = $this.Tag
            Write-Log -Message "DATEV-Button '$($this.Name)' geklickt - starte: $($config.ProgramName)" -Level 'INFO'
            Start-DATEVProgram -ProgramName $config.ProgramName -PossiblePaths $config.PossiblePaths -Description $config.Description
        })
}

function Register-SystemToolHandler {
    param($Button, $Command, $Description)
    $Button.Tag = @{
        Command     = $Command
        Description = $Description
    }
    $Button.Add_Click({
            $config = $this.Tag
            Write-Log -Message "SystemTool-Button '$($this.Name)' geklickt - starte: $($config.Command)" -Level 'INFO'
            Start-SystemTool -Command $config.Command -Description $config.Description
        })
}

function Register-FunctionHandler {
    param($Button, $FunctionName)
    $Button.Tag = $FunctionName
    $Button.Add_Click({
            $functionName = $this.Tag
            Write-Log -Message "Function-Button '$($this.Name)' geklickt - rufe auf: $functionName" -Level 'INFO'
            & $functionName
        })
}

#region Tray-Icon System
# System-Tray-Integration mit Benachrichtigungen

# Globale Variable für Tray-Icon
$script:TrayIcon = $null

function Initialize-TrayIcon {
    <#
    .SYNOPSIS
    Initialisiert das System-Tray-Icon mit Kontextmenü und Benachrichtigungen
    
    .DESCRIPTION
    Erstellt ein NotifyIcon im System-Tray mit Kontextmenü für Quick-Actions.
    Das Icon wird aus dem Skript extrahiert oder verwendet ein Standard-Windows-Icon als Fallback.
    
    .EXAMPLE
    Initialize-TrayIcon
    #>
    try {
        Write-Log -Message "Initialisiere System-Tray-Icon..." -Level 'DEBUG'
        
        # NotifyIcon erstellen
        $script:TrayIcon = New-Object System.Windows.Forms.NotifyIcon
        
        # Icon-Pfad für Custom Icon
        $customIconPath = Join-Path (Split-Path $PSCommandPath -Parent) "images\tray-icon.ico"
        $iconSource = $null
        
        # Icon-Loading mit 3-stufigem Fallback-System
        # 1. Versuche Custom Icon lokal zu laden
        if (Test-Path $customIconPath) {
            try {
                $script:TrayIcon.Icon = New-Object System.Drawing.Icon($customIconPath)
                $iconSource = "Custom Icon (lokal: images/tray-icon.ico)"
                Write-Log -Message "Custom Tray-Icon erfolgreich geladen: $customIconPath" -Level 'INFO'
            }
            catch {
                Write-Log -Message "Fehler beim Laden des Custom Icons: $($_.Exception.Message)" -Level 'WARN'
                # Fallback zu Application Icon
                $script:TrayIcon.Icon = [System.Drawing.SystemIcons]::Application
                $iconSource = "Application Icon (Fallback nach Custom-Fehler)"
            }
        }
        # 2. Versuche Icon von GitHub herunterzuladen (falls lokal nicht vorhanden)
        else {
            Write-Log -Message "Lokales Tray-Icon nicht gefunden, versuche Download von GitHub..." -Level 'DEBUG'
            
            try {
                # GitHub-URL für Tray-Icon
                $iconUrl = "https://github.com/$script:GitHubRepo/raw/main/images/tray-icon.ico"
                
                # Stelle sicher, dass images-Ordner existiert
                $imagesFolder = Split-Path $customIconPath -Parent
                if (-not (Test-Path $imagesFolder)) {
                    New-Item -ItemType Directory -Path $imagesFolder -Force | Out-Null
                    Write-Log -Message "Images-Ordner erstellt: $imagesFolder" -Level 'DEBUG'
                }
                
                # TLS 1.2 erzwingen für sicheren Download
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                
                # Icon herunterladen
                $webClient = New-Object System.Net.WebClient
                $webClient.DownloadFile($iconUrl, $customIconPath)
                $webClient.Dispose()
                
                Write-Log -Message "Tray-Icon erfolgreich von GitHub heruntergeladen" -Level 'INFO'
                
                # Heruntergeladenes Icon laden
                $script:TrayIcon.Icon = New-Object System.Drawing.Icon($customIconPath)
                $iconSource = "Custom Icon (heruntergeladen von GitHub)"
            }
            catch {
                Write-Log -Message "Fehler beim Download des Tray-Icons von GitHub: $($_.Exception.Message)" -Level 'WARN'
                
                # 3. Fallback: Application Icon (Standard Windows-Icon)
                $script:TrayIcon.Icon = [System.Drawing.SystemIcons]::Application
                $iconSource = "Application Icon (Fallback)"
                Write-Log -Message "Verwende Application Icon als Fallback" -Level 'DEBUG'
            }
        }
        
        $script:TrayIcon.Text = "DATEV-Toolbox 2.0"
        $script:TrayIcon.Visible = $true
        
        Write-Log -Message "Tray-Icon initialisiert mit: $iconSource" -Level 'DEBUG'
        
        # Kontextmenü erstellen
        $contextMenu = New-Object System.Windows.Forms.ContextMenuStrip
        
        # Menü-Einträge
        $menuShow = $contextMenu.Items.Add("Fenster anzeigen")
        $menuShow.Add_Click({
            Show-MainWindow
        })
        
        $contextMenu.Items.Add([System.Windows.Forms.ToolStripSeparator]::new())
        
        $menuDATEV = $contextMenu.Items.Add("DATEV-Arbeitsplatz")
        $menuDATEV.Add_Click({
            Start-DATEVProgram -ProgramName 'DATEVArbeitsplatz' -PossiblePaths $script:DATEVProgramPaths['DATEVArbeitsplatz'] -Description 'DATEV-Arbeitsplatz'
        })
        
        $menuDownloads = $contextMenu.Items.Add("Download-Ordner öffnen")
        $menuDownloads.Add_Click({
            Open-DownloadFolder
        })
        
        $contextMenu.Items.Add([System.Windows.Forms.ToolStripSeparator]::new())
        
        $menuExit = $contextMenu.Items.Add("Beenden")
        $menuExit.Add_Click({
            Close-Application
        })
        
        $script:TrayIcon.ContextMenuStrip = $contextMenu
        
        # Double-Click Event für Fenster anzeigen
        $script:TrayIcon.Add_DoubleClick({
            Show-MainWindow
        })
        
        Write-Log -Message "System-Tray-Icon erfolgreich initialisiert (Icon: $iconPath)" -Level 'INFO'
    }
    catch {
        Write-Log -Message "Fehler beim Initialisieren des Tray-Icons: $($_.Exception.Message)" -Level 'ERROR'
    }
}

function Show-TrayNotification {
    <#
    .SYNOPSIS
    Zeigt eine Balloon-Benachrichtigung im System-Tray an
    
    .DESCRIPTION
    Zeigt eine temporäre Benachrichtigung über dem Tray-Icon an.
    Die Benachrichtigung verschwindet automatisch nach der angegebenen Dauer.
    
    .PARAMETER Title
    Titel der Benachrichtigung
    
    .PARAMETER Message
    Nachrichtentext der Benachrichtigung
    
    .PARAMETER Icon
    Icon-Typ: None, Info, Warning oder Error
    
    .PARAMETER Duration
    Anzeigedauer in Millisekunden (Standard: 5000)
    
    .EXAMPLE
    Show-TrayNotification -Title "Update" -Message "Neue Version verfügbar" -Icon 'Info'
    
    .EXAMPLE
    Show-TrayNotification -Title "Fehler" -Message "Verbindung fehlgeschlagen" -Icon 'Error' -Duration 3000
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,
        
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('None', 'Info', 'Warning', 'Error')]
        [string]$Icon = 'Info',
        
        [Parameter(Mandatory = $false)]
        [int]$Duration = 5000  # Millisekunden
    )
    
    try {
        if ($null -eq $script:TrayIcon) {
            Write-Log -Message "Tray-Icon nicht initialisiert, Benachrichtigung wird übersprungen" -Level 'WARN'
            return
        }
        
        # Icon-Typ konvertieren
        $iconType = switch ($Icon) {
            'None' { [System.Windows.Forms.ToolTipIcon]::None }
            'Info' { [System.Windows.Forms.ToolTipIcon]::Info }
            'Warning' { [System.Windows.Forms.ToolTipIcon]::Warning }
            'Error' { [System.Windows.Forms.ToolTipIcon]::Error }
            default { [System.Windows.Forms.ToolTipIcon]::Info }
        }
        
        $script:TrayIcon.BalloonTipTitle = $Title
        $script:TrayIcon.BalloonTipText = $Message
        $script:TrayIcon.BalloonTipIcon = $iconType
        $script:TrayIcon.ShowBalloonTip($Duration)
        
        Write-Log -Message "Tray-Benachrichtigung angezeigt: $Title - $Message" -Level 'DEBUG'
    }
    catch {
        Write-Log -Message "Fehler beim Anzeigen der Tray-Benachrichtigung: $($_.Exception.Message)" -Level 'ERROR'
    }
}

function Show-MainWindow {
    <#
    .SYNOPSIS
    Zeigt das Hauptfenster an und aktiviert es
    
    .DESCRIPTION
    Stellt das minimierte oder versteckte Hauptfenster wieder her und bringt es in den Vordergrund.
    
    .EXAMPLE
    Show-MainWindow
    #>
    try {
        if ($null -ne $window) {
            $window.Show()
            $window.WindowState = [System.Windows.WindowState]::Normal
            $window.ShowInTaskbar = $true
            $window.Activate()
            Write-Log -Message "Hauptfenster angezeigt und aktiviert" -Level 'DEBUG'
        }
    }
    catch {
        Write-Log -Message "Fehler beim Anzeigen des Hauptfensters: $($_.Exception.Message)" -Level 'ERROR'
    }
}

function Close-Application {
    <#
    .SYNOPSIS
    Schließt die Anwendung ordnungsgemäß
    
    .DESCRIPTION
    Beendet die Anwendung, bereinigt das Tray-Icon und schließt das Hauptfenster.
    
    .EXAMPLE
    Close-Application
    #>
    try {
        Write-Log -Message "Anwendung wird über Tray-Icon beendet..." -Level 'INFO'
        
        # Tray-Icon bereinigen
        Close-TrayIcon
        
        # Fenster schließen
        if ($null -ne $window) {
            $window.Close()
        }
    }
    catch {
        Write-Log -Message "Fehler beim Beenden der Anwendung: $($_.Exception.Message)" -Level 'ERROR'
    }
}

function Close-TrayIcon {
    <#
    .SYNOPSIS
    Entfernt das Tray-Icon ordnungsgemäß
    
    .DESCRIPTION
    Macht das Tray-Icon unsichtbar, gibt Ressourcen frei und setzt die Variable zurück.
    
    .EXAMPLE
    Close-TrayIcon
    #>
    try {
        if ($null -ne $script:TrayIcon) {
            $script:TrayIcon.Visible = $false
            $script:TrayIcon.Dispose()
            $script:TrayIcon = $null
            Write-Log -Message "Tray-Icon ordnungsgemäß entfernt" -Level 'DEBUG'
        }
    }
    catch {
        Write-Log -Message "Fehler beim Entfernen des Tray-Icons: $($_.Exception.Message)" -Level 'WARN'
    }
}
#endregion

function Register-TextBlockHandler {
    param($TextBlock, $FunctionName)
    $TextBlock.Tag = $FunctionName
    $TextBlock.Add_MouseLeftButtonDown({
            $functionName = $this.Tag
            Write-Log -Message "TextBlock '$($this.Name)' geklickt - rufe auf: $functionName" -Level 'INFO'
            & $functionName
        })
}

function Register-HyperlinkHandler {
    param($Hyperlink, $FunctionName)
    $Hyperlink.Tag = $FunctionName
    $Hyperlink.Add_RequestNavigate({
            $functionName = $this.Tag
            Write-Log -Message "Hyperlink '$($this.Name)' geklickt - rufe auf: $functionName" -Level 'INFO'
            & $functionName
        })
}

function Register-DownloadHandler {
    param($Button, $DownloadInfo)
    $Button.Tag = $DownloadInfo
    $Button.Add_Click({
            $downloadInfo = $this.Tag
            Write-Log -Message "Download-Button '$($this.Name)' geklickt - starte Download: $($downloadInfo.FileName)" -Level 'INFO'
            Start-BackgroundDownload -Url $downloadInfo.Url -FileName $downloadInfo.FileName
        })
}

# Zentrale Button-Handler-Registrierung
function Register-ButtonHandlers {
    <#
    .SYNOPSIS
    Registriert Event-Handler für alle Buttons basierend auf der zentralen Konfiguration
    .DESCRIPTION
    PowerShell 5.1-kompatible zentrale Event-Handler-Registrierung ohne GetNewClosure()
    #>
    param(
        [Parameter(Mandatory = $true)][System.Windows.Window]$Window
    )
    
    Write-Log -Message "Registriere zentrale Button-Handler..." -Level 'DEBUG'
    
    # Debug: Zeige alle konfigurierten Buttons
    Write-Log -Message "Anzahl konfigurierte Buttons: $($script:Config.ButtonMappings.Keys.Count)" -Level 'DEBUG'
    Write-Log -Message "Konfigurierte Buttons: $($script:Config.ButtonMappings.Keys -join ', ')" -Level 'DEBUG'
    
    try {
        foreach ($buttonName in $script:Config.ButtonMappings.Keys) {
            $buttonConfig = $script:Config.ButtonMappings[$buttonName]
            $buttonElement = $Window.FindName($buttonName)
            
            if ($null -eq $buttonElement) {
                Write-Log -Message "Button '$buttonName' nicht gefunden im GUI - überspringe (Typ: $($buttonConfig.Type))" -Level 'WARN'
                continue
            }
            else {
                Write-Log -Message "Button '$buttonName' gefunden: $($buttonElement.GetType().Name)" -Level 'DEBUG'
            }
            
            # Handler-Typ bestimmen und entsprechenden Event-Handler registrieren (OHNE GetNewClosure)
            switch ($buttonConfig.Type) {
                'URL' {
                    if ($buttonConfig.ContainsKey('UrlKey')) {
                        $urlKey = $buttonConfig.UrlKey
                        $url = $script:Config.URLs.DATEV[$urlKey]
                        if ($null -ne $url) {
                            # Direkte Registrierung ohne Closure
                            Register-UrlHandler -Button $buttonElement -Url $url
                            Write-Log -Message "URL-Handler für '$buttonName' registriert (URL: $url)" -Level 'DEBUG'
                        }
                        else {
                            Write-Log -Message "URL für '$urlKey' nicht gefunden - Button '$buttonName' übersprungen" -Level 'WARN'
                        }
                    }
                }
                
                'DATEV' {
                    if ($buttonConfig.ContainsKey('ProgramName')) {
                        $programName = $buttonConfig.ProgramName
                        $description = $buttonConfig.Description
                        $possiblePaths = $script:DATEVProgramPaths[$programName]
                        
                        Write-Log -Message "Debug: Button '$buttonName', Programm '$programName', Pfade: $($possiblePaths -join ', ')" -Level 'DEBUG'
                        
                        if ($null -ne $possiblePaths -and $possiblePaths.Count -gt 0) {
                            # Direkte Registrierung ohne Closure
                            Register-DATEVHandler -Button $buttonElement -ProgramName $programName -PossiblePaths $possiblePaths -Description $description
                            Write-Log -Message "DATEV-Handler für '$buttonName' registriert" -Level 'DEBUG'
                        }
                        else {
                            Write-Log -Message "Keine DATEV-Pfade für '$programName' gefunden - Button '$buttonName' übersprungen" -Level 'WARN'
                        }
                    }
                }
                
                'SystemTool' {
                    if ($buttonConfig.ContainsKey('Command')) {
                        $command = $buttonConfig.Command
                        $description = $buttonConfig.Description
                        # Direkte Registrierung ohne Closure
                        Register-SystemToolHandler -Button $buttonElement -Command $command -Description $description
                        Write-Log -Message "SystemTool-Handler für '$buttonName' registriert" -Level 'DEBUG'
                    }
                }
                
                'Function' {
                    if ($buttonConfig.ContainsKey('FunctionName')) {
                        $functionName = $buttonConfig.FunctionName
                        # Direkte Registrierung ohne Closure
                        Register-FunctionHandler -Button $buttonElement -FunctionName $functionName
                        Write-Log -Message "Function-Handler für '$buttonName' registriert" -Level 'DEBUG'
                    }
                }
                
                'Download' {
                    if ($buttonConfig.ContainsKey('DownloadKey')) {
                        $downloadKey = $buttonConfig.DownloadKey
                        $downloadInfo = $script:Config.Downloads[$downloadKey]
                        if ($null -ne $downloadInfo) {
                            # Direkte Registrierung ohne Closure
                            Register-DownloadHandler -Button $buttonElement -DownloadInfo $downloadInfo
                            Write-Log -Message "Download-Handler für '$buttonName' registriert (Datei: $($downloadInfo.FileName))" -Level 'DEBUG'
                        }
                        else {
                            Write-Log -Message "Download-Info für '$downloadKey' nicht gefunden - Button '$buttonName' übersprungen" -Level 'WARN'
                        }
                    }
                }
                
                'TextBlock' {
                    # TextBlock-Elemente verwenden MouseLeftButtonDown statt Add_Click
                    if ($buttonConfig.ContainsKey('FunctionName')) {
                        $functionName = $buttonConfig.FunctionName
                        # Direkte Registrierung ohne Closure
                        Register-TextBlockHandler -TextBlock $buttonElement -FunctionName $functionName
                        Write-Log -Message "TextBlock-Handler für '$buttonName' registriert" -Level 'DEBUG'
                    }
                }
                
                'Hyperlink' {
                    # Hyperlink-Elemente verwenden RequestNavigate Event
                    if ($buttonConfig.ContainsKey('FunctionName')) {
                        $functionName = $buttonConfig.FunctionName
                        # Direkte Registrierung ohne Closure
                        Register-HyperlinkHandler -Hyperlink $buttonElement -FunctionName $functionName
                        Write-Log -Message "Hyperlink-Handler für '$buttonName' registriert" -Level 'DEBUG'
                    }
                }
                
                default {
                    Write-Log -Message "Unbekannter Handler-Typ '$($buttonConfig.Type)' für Button '$buttonName'" -Level 'WARN'
                }
            }
        }
        
        Write-Log -Message "Button-Handler-Registrierung abgeschlossen" -Level 'DEBUG'
    }
    catch {
        Write-Log -Message "Fehler bei der Button-Handler-Registrierung: $($_.Exception.Message)" -Level 'ERROR'
        throw
    }
}

# Funktions-Handler für zentrale Button-Registrierung
function Start-UpdateCheck {
    <#
    .SYNOPSIS
    Führt eine manuelle Update-Prüfung durch
    #>
    Start-ManualUpdateCheck
}

function Start-DirectDownload {
    <#
    .SYNOPSIS
    Startet einen direkten Download basierend auf der ComboBox-Auswahl
    #>
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
            
            Write-Log -Message "Starte Download: $($downloadInfo.Name)" -Level 'INFO'
            Start-BackgroundDownload -Url $downloadInfo.url -FileName $fileName
        }
        else {
            Write-Log -Message "Kein Download ausgewählt oder ungültige Auswahl" -Level 'WARN'
            [System.Windows.MessageBox]::Show(
                "Bitte wählen Sie zuerst einen Download aus der Liste aus.",
                "Kein Download ausgewählt",
                [System.Windows.MessageBoxButton]::OK,
                [System.Windows.MessageBoxImage]::Information
            )
        }
    }
    catch {
        Write-Log -Message "Fehler beim Starten des Downloads: $($_.Exception.Message)" -Level 'ERROR'
        [System.Windows.MessageBox]::Show(
            "Fehler beim Starten des Downloads:`n$($_.Exception.Message)",
            "Download-Fehler",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error
        )
    }
}

function Open-AppDataFolder {
    <#
    .SYNOPSIS
    Öffnet den AppData-Ordner der DATEV-Toolbox
    #>
    try {
        $appDataPath = $script:Config.Paths.AppData
        
        # Ordner erstellen falls er nicht existiert
        if (-not (Test-Path $appDataPath)) {
            New-Item -ItemType Directory -Path $appDataPath -Force | Out-Null
            Write-Log -Message "AppData-Ordner erstellt: $appDataPath" -Level 'INFO'
        }
        
        Write-Log -Message "Öffne AppData-Ordner: $appDataPath" -Level 'INFO'
        Start-Process -FilePath 'explorer.exe' -ArgumentList $appDataPath
    }
    catch {
        Write-Log -Message "Fehler beim Öffnen des AppData-Ordners: $($_.Exception.Message)" -Level 'ERROR'
        [System.Windows.MessageBox]::Show(
            "Fehler beim Öffnen des AppData-Ordners:`n$($_.Exception.Message)",
            "Fehler",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error
        )
    }
}

#endregion

#region DATEV-Programme und -Tools
# Zentrale Funktion zur robusten Suche nach DATEV-Programmpfaden (Performance-optimiert mit Caching)
function Get-DATEVExecutablePath {
    <#
    .SYNOPSIS
    Findet den vollständigen Pfad zu einem DATEV-Programm mit Performance-Caching.
    .DESCRIPTION
    Sucht nach einem Programm, indem es die %DATEVPP%-Umgebungsvariable,
    Standard-Installationspfade und die Windows-Registrierung prüft.
    Verwendet Caching für bessere Performance bei wiederholten Aufrufen.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProgramName
    )
    
    # Cache-Check: Ist der Pfad bereits bekannt und noch gültig?
    if ($script:CachedDATEVPaths.ContainsKey($ProgramName)) {
        $cachedEntry = $script:CachedDATEVPaths[$ProgramName]
        $cacheExpiry = $script:PathCacheExpiry[$ProgramName]
        
        # Cache ist noch gültig (5 Minuten)
        if ($cacheExpiry -gt (Get-Date)) {
            # Pfad nochmal validieren (schneller als komplette Suche)
            $cachedPath = $cachedEntry.Path
            
            # Sicherstellen dass wir einen String zurückgeben (Cache-Konsistenz)
            $pathToValidate = if ($cachedPath -is [Array]) { $cachedPath[0] } else { $cachedPath }
            
            if (Test-Path $pathToValidate) {
                Write-Log -Message "DATEV-Pfad aus Cache: $ProgramName -> $pathToValidate" -Level 'DEBUG'
                return $pathToValidate  # Immer String zurückgeben
            }
            else {
                # Cache-Eintrag ist ungültig, entfernen
                $script:CachedDATEVPaths.Remove($ProgramName)
                $script:PathCacheExpiry.Remove($ProgramName)
                Write-Log -Message "Cache-Eintrag für $ProgramName ungültig geworden, entfernt" -Level 'DEBUG'
            }
        }
        else {
            # Cache abgelaufen, entfernen
            $script:CachedDATEVPaths.Remove($ProgramName)
            $script:PathCacheExpiry.Remove($ProgramName)
            Write-Log -Message "Cache für $ProgramName abgelaufen, wird neu gesucht" -Level 'DEBUG'
        }
    }
    
    $possiblePaths = $script:DATEVProgramPaths[$ProgramName]
    if (-not $possiblePaths) {
        Write-Log -Message "Keine Pfad-Definitionen für $ProgramName gefunden" -Level 'WARN' | Out-Null
        return $null
    }

    Write-Log -Message "Suche DATEV-Programm: $ProgramName" -Level 'DEBUG'

    # Primäre Suche über Umgebungsvariable
    if (-not [string]::IsNullOrEmpty($env:DATEVPP)) {
        Write-Log -Message "Prüfe DATEVPP-Umgebungsvariable: $env:DATEVPP" -Level 'DEBUG'
        foreach ($path in $possiblePaths) {
            $expandedPath = $path -replace '%DATEVPP%', $env:DATEVPP
            if (Test-Path $expandedPath) {
                # Erfolgreichen Pfad cachen
                $script:CachedDATEVPaths[$ProgramName] = @{
                    Path   = $expandedPath
                    Source = 'DATEVPP-Environment'
                    Found  = Get-Date
                }
                $script:PathCacheExpiry[$ProgramName] = (Get-Date).AddMinutes(5)
                Write-Log -Message "DATEV-Programm gefunden (DATEVPP): $expandedPath" -Level 'DEBUG'
                return $expandedPath
            }
        }
    }

    # Fallback: Standardpfade und Registrierung
    Write-Log -Message "DATEVPP nicht verfügbar, prüfe Standardpfade und Registrierung" -Level 'DEBUG'
    $standardBasePaths = @(
        'C:\DATEV', 'D:\DATEV', 'E:\DATEV',
        "${env:ProgramFiles(x86)}\DATEV",
        (Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\DATEV\CONFIG\DVSW\SETUP' -Name 'DATEVPP' -ErrorAction SilentlyContinue).DATEVPP
    ) | Where-Object { -not [string]::IsNullOrEmpty($_) } | Get-Unique

    foreach ($basePath in $standardBasePaths) {
        Write-Log -Message "Prüfe Basispfad: $basePath" -Level 'DEBUG'
        foreach ($path in $possiblePaths) {
            $testPath = $path -replace '%DATEVPP%', $basePath
            if (Test-Path $testPath) {
                # Erfolgreichen Pfad cachen (immer als String)
                $script:CachedDATEVPaths[$ProgramName] = @{
                    Path   = $testPath
                    Source = "StandardPath-$basePath"
                    Found  = Get-Date
                }
                $script:PathCacheExpiry[$ProgramName] = (Get-Date).AddMinutes(5)
                Write-Log -Message "DATEV-Programm gefunden (Standard): $testPath" -Level 'DEBUG'
                return $testPath
            }
        }
    }
    
    Write-Log -Message "DATEV-Programm $ProgramName nicht gefunden" -Level 'WARN'
    return $null # Nichts gefunden
}

# Funktion zum Finden und Starten von DATEV-Programmen (jetzt mit zentraler Pfadsuche)
function Start-DATEVProgram {
    param(
        [Parameter(Mandatory = $true)][string]$ProgramName,
        [Parameter(Mandatory = $true)][array]$PossiblePaths, # Bleibt für Handler-Kompatibilität
        [string]$Description = $ProgramName
    )
    
    try {
        Write-Log -Message "Suche nach $Description..." -Level 'INFO'
        
        $foundPath = Get-DATEVExecutablePath -ProgramName $ProgramName
        
        if ($foundPath) {
            # Da Get-DATEVExecutablePath jetzt immer einen String zurückgibt
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

# Spezielle Funktion für den Leistungsindex (jetzt mit zentraler Pfadsuche)
function Start-Leistungsindex {
    <#
    .SYNOPSIS
    Startet die Leistungsindex-Messung asynchron mit doppelter Ausführung
    
    .DESCRIPTION
    Führt den DATEV Leistungsindex (irw.exe) in zwei Schritten aus:
    1. irw.exe -ap:PerfIndex -d:IRW20011 -c
    2. irw.exe -ap:PerfIndex -d:IRW20011
    
    Die Ausführung erfolgt asynchron um die GUI nicht zu blockieren.
    #>
    try {
        Write-Log -Message "Suche nach Leistungsindex (irw.exe)..." -Level 'INFO'
        
        $foundPath = Get-DATEVExecutablePath -ProgramName 'Leistungsindex'
        
        if ($foundPath) {
            Write-Log -Message "Starte Leistungsindex von: $foundPath" -Level 'INFO'
            
            # Asynchrone Ausführung mit Runspace um GUI nicht zu blockieren
            $runspace = [runspacefactory]::CreateRunspace()
            $runspace.Open()
            $runspace.SessionStateProxy.SetVariable('foundPath', $foundPath)
            $runspace.SessionStateProxy.SetVariable('logFunction', (Get-Command Write-Log))
            
            $powershell = [powershell]::Create()
            $powershell.Runspace = $runspace
            
            [void]$powershell.AddScript({
                    param($executablePath, $writeLogCmd)
                
                    # Write-Log Funktion im Runspace verfügbar machen
                    function Write-Log { 
                        param([string]$Message, [string]$Level = 'INFO')
                        # Vereinfachtes Logging für Runspace
                        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                        Write-Host "[$timestamp] [$Level] $Message"
                    }
                
                    try {
                        Write-Log -Message "Erster Durchlauf: irw.exe -ap:PerfIndex -d:IRW20011 -c" -Level 'INFO'
                    
                        # Erster Durchlauf mit -c Parameter
                        $process1 = Start-Process -FilePath $executablePath -ArgumentList "-ap:PerfIndex", "-d:IRW20011", "-c" -Wait -PassThru -NoNewWindow
                    
                        if ($process1.ExitCode -eq 0) {
                            Write-Log -Message "Erster Durchlauf erfolgreich abgeschlossen (Exit Code: $($process1.ExitCode))" -Level 'INFO'
                        
                            # Kurze Pause zwischen den Durchläufen
                            Start-Sleep -Seconds 2
                        
                            Write-Log -Message "Zweiter Durchlauf: irw.exe -ap:PerfIndex -d:IRW20011" -Level 'INFO'
                        
                            # Zweiter Durchlauf ohne -c Parameter
                            $process2 = Start-Process -FilePath $executablePath -ArgumentList "-ap:PerfIndex", "-d:IRW20011" -Wait -PassThru -NoNewWindow
                        
                            if ($process2.ExitCode -eq 0) {
                                Write-Log -Message "Leistungsindex-Messungen erfolgreich abgeschlossen (Exit Code: $($process2.ExitCode))" -Level 'INFO'
                                return @{ Success = $true; Message = "Leistungsindex-Messungen erfolgreich abgeschlossen" }
                            }
                            else {
                                Write-Log -Message "Zweiter Durchlauf fehlgeschlagen (Exit Code: $($process2.ExitCode))" -Level 'ERROR'
                                return @{ Success = $false; Message = "Zweiter Durchlauf fehlgeschlagen" }
                            }
                        }
                        else {
                            Write-Log -Message "Erster Durchlauf fehlgeschlagen (Exit Code: $($process1.ExitCode))" -Level 'ERROR'
                            return @{ Success = $false; Message = "Erster Durchlauf fehlgeschlagen" }
                        }
                    }
                    catch {
                        Write-Log -Message "Fehler bei Leistungsindex-Ausführung: $($_.Exception.Message)" -Level 'ERROR'
                        return @{ Success = $false; Message = $_.Exception.Message }
                    }
                })
            
            # Parameter für das Skript hinzufügen
            [void]$powershell.AddParameter('executablePath', $foundPath)
            [void]$powershell.AddParameter('writeLogCmd', (Get-Command Write-Log))
            
            # Asynchrone Ausführung starten
            $asyncResult = $powershell.BeginInvoke()
            
            Write-Log -Message "Leistungsindex-Messung asynchron gestartet - läuft im Hintergrund" -Level 'INFO'
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
# Windows System-Tools starten
function Start-SystemTool {
    <#
    .SYNOPSIS
    Startet ein Windows System-Tool mit Fehlerbehandlung
    #>
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

# Funktion zum Ausführen von Gruppenrichtlinien-Update
function Start-Gpupdate {
    <#
    .SYNOPSIS
    Führt gpupdate /force in einer neuen CMD aus (vereinfachte Version)
    .DESCRIPTION
    Startet gpupdate /force in einem separaten CMD-Fenster, das sichtbar bleibt
    bis der Prozess abgeschlossen ist. Deutlich einfacher als die bisherige Lösung.
    #>
    try {
        Write-Log -Message "Starte Gruppenrichtlinien-Update (gpupdate /force) in neuer CMD..." -Level 'INFO'
        
        # Prüfen ob bereits ein gpupdate läuft (optional)
        $existingProcesses = Get-Process -Name "gpupdate" -ErrorAction SilentlyContinue
        if ($existingProcesses) {
            $result = [System.Windows.MessageBox]::Show(
                "Es läuft bereits ein Gruppenrichtlinien-Update ($($existingProcesses.Count) Prozess(e)).`n`nMöchten Sie trotzdem ein neues Update starten?",
                "Gruppenrichtlinien-Update läuft bereits",
                [System.Windows.MessageBoxButton]::YesNo,
                [System.Windows.MessageBoxImage]::Question
            )
            
            if ($result -eq [System.Windows.MessageBoxResult]::No) {
                Write-Log -Message "Gruppenrichtlinien-Update abgebrochen - bereits laufender Prozess" -Level 'INFO'
                return
            }
        }
        
        # CMD-Befehl zusammenstellen
        $cmdArguments = '/k "echo =============================================== && echo DATEV-Toolbox 2.0 - Gruppenrichtlinien-Update && echo =============================================== && echo. && echo Starte Gruppenrichtlinien-Update... && echo. && gpupdate /force && echo. && echo =============================================== && echo Gruppenrichtlinien-Update abgeschlossen! && echo =============================================== && echo. && echo Fenster kann geschlossen werden. && pause"'
        
        # CMD-Fenster starten
        Start-Process -FilePath "cmd.exe" -ArgumentList $cmdArguments -WindowStyle Normal
        
        Write-Log -Message "Gruppenrichtlinien-Update in separater CMD gestartet" -Level 'INFO'
        
        # Benutzer informieren
        [System.Windows.MessageBox]::Show(
            "Das Gruppenrichtlinien-Update wurde in einem separaten CMD-Fenster gestartet.`n`nDas Fenster zeigt den Fortschritt an und kann nach Abschluss geschlossen werden.",
            "Gruppenrichtlinien-Update gestartet",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Information
        )
        
    }
    catch {
        Write-Log -Message "Fehler beim Starten des Gruppenrichtlinien-Updates: $($_.Exception.Message)" -Level 'ERROR'
        [System.Windows.MessageBox]::Show(
            "Fehler beim Starten des Gruppenrichtlinien-Updates:`n$($_.Exception.Message)",
            "Fehler",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error
        )
    }
}

# Funktion zum Öffnen der Windows Updates
function Start-WindowsUpdates {
    <#
    .SYNOPSIS
    Öffnet Windows Updates - funktioniert sowohl auf Client- als auch Server-Versionen
    .DESCRIPTION
    Versucht verschiedene Methoden, um Windows Updates zu öffnen:
    1. Moderne Settings-App (Windows 10/11 Client)
    2. Legacy Control Panel (Windows Server, ältere Versionen)
    3. PowerShell-Module als Fallback
    #>
    try {
        Write-Log -Message "Öffne Windows Updates..." -Level 'INFO'
        
        # Betriebssystem-Info abrufen
        $os = Get-WmiObject -Class Win32_OperatingSystem
        $isServer = $os.ProductType -ne 1  # 1 = Workstation, 2 = Domain Controller, 3 = Server
        $osVersion = [Environment]::OSVersion.Version
        
        $success = $false
        
        # Methode 1: Moderne Settings-App (bevorzugt für Windows 10/11 Client)
        if (-not $isServer -and $osVersion.Major -ge 10) {
            try {
                Write-Log -Message "Versuche moderne Settings-App (ms-settings:windowsupdate)..." -Level 'DEBUG'
                Start-Process "ms-settings:windowsupdate"
                $success = $true
                Write-Log -Message "Windows Updates über Settings-App geöffnet" -Level 'INFO'
            }
            catch {
                Write-Log -Message "Settings-App nicht verfügbar: $($_.Exception.Message)" -Level 'DEBUG'
            }
        }
        
        # Methode 2: Legacy Control Panel (Windows Server, ältere Versionen)
        if (-not $success) {
            try {
                Write-Log -Message "Versuche Control Panel (wuapp.exe)..." -Level 'DEBUG'
                if (Get-Command "wuapp.exe" -ErrorAction SilentlyContinue) {
                    Start-Process "wuapp.exe"
                    $success = $true
                    Write-Log -Message "Windows Updates über wuapp.exe geöffnet" -Level 'INFO'
                }
            }
            catch {
                Write-Log -Message "wuapp.exe nicht verfügbar: $($_.Exception.Message)" -Level 'DEBUG'
            }
        }
        
        # Methode 3: Control Panel Applet (Universal-Fallback)
        if (-not $success) {
            try {
                Write-Log -Message "Versuche Control Panel Applet..." -Level 'DEBUG'
                Start-Process "control.exe" -ArgumentList "/name Microsoft.WindowsUpdate"
                $success = $true
                Write-Log -Message "Windows Updates über Control Panel geöffnet" -Level 'INFO'
            }
            catch {
                Write-Log -Message "Control Panel Applet nicht verfügbar: $($_.Exception.Message)" -Level 'DEBUG'
            }
        }
        
        # Methode 4: PowerShell-Module Hinweis (letzte Option)
        if (-not $success) {
            $message = if ($isServer) {
                "Windows Updates konnten nicht automatisch geöffnet werden.`n`n" +
                "Auf Windows Server können Sie Windows Updates folgendermaßen verwalten:`n" +
                "• Server Manager → Tools → Windows Update`n" +
                "• PowerShell: Get-WindowsUpdate, Install-WindowsUpdate`n" +
                "• WSUS/SCCM falls konfiguriert`n`n" +
                "Oder öffnen Sie die Systemsteuerung manuell und suchen nach 'Windows Update'."
            }
            else {
                "Windows Updates konnten nicht automatisch geöffnet werden.`n`n" +
                "Bitte öffnen Sie Windows Updates manuell über:`n" +
                "• Einstellungen → Update und Sicherheit → Windows Update`n" +
                "• Systemsteuerung → Windows Update`n" +
                "• Suche: 'Windows Update' in der Taskleiste"
            }
            
            [System.Windows.MessageBox]::Show(
                $message,
                "Windows Updates",
                [System.Windows.MessageBoxButton]::OK,
                [System.Windows.MessageBoxImage]::Information
            )
            Write-Log -Message "Windows Updates konnten nicht automatisch geöffnet werden - Benutzer informiert" -Level 'WARN'
        }
        
    }
    catch {
        Write-Log -Message "Fehler beim Öffnen von Windows Updates: $($_.Exception.Message)" -Level 'ERROR'
        [System.Windows.MessageBox]::Show(
            "Fehler beim Öffnen von Windows Updates:`n$($_.Exception.Message)`n`nBitte öffnen Sie Windows Updates manuell über die Systemsteuerung.",
            "Fehler",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error
        )
    }
}

# Funktion zum Anzeigen des Changelogs
function Show-ChangelogDialog {
    <#
    .SYNOPSIS
    Zeigt das Changelog der aktuellen Version und der letzten Updates in einem scrollbaren Fenster an
    #>
    $webClient = $null
    try {
        Write-Log -Message "Lade Changelog von GitHub..." -Level 'INFO'
        
        # Version-Daten von GitHub laden
        $versionUrl = $script:Config.URLs.GitHub.VersionCheck
        
        # TLS 1.2 erzwingen für sichere Downloads
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        
        $webClient = New-Object System.Net.WebClient
        $webClient.Encoding = [System.Text.Encoding]::UTF8
        
        $versionJson = $webClient.DownloadString($versionUrl)
        $versionData = $versionJson | ConvertFrom-Json
        
        # Changelog-Text zusammenstellen
        $changelogText = "DATEV-Toolbox 2.0 - Changelog`r`n"
        $changelogText += "=" * 60 + "`r`n`r`n"
        
        # Aktuelle Version
        $changelogText += "📦 Version $($versionData.version) ($(Get-Date $versionData.releaseDate -Format 'dd.MM.yyyy'))`r`n"
        $changelogText += "-" * 40 + "`r`n"
        foreach ($change in $versionData.changelog) {
            $changelogText += "• $change`r`n"
        }
        $changelogText += "`r`n"
        
        # Vorherige Versionen (maximal 10 für bessere Performance)
        if ($versionData.previousVersions) {
            $maxVersions = [Math]::Min(10, $versionData.previousVersions.Count)
            for ($i = 0; $i -lt $maxVersions; $i++) {
                $prevVersion = $versionData.previousVersions[$i]
                $changelogText += "📦 Version $($prevVersion.version) ($(Get-Date $prevVersion.releaseDate -Format 'dd.MM.yyyy'))`r`n"
                $changelogText += "-" * 40 + "`r`n"
                foreach ($change in $prevVersion.changelog) {
                    $changelogText += "• $change`r`n"
                }
                $changelogText += "`r`n"
            }
            
            # Hinweis wenn mehr Versionen verfügbar sind
            if ($versionData.previousVersions.Count -gt 10) {
                $changelogText += "... und $($versionData.previousVersions.Count - 10) weitere Versionen`r`n"
                $changelogText += "Vollständige Historie: https://github.com/Zdministrator/DATEV-Toolbox-2.0`r`n"
            }
        }
        
        # Erstelle WPF-Fenster für scrollbares Changelog
        $changelogWindow = New-Object System.Windows.Window
        $changelogWindow.Title = "DATEV-Toolbox 2.0 - Changelog"
        $changelogWindow.Width = 800
        $changelogWindow.Height = 600
        $changelogWindow.WindowStartupLocation = "CenterOwner"
        $changelogWindow.Owner = $window
        $changelogWindow.ResizeMode = "CanResize"
        $changelogWindow.MinWidth = 600
        $changelogWindow.MinHeight = 400
        
        # Grid-Layout erstellen
        $grid = New-Object System.Windows.Controls.Grid
        $grid.Margin = "10"
        
        # Zwei Zeilen: TextBox und Button
        $row1 = New-Object System.Windows.Controls.RowDefinition
        $row1.Height = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star)
        $row2 = New-Object System.Windows.Controls.RowDefinition
        $row2.Height = New-Object System.Windows.GridLength(40)
        
        $grid.RowDefinitions.Add($row1)
        $grid.RowDefinitions.Add($row2)
        
        # Scrollbare TextBox für Changelog
        $textBox = New-Object System.Windows.Controls.TextBox
        $textBox.Text = $changelogText
        $textBox.IsReadOnly = $true
        $textBox.TextWrapping = "Wrap"
        $textBox.VerticalScrollBarVisibility = "Auto"
        $textBox.HorizontalScrollBarVisibility = "Auto"
        $textBox.FontFamily = "Consolas, Courier New, monospace"
        $textBox.FontSize = 12
        $textBox.Margin = "0,0,0,10"
        $textBox.Padding = "10"
        $textBox.Background = "#F8F8F8"
        
        [System.Windows.Controls.Grid]::SetRow($textBox, 0)
        $grid.Children.Add($textBox)
        
        # Schließen-Button
        $closeButton = New-Object System.Windows.Controls.Button
        $closeButton.Content = "Schließen"
        $closeButton.Width = 100
        $closeButton.Height = 30
        $closeButton.HorizontalAlignment = "Right"
        $closeButton.VerticalAlignment = "Top"
        $closeButton.Add_Click({
                $changelogWindow.Close()
            })
        
        [System.Windows.Controls.Grid]::SetRow($closeButton, 1)
        $grid.Children.Add($closeButton)
        
        # Grid zum Fenster hinzufügen
        $changelogWindow.Content = $grid
        
        # Fenster anzeigen
        $changelogWindow.ShowDialog() | Out-Null
        
        Write-Log -Message "Changelog erfolgreich angezeigt" -Level 'INFO'
        
    }
    catch {
        Write-Log -Message "Fehler beim Laden des Changelogs: $($_.Exception.Message)" -Level 'ERROR'
        [System.Windows.MessageBox]::Show(
            "Fehler beim Laden des Changelogs von GitHub:`n$($_.Exception.Message)`n`nPrüfen Sie Ihre Internetverbindung.",
            "Fehler",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error
        )
    }
    finally {
        # WebClient ordnungsgemäß entsorgen (immer ausführen)
        if ($null -ne $webClient) {
            try {
                $webClient.Dispose()
                Write-Log -Message "WebClient ordnungsgemäß disposed" -Level 'DEBUG'
            }
            catch {
                Write-Log -Message "Fehler beim Entsorgen des WebClients: $($_.Exception.Message)" -Level 'WARN'
            }
        }
    }
}
#endregion

#region Update- und Versionsverwaltung
# Update-Check und -Management Funktionen
# Funktion zum Bereinigen alter Update-Backups (behält nur die letzten 5)
function Clear-OldUpdateBackups {
    try {
        $updateDir = $script:Config.Paths.Updates
        if (-not (Test-Path $updateDir)) {
            return
        }
        
        # Alle Backup-Dateien finden und nach Datum sortieren
        $backupFiles = Get-ChildItem -Path $updateDir -Filter "*.backup" | Sort-Object CreationTime -Descending
        
        # Nur die konfigurierten Anzahl behalten, den Rest löschen
        if ($backupFiles.Count -gt $script:Config.Limits.MaxBackups) {
            $filesToDelete = $backupFiles | Select-Object -Skip $script:Config.Limits.MaxBackups
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
        $versionInfo = Invoke-RestMethod -Uri $script:UpdateCheckUrl -TimeoutSec $script:Config.Timeouts.UpdateCheck -UseBasicParsing
        
        # PowerShell 5.1 Kompatibilität: Sicherstellen, dass wir ein einzelnes Objekt haben
        if ($versionInfo -is [Array] -and $versionInfo.Count -gt 0) {
            $versionInfo = $versionInfo[0]
        }
        
        $currentVersion = Get-CurrentVersion
        $remoteVersion = $versionInfo.version
        
        Write-Log -Message "Aktuelle Version: $currentVersion, Verfügbare Version: $remoteVersion" -Level 'INFO'
        
        if ([string]::IsNullOrEmpty($remoteVersion)) {
            throw "Remote-Version konnte nicht gelesen werden"
        }
        
        $comparison = Compare-Version -Version1 $currentVersion -Version2 $remoteVersion
        
        if ($comparison -lt 0) {
            # Update verfügbar
            if (-not $Silent) {
                Write-Log -Message "Update verfügbar: Version $remoteVersion" -Level 'INFO'
            }
            return @{
                UpdateAvailable = $true
                CurrentVersion  = $currentVersion
                NewVersion      = $remoteVersion
                VersionInfo     = $versionInfo
            }
        }
        else {
            if (-not $Silent) {
                Write-Log -Message "Sie verwenden bereits die neueste Version" -Level 'INFO'
            }
            return @{
                UpdateAvailable = $false
                CurrentVersion  = $currentVersion
                NewVersion      = $remoteVersion
                VersionInfo     = $versionInfo
            }
        }
    }
    catch {
        Write-Log -Message "Fehler beim Prüfen auf Updates: $($_.Exception.Message)" -Level 'ERROR'
        return @{
            UpdateAvailable = $false
            Error           = $_.Exception.Message
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
        }
        else { "" }
        
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
# Update-Prozess-Hilfsfunktionen
function New-UpdatePaths {
    <#
    .SYNOPSIS
    Erstellt die benötigten Pfade für den Update-Prozess
    #>
    param(
        [Parameter(Mandatory = $true)][hashtable]$UpdateInfo,
        [Parameter(Mandatory = $true)][string]$CurrentScriptPath
    )
    
    $updateDir = $script:Config.Paths.Updates
    if (-not (Test-Path $updateDir)) {
        New-Item -Path $updateDir -ItemType Directory -Force | Out-Null
        Write-Log -Message "Update-Verzeichnis erstellt: $updateDir" -Level 'INFO'
    }
    
    $timestamp = (Get-Date).ToString('yyyyMMdd-HHmmss')
    return @{
        UpdateDir       = $updateDir
        BackupPath      = Join-Path $updateDir "DATEV-Toolbox-$timestamp.backup"
        TempUpdatePath  = Join-Path $updateDir "DATEV-Toolbox-$($UpdateInfo.NewVersion).download"
        UpdateBatchPath = Join-Path $updateDir "Update-$timestamp.bat"
        Timestamp       = $timestamp
    }
}

function Test-DownloadedFile {
    <#
    .SYNOPSIS
    Prüft die Integrität und Syntax der heruntergeladenen Update-Datei
    #>
    param(
        [Parameter(Mandatory = $true)][string]$FilePath
    )
    
    $downloadedFile = Get-Item $FilePath
    if ($downloadedFile.Length -lt $script:Config.Limits.MinFileSize) {
        throw "Heruntergeladene Datei ist zu klein ($($downloadedFile.Length) Bytes) und möglicherweise beschädigt"
    }
    
    # PowerShell-Syntax-Check der heruntergeladenen Datei
    try {
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $FilePath -Raw), [ref]$null)
        Write-Log -Message "PowerShell-Syntax-Prüfung der heruntergeladenen Datei erfolgreich" -Level 'INFO'
        return $true
    }
    catch {
        throw "Heruntergeladene Datei hat ungültige PowerShell-Syntax: $($_.Exception.Message)"
    }
}

function New-UpdateBatchScript {
    <#
    .SYNOPSIS
    Erstellt das Batch-Skript für die verzögerte Update-Installation
    #>
    param(
        [Parameter(Mandatory = $true)][hashtable]$UpdateInfo,
        [Parameter(Mandatory = $true)][hashtable]$Paths,
        [Parameter(Mandatory = $true)][string]$CurrentScriptPath
    )
    
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
copy "$CurrentScriptPath" "$($Paths.BackupPath)" >nul
if errorlevel 1 (
    echo FEHLER: Backup konnte nicht erstellt werden!
    echo Aktuelle Datei: $CurrentScriptPath
    echo Backup-Ziel: $($Paths.BackupPath)
    pause
    exit /b 1
)
echo Backup erfolgreich erstellt: $($Paths.BackupPath)

echo [3/5] Installiere neue Version...
copy "$($Paths.TempUpdatePath)" "$CurrentScriptPath" >nul
if errorlevel 1 (
    echo FEHLER: Installation der neuen Version fehlgeschlagen!
    echo Stelle Backup wieder her...
    copy "$($Paths.BackupPath)" "$CurrentScriptPath" >nul
    if errorlevel 1 (
        echo KRITISCHER FEHLER: Rollback fehlgeschlagen!
        echo Backup manuell wiederherstellen: $($Paths.BackupPath)
        pause
        exit /b 2
    )
    echo Rollback erfolgreich.
    pause
    exit /b 1
)
echo Installation erfolgreich.

echo [4/5] Bereinige temporäre Dateien...
del "$($Paths.TempUpdatePath)" >nul 2>&1

echo [5/5] Starte DATEV-Toolbox neu...
echo.
echo Update auf Version $($UpdateInfo.NewVersion) erfolgreich installiert!

REM Versuche zuerst pwsh.exe (PowerShell 7+), dann powershell.exe (PowerShell 5.1)
where pwsh.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo Starte mit PowerShell 7+ ^(pwsh.exe^)...
    start "" pwsh.exe -File "$CurrentScriptPath"
) else (
    echo PowerShell 7+ nicht gefunden, verwende PowerShell 5.1 ^(powershell.exe^)...
    start "" powershell.exe -File "$CurrentScriptPath"
)

echo.
echo Bereinige Update-Skript in 5 Sekunden...
timeout /t 5 /nobreak >nul
del "%~f0" >nul 2>&1
"@
    
    Set-Content -Path $Paths.UpdateBatchPath -Value $batchContent -Encoding ASCII
    Write-Log -Message "Update-Batch-Skript erstellt: $($Paths.UpdateBatchPath)" -Level 'INFO'
}

function Update-SettingsForUpdate {
    <#
    .SYNOPSIS
    Aktualisiert die Einstellungen mit Update-Informationen
    #>
    param(
        [Parameter(Mandatory = $true)][hashtable]$UpdateInfo,
        [Parameter(Mandatory = $true)][string]$BackupPath
    )
    
    # Update-Einstellungen speichern (PSObject sicher in Hashtable konvertieren)
    $settingsHash = @{}
    if ($script:Settings -is [PSCustomObject]) {
        foreach ($property in $script:Settings.PSObject.Properties) {
            $settingsHash[$property.Name] = $property.Value
        }
    }
    else {
        $settingsHash = $script:Settings
    }
    
    $settingsHash.lastUpdateCheck = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
    $settingsHash.lastInstalledVersion = $UpdateInfo.NewVersion
    $settingsHash.lastBackupPath = $BackupPath
    # Update-History als Array initialisieren oder erweitern
    if (-not $settingsHash.updateHistory) {
        $settingsHash.updateHistory = @()
    }
    
    # Neuen Eintrag zur Update-History hinzufügen
    $newHistoryEntry = @{
        version    = $UpdateInfo.NewVersion
        date       = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
        backupPath = $BackupPath
    }
    
    # Array erweitern (PowerShell 5.1 kompatibel)
    $currentHistory = $settingsHash.updateHistory
    if ($currentHistory -is [array]) {
        $settingsHash.updateHistory = $currentHistory + $newHistoryEntry
    }
    else {
        $settingsHash.updateHistory = @($currentHistory, $newHistoryEntry)
    }
    
    # Einstellungen in globale Variable übertragen und speichern
    $script:Settings = $settingsHash
    Save-Settings
    Write-Log -Message "Update-Einstellungen gespeichert" -Level 'INFO'
}

function Remove-UpdateTemporaryFiles {
    <#
    .SYNOPSIS
    Bereinigt temporäre Update-Dateien bei Fehlern
    #>
    param(
        [Parameter(Mandatory = $true)][string[]]$FilePaths
    )
    
    foreach ($file in $FilePaths) {
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
}

function Start-UpdateProcess {
    <#
    .SYNOPSIS
    Führt den Update-Prozess für die DATEV-Toolbox durch
    .DESCRIPTION
    Modularisierte und optimierte Version des Update-Prozesses
    #>
    param(
        [Parameter(Mandatory = $true)][hashtable]$UpdateInfo
    )
    
    try {
        Write-Log -Message "Starte Update-Prozess für Version $($UpdateInfo.NewVersion)..." -Level 'INFO'
        
        # Aktuellen Script-Pfad ermitteln
        $currentScriptPath = $MyInvocation.ScriptName
        if ([string]::IsNullOrEmpty($currentScriptPath)) {
            $currentScriptPath = $PSCommandPath
        }
        if ([string]::IsNullOrEmpty($currentScriptPath)) {
            throw "Kann den aktuellen Skript-Pfad nicht ermitteln"
        }
        
        # Update-Pfade erstellen
        $paths = New-UpdatePaths -UpdateInfo $UpdateInfo -CurrentScriptPath $currentScriptPath
        Write-Log -Message "Update-Pfade erstellt: Backup=$($paths.BackupPath), Download=$($paths.TempUpdatePath)" -Level 'INFO'
        
        # TLS 1.2 für sichere Downloads erzwingen
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        
        # Neue Version herunterladen
        Write-Log -Message "Lade neue Version herunter nach: $($paths.TempUpdatePath)" -Level 'INFO'
        Invoke-WebRequest -Uri $UpdateInfo.VersionInfo.downloadUrl -OutFile $paths.TempUpdatePath -UseBasicParsing -TimeoutSec $script:Config.Timeouts.FileDownload
        
        # Heruntergeladene Datei validieren
        Test-DownloadedFile -FilePath $paths.TempUpdatePath
        $downloadedFile = Get-Item $paths.TempUpdatePath
        Write-Log -Message "Download erfolgreich ($($downloadedFile.Length) Bytes). Erstelle Update-Skript..." -Level 'INFO'
        
        # Update-Batch-Skript erstellen
        New-UpdateBatchScript -UpdateInfo $UpdateInfo -Paths $paths -CurrentScriptPath $currentScriptPath
        
        # Einstellungen für Update vorbereiten
        Update-SettingsForUpdate -UpdateInfo $UpdateInfo -BackupPath $paths.BackupPath
        
        # Alte Backups bereinigen
        Clear-OldUpdateBackups
        
        # Update-Prozess starten
        Write-Log -Message "Update wird angewendet. Anwendung wird neu gestartet..." -Level 'INFO'
        Write-Log -Message "Backup wird erstellt unter: $($paths.BackupPath)" -Level 'INFO'
        Write-Log -Message "Starte Update-Batch-Skript: $($paths.UpdateBatchPath)" -Level 'INFO'
        
        Start-Process -FilePath $paths.UpdateBatchPath -WindowStyle Normal
        
        # Kurz warten und dann Fenster schließen
        Start-Sleep -Milliseconds 500
        $window.Close()
        
        return $true
    }
    catch {
        Write-Log -Message "Fehler beim Update-Prozess: $($_.Exception.Message)" -Level 'ERROR'
        
        # Temporäre Dateien bereinigen
        if ($paths) {
            Remove-UpdateTemporaryFiles -FilePaths @($paths.TempUpdatePath, $paths.UpdateBatchPath)
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
        if ($null -eq $script:Settings) {
            Initialize-Settings
        }
        $checkInterval = $script:Config.Timeouts.UpdateInterval # Stunden
        # Letzten Check-Zeitpunkt prüfen
        $lastCheck = $null
        if ($script:Settings.lastUpdateCheck) {
            try {
                $lastCheck = [DateTime]::Parse($script:Settings.lastUpdateCheck)
            }
            catch {
                Write-Log -Message "Ungültiger lastUpdateCheck Wert, setze zurück" -Level 'WARN'
            }
        }
        
        $shouldCheck = $false
        if ($null -eq $lastCheck) {
            $shouldCheck = $true
            Write-Log -Message "Erster Update-Check wird durchgeführt" -Level 'DEBUG'
        }
        elseif ($lastCheck.AddHours($checkInterval) -lt (Get-Date)) {
            $shouldCheck = $true
            Write-Log -Message "Update-Check-Intervall erreicht (alle $checkInterval Stunden)" -Level 'DEBUG'
        }
        if ($shouldCheck) {
            # Stillen Update-Check durchführen
            $updateInfo = Test-ForUpdates -Silent
              
            # PowerShell 5.1 Kompatibilität: Array zu Hashtable konvertieren
            if ($updateInfo -is [Array] -and $updateInfo.Count -gt 0) {
                $updateInfo = $updateInfo[0]
            }
              
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
            # Letzten Check-Zeitpunkt aktualisieren
            Set-Setting -Key "lastUpdateCheck" -Value (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
        }
        else {
            Write-Log -Message "Update-Check übersprungen (letzter Check: $($lastCheck.ToString('yyyy-MM-dd HH:mm')))" -Level 'DEBUG'
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
        
        # PowerShell 5.1 Kompatibilität: Array zu Hashtable konvertieren
        if ($updateInfo -is [Array] -and $updateInfo.Count -gt 0) {
            # Suche nach dem korrekten Hashtable-Element im Array
            $correctElement = $null
            for ($i = 0; $i -lt $updateInfo.Count; $i++) {
                $element = $updateInfo[$i]
                if ($element -is [hashtable] -and $element.ContainsKey('UpdateAvailable')) {
                    $correctElement = $element
                    break
                }
            }
            
            if ($null -ne $correctElement) {
                $updateInfo = $correctElement
            }
            else {
                Write-Log -Message "Kein korrektes Hashtable-Element im Array gefunden" -Level 'ERROR'
                $updateInfo = $updateInfo[0]
            }
        }
        
        if ($updateInfo.UpdateAvailable) {
            Write-Log -Message "DIAGNOSE: Update verfügbar - zeige Dialog" -Level 'DEBUG'
            $userWantsUpdate = Show-UpdateDialog -UpdateInfo $updateInfo
            
            if ($userWantsUpdate) {
                Start-UpdateProcess -UpdateInfo $updateInfo
            }
        }
        else {
            # Prüfen warum kein Update verfügbar ist
            if ($updateInfo.Error) {
                [System.Windows.MessageBox]::Show(
                    "Fehler beim Update-Check:`n$($updateInfo.Error)`n`nPrüfen Sie Ihre Internetverbindung und versuchen Sie es erneut.",
                    "Update-Check fehlgeschlagen",
                    [System.Windows.MessageBoxButton]::OK,
                    [System.Windows.MessageBoxImage]::Error
                )
            }
            elseif ([string]::IsNullOrEmpty($updateInfo.CurrentVersion) -or [string]::IsNullOrEmpty($updateInfo.NewVersion)) {
                [System.Windows.MessageBox]::Show(
                    "Update-Check unvollständig:`nAktuelle Version: '$($updateInfo.CurrentVersion)'`nVerfügbare Version: '$($updateInfo.NewVersion)'`n`nMöglicherweise besteht ein Netzwerkproblem.",
                    "Update-Check unvollständig",
                    [System.Windows.MessageBoxButton]::OK,
                    [System.Windows.MessageBoxImage]::Warning
                )
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
    }
    catch {
        Write-Log -Message "DIAGNOSE: Exception in Start-ManualUpdateCheck: $($_.Exception.Message)" -Level 'ERROR'
        Write-Log -Message "Fehler beim manuellen Update-Check: $($_.Exception.Message)" -Level 'ERROR'
        
        [System.Windows.MessageBox]::Show(
            "Unerwarteter Fehler beim Update-Check:`n$($_.Exception.Message)",
            "Fehler",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error
        )
    }
}
#endregion

#region Download- und Datei-Management
# DATEV Downloads und Dateimanagement
# Funktion zum Laden der DATEV Downloads aus datev-downloads.json
function Get-DATEVDownloads {
    try {
        # Nur im AppData-Ordner suchen
        $appDataFile = $script:Config.Paths.DownloadsJSON
        
        if (Test-Path $appDataFile) {
            $json = Get-Content -Path $appDataFile -Raw -Encoding UTF8
            $downloadsData = $json | ConvertFrom-Json
            Write-Log -Message "DATEV Downloads erfolgreich aus AppData geladen" -Level 'DEBUG'
            
            # Rückgabe als Hashtable mit Downloads und lastUpdated
            return @{
                downloads   = $downloadsData.downloads
                lastUpdated = $downloadsData.lastUpdated
            }
        }
        else {
            Write-Log -Message "Keine datev-downloads.json im AppData-Ordner gefunden. Bitte erst aktualisieren." -Level 'WARN'
            return @{
                downloads   = @()
                lastUpdated = $null
            }
        }
    }
    catch {
        Write-Log -Message "Fehler beim Laden der DATEV Downloads: $($_.Exception.Message)" -Level 'ERROR'
        return @{
            downloads   = @()
            lastUpdated = $null
        }
    }
}

# Funktion zum Aktualisieren der datev-downloads.json aus GitHub
function Update-DATEVDownloads {
    $downloadsUrl = $script:Config.URLs.GitHub.DownloadsConfig
    $localFile = $script:Config.Paths.DownloadsJSON
    
    Write-Log -Message "Benutzeraktion: Direkt-Downloads aktualisieren geklickt. Lade JSON von $downloadsUrl" -Level 'DEBUG'
    
    try {
        # Verzeichnis erstellen falls es nicht existiert
        $downloadsDir = $script:Config.Paths.AppData
        if (-not (Test-Path $downloadsDir)) {
            New-Item -Path $downloadsDir -ItemType Directory -Force | Out-Null
            Write-Log -Message "Downloads-Verzeichnis erstellt: $downloadsDir" -Level 'DEBUG'
        }
        
        # Button während Download deaktivieren
        if ($null -ne $btnUpdateDownloads) {
            $btnUpdateDownloads.IsEnabled = $false
        }
        
        # TLS 1.2 für sichere Downloads erzwingen
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        
        # JSON-Datei herunterladen
        Invoke-WebRequest -Uri $downloadsUrl -OutFile $localFile -UseBasicParsing -TimeoutSec $script:Config.Timeouts.DownloadJSON
        
        Write-Log -Message "Downloads-JSON erfolgreich aktualisiert: $localFile" -Level 'DEBUG'
        
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
        # Prüfen ob ComboBox verfügbar ist
        if ($null -eq $cmbDirectDownloads) {
            Write-Log -Message "ComboBox 'cmbDirectDownloads' nicht verfügbar, überspringe Initialisierung" -Level 'WARN'
            return
        }
        
        # Event-Handler Memory Leak Fix: Handler neu registrieren
        if ($script:ComboBoxEventRegistered -and $null -ne $script:ComboBoxHandler) {
            $cmbDirectDownloads.Remove_SelectionChanged($script:ComboBoxHandler)
            Write-Log -Message "ComboBox Event-Handler für Neuinitialisierung entfernt" -Level 'DEBUG'
        }
        
        $downloadsData = Get-DATEVDownloads
        $downloads = $downloadsData.downloads
        $lastUpdated = $downloadsData.lastUpdated
        
        $cmbDirectDownloads.Items.Clear()
        
        # Platzhalter-Element mit Datum hinzufügen
        $placeholderItem = New-Object System.Windows.Controls.ComboBoxItem
        if ($lastUpdated) {
            # Datum in deutsches Format konvertieren
            try {
                $dateObj = [DateTime]::ParseExact($lastUpdated, 'yyyy-MM-dd', $null)
                $germanDate = $dateObj.ToString('dd.MM.yyyy')
                $placeholderItem.Content = "Download auswählen... (Stand: $germanDate)"
            }
            catch {
                $placeholderItem.Content = "Download auswählen... (Stand: $lastUpdated)"
            }
        }
        else {
            $placeholderItem.Content = "Download auswählen..."
        }
        $placeholderItem.IsEnabled = $false
        $placeholderItem.Foreground = "Gray"
        $cmbDirectDownloads.Items.Add($placeholderItem) | Out-Null
        
        foreach ($download in $downloads) {
            $item = New-Object System.Windows.Controls.ComboBoxItem
            $item.Content = $download.name
            $item.Tag = @{
                url          = $download.url
                description  = $download.description
                erschienen   = $download.erschienen
                dateiname    = $download.dateiname
                dateigroesse = $download.dateigroesse
            }
            $cmbDirectDownloads.Items.Add($item) | Out-Null
        }
        
        # Platzhalter als Standardauswahl setzen
        $cmbDirectDownloads.SelectedIndex = 0
        
        # Event-Handler neu registrieren nach Initialisierung
        if ($null -ne $script:ComboBoxHandler) {
            $cmbDirectDownloads.Add_SelectionChanged($script:ComboBoxHandler)
            $script:ComboBoxEventRegistered = $true
            Write-Log -Message "ComboBox Event-Handler nach Initialisierung neu registriert" -Level 'DEBUG'
        }
        
        if ($cmbDirectDownloads.Items.Count -gt 1) {
            Write-Log -Message "$($cmbDirectDownloads.Items.Count - 1) Downloads geladen" -Level 'DEBUG'
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
    
    $webClient = $null
    try {
        # Download-Ordner erstellen
        $downloadFolder = $script:Config.Paths.Downloads
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
        
        # WebClient für Download erstellen (PowerShell 5.1 kompatibel)
        $webClient = New-Object System.Net.WebClient
        # Hinweis: WebClient in PowerShell 5.1 hat keine Timeout-Eigenschaft
        # Standard-Timeout wird verwendet (ca. 100 Sekunden)
        
        # Event-Handler für Download-Completion (mit verbessertem Disposal)
        $webClient.add_DownloadFileCompleted({
                param($webClientSender, $downloadEventArgs)
            
                try {
                    # Dateiname aus UserState extrahieren
                    $currentFileName = if ($downloadEventArgs.UserState) { $downloadEventArgs.UserState } else { "unbekannte Datei" }
                
                    if ($null -eq $downloadEventArgs.Error -and -not $downloadEventArgs.Cancelled) {
                        Write-Log -Message "Download erfolgreich abgeschlossen: $currentFileName" -Level 'INFO'
                    
                        # Optional: Download-Ordner öffnen bei erfolgreichem Download
                        $result = [System.Windows.MessageBox]::Show(
                            "Download erfolgreich abgeschlossen: $currentFileName`n`nMöchten Sie den Download-Ordner öffnen?",
                            "Download abgeschlossen",
                            [System.Windows.MessageBoxButton]::YesNo,
                            [System.Windows.MessageBoxImage]::Information
                        )
                    
                        if ($result -eq [System.Windows.MessageBoxResult]::Yes) {
                            Open-DownloadFolder
                        }
                    }
                    elseif ($downloadEventArgs.Cancelled) {
                        Write-Log -Message "Download abgebrochen: $currentFileName" -Level 'WARN'
                    }
                    else {
                        Write-Log -Message "Download fehlgeschlagen: $($downloadEventArgs.Error.Message)" -Level 'ERROR'
                        [System.Windows.MessageBox]::Show(
                            "Download fehlgeschlagen: $currentFileName`n`nFehler: $($downloadEventArgs.Error.Message)",
                            "Download-Fehler",
                            [System.Windows.MessageBoxButton]::OK,
                            [System.Windows.MessageBoxImage]::Error
                        )
                    }
                }
                catch {
                    Write-Log -Message "Fehler im Download-Completion-Handler: $($_.Exception.Message)" -Level 'ERROR'
                }
                finally {
                    # UI zurücksetzen (immer ausführen)
                    try {
                        $btnDownload.IsEnabled = $true
                    }
                    catch {
                        Write-Log -Message "Fehler beim Zurücksetzen der UI: $($_.Exception.Message)" -Level 'WARN'
                    }
                
                    # WebClient sicher entsorgen (immer ausführen)
                    try {
                        if ($null -ne $webClientSender -and $webClientSender -is [System.Net.WebClient]) {
                            $webClientSender.Dispose()
                            Write-Log -Message "WebClient ordnungsgemäß disposed" -Level 'DEBUG'
                        }
                    }
                    catch {
                        Write-Log -Message "Fehler beim Entsorgen des WebClients: $($_.Exception.Message)" -Level 'WARN'
                    }
                }
            })
        
        # Asynchronen Download starten mit Dateiname als UserState
        $webClient.DownloadFileAsync($Url, $filePath, $FileName)
        
    }
    catch {
        Write-Log -Message "Fehler beim Starten des Downloads: $($_.Exception.Message)" -Level 'ERROR'
        
        # UI zurücksetzen bei Fehler
        try {
            $btnDownload.IsEnabled = $true
        }
        catch {
            Write-Log -Message "Fehler beim Zurücksetzen der UI nach Download-Fehler: $($_.Exception.Message)" -Level 'WARN'
        }
        
        # WebClient entsorgen falls erstellt aber nicht erfolgreich gestartet
        if ($null -ne $webClient) {
            try {
                $webClient.Dispose()
                Write-Log -Message "WebClient nach Fehler ordnungsgemäß disposed" -Level 'DEBUG'
            }
            catch {
                Write-Log -Message "Fehler beim Entsorgen des WebClients nach Hauptfehler: $($_.Exception.Message)" -Level 'WARN'
            }
        }
        
        # Benutzer über Fehler informieren
        [System.Windows.MessageBox]::Show(
            "Fehler beim Starten des Downloads:`n$($_.Exception.Message)",
            "Download-Fehler",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error
        )
    }
}
#endregion

# Ordner-Management Funktionen
# Funktion zum Öffnen des Download-Ordners im Explorer
function Open-DownloadFolder {
    try {
        $downloadFolder = $script:Config.Paths.Downloads
        
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

function Open-EmailClient {
    <#
    .SYNOPSIS
    Öffnet den Standard E-Mail-Client mit vorbefüllter E-Mail für Dokument-Vorschläge
    
    .DESCRIPTION
    Diese Funktion öffnet eine neue E-Mail im Standard E-Mail-Client mit der Zieladresse 
    und einem vorausgefüllten Betreff für Dokument-Vorschläge.
    #>
    try {
        $emailAddress = "norman.zamponi@hees.de"
        $subject = "DATEV-Toolbox - Dokument-Vorschlag"
        $body = "Hallo,%0D%0A%0D%0AIch hätte gerne folgenden Vorschlag für ein zusätzliches DATEV-Dokument in der Toolbox:%0D%0A%0D%0ATitel:%0D%0AURL:%0D%0ABeschreibung:%0D%0A%0D%0AVielen Dank!"
        
        $mailtoUrl = "mailto:$emailAddress?subject=$subject&body=$body"
        
        Start-Process $mailtoUrl
        Write-Log -Message "E-Mail-Client für Dokument-Vorschlag geöffnet" -Level 'INFO'
    }
    catch {
        Write-Log -Message "Fehler beim Öffnen des E-Mail-Clients: $($_.Exception.Message)" -Level 'ERROR'
        [System.Windows.MessageBox]::Show("Fehler beim Öffnen des E-Mail-Clients. Bitte senden Sie Ihre Vorschläge direkt an: norman.zamponi@hees.de", "E-Mail-Fehler", "OK", "Warning")
    }
}
#endregion

#region Dokumente-Management
# Funktionen für das Verwalten und Anzeigen von DATEV-Dokumenten

function Get-DATEVDocuments {
    <#
    .SYNOPSIS
    Lädt die DATEV-Dokumente aus der lokalen JSON-Datei oder GitHub
    #>
    try {
        $documentsPath = Join-Path $script:Config.Paths.AppData "datev-dokumente.json"
        
        # Prüfen ob lokale Datei existiert
        if (Test-Path $documentsPath) {
            $jsonContent = Get-Content $documentsPath -Raw -Encoding UTF8
            $documentsData = $jsonContent | ConvertFrom-Json
            
            # Konvertiere PSObject zu Hashtable für bessere Handhabung
            $documents = @()
            foreach ($doc in $documentsData.documents) {
                $documents += @{
                    id          = $doc.id
                    title       = $doc.title
                    url         = $doc.url  
                    description = $doc.description
                }
            }
            
            # Rückgabe-Objekt mit Dokumenten und lastUpdated
            $result = @{
                documents   = $documents
                lastUpdated = $documentsData.lastUpdated
            }
            
            Write-Log -Message "DATEV-Dokumente aus lokaler Datei geladen: $($documents.Count) Dokumente" -Level 'INFO'
            return $result
        }
        else {
            Write-Log -Message "Lokale Dokumente-Datei nicht gefunden. Lade von GitHub..." -Level 'INFO'
            return Update-DATEVDocuments
        }
    }
    catch {
        Write-Log -Message "Fehler beim Laden der DATEV-Dokumente: $($_.Exception.Message)" -Level 'ERROR'
        return @{
            documents   = @()
            lastUpdated = "Unbekannt"
        }
    }
}

function Update-DATEVDocuments {
    <#
    .SYNOPSIS
    Aktualisiert die DATEV-Dokumente von GitHub
    #>
    try {
        Write-Log -Message "Aktualisiere DATEV-Dokumente von GitHub..." -Level 'INFO'
        
        $documentsUrl = "https://github.com/Zdministrator/DATEV-Toolbox-2.0/raw/main/datev-dokumente.json"
        $documentsPath = Join-Path $script:Config.Paths.AppData "datev-dokumente.json"
        
        # TLS 1.2 für sichere Downloads erzwingen
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        $webClient = New-Object System.Net.WebClient
        $webClient.Encoding = [System.Text.Encoding]::UTF8
        
        try {
            $documentsJson = $webClient.DownloadString($documentsUrl)
            
            # Speichere die Datei lokal
            $documentsJson | Out-File -FilePath $documentsPath -Encoding UTF8 -Force
            
            # Parse und return der Dokumente
            $documentsData = $documentsJson | ConvertFrom-Json
            $documents = @()
            foreach ($doc in $documentsData.documents) {
                $documents += @{
                    id          = $doc.id
                    title       = $doc.title
                    url         = $doc.url
                    description = $doc.description
                }
            }
            
            # Rückgabe-Objekt mit Dokumenten und lastUpdated
            $result = @{
                documents   = $documents
                lastUpdated = $documentsData.lastUpdated
            }
            
            Write-Log -Message "DATEV-Dokumente erfolgreich aktualisiert: $($documents.Count) Dokumente" -Level 'INFO'
            return $result
        }
        finally {
            $webClient.Dispose()
        }
    }
    catch {
        Write-Log -Message "Fehler beim Aktualisieren der DATEV-Dokumente: $($_.Exception.Message)" -Level 'ERROR'
        return @{
            documents   = @()
            lastUpdated = "Unbekannt"
        }
    }
}

function Initialize-DocumentsList {
    <#
    .SYNOPSIS
    Initialisiert die Dokumente-Liste im GUI
    #>
    try {
        $documentsPanel = $window.FindName("spDocumentsList")
        if (-not $documentsPanel) {
            Write-Log -Message "Dokumente-Panel nicht gefunden" -Level 'WARN'
            return
        }
        
        # Panel leeren
        $documentsPanel.Children.Clear()
        
        # Lade Dokumente
        $documentsResult = Get-DATEVDocuments
        $documents = $documentsResult.documents
        $lastUpdated = $documentsResult.lastUpdated
        
        # Aktualisiere lastUpdated-Anzeige
        $lastUpdatedText = $window.FindName("txtDocumentsLastUpdated")
        if ($lastUpdatedText) {
            if ($lastUpdated -and $lastUpdated -ne "Unbekannt") {
                try {
                    # Formatiere das Datum schöner
                    $date = [DateTime]::ParseExact($lastUpdated, "yyyy-MM-dd", $null)
                    $lastUpdatedText.Text = $date.ToString("dd.MM.yyyy")
                }
                catch {
                    $lastUpdatedText.Text = $lastUpdated
                }
            }
            else {
                $lastUpdatedText.Text = "Unbekannt"
            }
        }
        
        if ($documents.Count -eq 0) {
            $noDocsText = New-Object System.Windows.Controls.TextBlock
            $noDocsText.Text = "Keine Dokumente verfügbar"
            $noDocsText.FontStyle = "Italic"
            $noDocsText.Foreground = "Gray"
            $noDocsText.Margin = "0,10,0,10"
            $documentsPanel.Children.Add($noDocsText)
            return
        }
        
        # Erstelle Links für jedes Dokument
        foreach ($doc in $documents) {
            # Titel als anklickbarer Link (ohne Container-Box)
            $titleLink = New-Object System.Windows.Controls.TextBlock
            $titleLink.Text = "$($doc.id) - $($doc.title)"
            $titleLink.Foreground = "Black"
            $titleLink.Cursor = "Hand"
            $titleLink.TextDecorations = "Underline"
            $titleLink.Tag = $doc.url
            $titleLink.ToolTip = $doc.description
            $titleLink.Margin = "0,2,0,2"
            
            # Click-Event für Titel
            $titleLink.Add_MouseLeftButtonUp({
                    param($sender, $e)
                    try {
                        $url = $sender.Tag
                        Start-Process $url
                        Write-Log -Message "DATEV-Dokument geöffnet: $($sender.Text)" -Level 'INFO'
                    }
                    catch {
                        Write-Log -Message "Fehler beim Öffnen des Dokuments: $($_.Exception.Message)" -Level 'ERROR'
                        [System.Windows.MessageBox]::Show("Fehler beim Öffnen des Dokuments: $($_.Exception.Message)", "Fehler", "OK", "Error")
                    }
                })
            
            $documentsPanel.Children.Add($titleLink)
        }
        
        Write-Log -Message "Dokumente-Liste initialisiert: $($documents.Count) Dokumente" -Level 'INFO'
    }
    catch {
        Write-Log -Message "Fehler beim Initialisieren der Dokumente-Liste: $($_.Exception.Message)" -Level 'ERROR'
    }
}

function Refresh-DocumentsList {
    <#
    .SYNOPSIS
    Aktualisiert die Dokumente-Liste durch Neuladen von GitHub
    #>
    try {
        Write-Log -Message "Aktualisiere Dokumente-Liste..." -Level 'INFO'
        
        # Aktualisiere von GitHub
        Update-DATEVDocuments | Out-Null
        
        # GUI neu initialisieren
        Initialize-DocumentsList
        
        Write-Log -Message "Dokumente-Liste erfolgreich aktualisiert" -Level 'INFO'
    }
    catch {
        Write-Log -Message "Fehler beim Aktualisieren der Dokumente-Liste: $($_.Exception.Message)" -Level 'ERROR'
    }
}

#endregion

#region Update-Termine und Kalenderfunktionen
# Update-Termine Hilfsfunktionen
function ConvertFrom-ICSDate {
    <#
    .SYNOPSIS
    Konvertiert ICS-Datumsformat in DateTime-Objekt
    #>
    param(
        [Parameter(Mandatory = $true)][string]$ICSDate
    )
    
    try {
        if ($ICSDate.Length -eq 8) { 
            return [datetime]::ParseExact($ICSDate, 'yyyyMMdd', $null) 
        }
        elseif ($ICSDate.Length -ge 15) { 
            return [datetime]::ParseExact($ICSDate.Substring(0, 8), 'yyyyMMdd', $null) 
        }
        return $null
    }
    catch {
        return $null
    }
}

function ConvertFrom-IcsContent {
    <#
    .SYNOPSIS
    Parst ICS-Dateiinhalt robust mit Regex und extrahiert VEVENT-Einträge
    #>
    param(
        [Parameter(Mandatory = $true)][string]$ICSContent
    )
    
    try {
        # Regex, um ganze VEVENT-Blöcke zu erfassen
        $eventMatches = $ICSContent | Select-String -Pattern '(?s)BEGIN:VEVENT(.+?)END:VEVENT' -AllMatches
        
        $events = foreach ($match in $eventMatches.Matches) {
            $eventBlock = $match.Groups[1].Value
            
            # Zeilenumbrüche, die von einem Leerzeichen gefolgt werden, entfernen (folded lines)
            $unfoldedBlock = $eventBlock -replace '(?m)\r?\n\s', ''
            
            # Eigenschaften extrahieren
            $dtstart = if ($unfoldedBlock -match 'DTSTART.*?:(\d{8})') { $matches[1] } else { $null }
            $summary = if ($unfoldedBlock -match 'SUMMARY:(.+)') { $matches[1].Trim() } else { 'Unbekannter Termin' }
            $description = if ($unfoldedBlock -match 'DESCRIPTION:(.+)') { $matches[1].Trim() } else { '' }

            if ($dtstart) {
                [PSCustomObject]@{
                    DTSTART     = $dtstart
                    SUMMARY     = $summary
                    DESCRIPTION = $description.Replace('\n', [Environment]::NewLine).Replace('\,', ',')
                }
            }
        }
        return $events
    }
    catch {
        Write-Log -Message "Fehler beim Parsen des ICS-Inhalts: $($_.Exception.Message)" -Level 'ERROR'
        return @()
    }
}

function Get-UpcomingEvents {
    <#
    .SYNOPSIS
    Filtert Events nach anstehenden Terminen
    #>
    param(
        [Parameter(Mandatory = $true)][array]$Events,
        [Parameter(Mandatory = $false)][int]$MaxCount = 3
    )
    
    $now = Get-Date
    $upcoming = $Events | Where-Object {
        $parsedDate = ConvertFrom-ICSDate -ICSDate $_.DTSTART
        $parsedDate -and $parsedDate -ge $now.Date
    } | Sort-Object {
        ConvertFrom-ICSDate -ICSDate $_.DTSTART
    } | Select-Object -First $MaxCount
    
    return $upcoming
}

function Add-EventToUI {
    <#
    .SYNOPSIS
    Fügt ein Event zur UI hinzu
    #>
    param(
        [Parameter(Mandatory = $true)][PSCustomObject]$Event,
        [Parameter(Mandatory = $true)][System.Windows.Controls.StackPanel]$Container
    )
    
    $parsedDate = ConvertFrom-ICSDate -ICSDate $Event.DTSTART
    if ($parsedDate) {
        $tb = New-Object System.Windows.Controls.TextBlock
        $tb.Text = "{0:dd.MM.yyyy} - {1}" -f $parsedDate, $Event.SUMMARY
        if ($Event.DESCRIPTION) { 
            $tb.ToolTip = $Event.DESCRIPTION 
        }
        $tb.FontSize = 12
        $tb.Margin = '2'
        $Container.Children.Add($tb) | Out-Null
    }
}

# Funktion zum Anzeigen der nächsten DATEV Update-Termine aus ICS-Datei
function Show-NextUpdateDates {
    Write-Log -Message "Lese Update-Termine aus ICS-Datei..." -Level 'DEBUG'
    $icsFile = $script:Config.Paths.ICSFile
    
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
        $allEvents = ConvertFrom-IcsContent -ICSContent $icsContent
        Write-Log -Message "ICS: $($allEvents.Count) VEVENTs gefunden" -Level 'DEBUG'

        $upcoming = Get-UpcomingEvents -Events $allEvents -MaxCount 3
        Write-Log -Message "$($upcoming.Count) anstehende Termine werden angezeigt" -Level 'DEBUG'
        
        if ($upcoming.Count -eq 0) {
            Write-Log -Message "Keine anstehenden Termine gefunden" -Level 'DEBUG'
            $tb = New-Object System.Windows.Controls.TextBlock
            $tb.Text = "Keine anstehenden Termine gefunden."
            $tb.FontStyle = 'Italic'
            $tb.Foreground = 'Gray'
            $spUpdateDates.Children.Add($tb) | Out-Null
        }
        else {
            foreach ($ev in $upcoming) {
                Add-EventToUI -Event $ev -Container $spUpdateDates
                $parsedDate = ConvertFrom-ICSDate -ICSDate $ev.DTSTART
                if ($parsedDate) {
                    Write-Log -Message "Termin: $($parsedDate.ToString('dd.MM.yyyy')) - $($ev.SUMMARY)" -Level 'DEBUG'
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
    $icsFile = $script:Config.Paths.ICSFile
    
    if (Test-Path $icsFile) {
        Write-Log -Message "Vorhandene ICS-Datei gefunden. Lade Update-Termine automatisch..." -Level 'DEBUG'
        Show-NextUpdateDates
    }
    else {
        Write-Log -Message "Keine lokale ICS-Datei gefunden. Update-Termine können manuell aktualisiert werden." -Level 'DEBUG'
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
    $icsUrl = $script:Config.URLs.DATEV.Jahresplanung
    $icsFile = $script:Config.Paths.ICSFile
    
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
    
    Write-Log -Message "Benutzeraktion: Update-Termine aktualisieren geklickt. Lade ICS von $icsUrl" -Level 'DEBUG'
    
    try {
        # TLS 1.2 für sichere Downloads erzwingen
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        
        Invoke-WebRequest -Uri $icsUrl -OutFile $icsFile -UseBasicParsing -TimeoutSec $script:Config.Timeouts.ICSDownload
        
        $spUpdateDates.Children.Clear()
        $tb = New-Object System.Windows.Controls.TextBlock
        $tb.Text = "ICS-Datei geladen. Lese Termine..."
        $tb.FontStyle = 'Italic'
        $tb.Foreground = 'Blue'
        $spUpdateDates.Children.Add($tb) | Out-Null
        
        Write-Log -Message "ICS-Datei erfolgreich geladen: $icsFile" -Level 'DEBUG'
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

#region GUI-Setup und Event-Handler-Registrierung
# Initialisierung der Benutzeroberfläche und Event-Handler
# Doppelte Open-Url Funktion entfernen (bereits in Hilfsfunktionen definiert)

# Zentrale Handler-Registrierung ausführen
Write-Log -Message "Starte zentrale Button-Handler-Registrierung..." -Level 'DEBUG'
Register-ButtonHandlers -Window $window
Write-Log -Message "Zentrale Button-Handler-Registrierung abgeschlossen" -Level 'DEBUG'

# Event-Handler für DATEV Downloads ComboBox (Memory Leak Fix)
if ($null -ne $cmbDirectDownloads) {
    # Alte Event-Handler entfernen vor Neuregistrierung
    if ($script:ComboBoxEventRegistered -and $null -ne $script:ComboBoxHandler) {
        $cmbDirectDownloads.Remove_SelectionChanged($script:ComboBoxHandler)
        Write-Log -Message "Alter ComboBox Event-Handler entfernt" -Level 'DEBUG'
    }
    
    # Neuen Handler erstellen und speichern
    $script:ComboBoxHandler = {
        if ($null -ne $cmbDirectDownloads.SelectedItem -and
            $cmbDirectDownloads.SelectedIndex -gt 0 -and
            $null -ne $cmbDirectDownloads.SelectedItem.Tag) {
            $btnDownload.IsEnabled = $true
            $selectedItem = $cmbDirectDownloads.SelectedItem
            Write-Log -Message "Download ausgewählt: $($selectedItem.Content)" -Level 'DEBUG'
            
            # Beschreibung und Zusatzinformationen anzeigen wenn verfügbar
            $txtDownloadDescription = $Window.FindName('txtDownloadDescription')
            $borderDownloadDescription = $Window.FindName('borderDownloadDescription')
            if ($null -ne $txtDownloadDescription -and $null -ne $borderDownloadDescription) {
                $downloadData = $selectedItem.Tag
                
                # Inlines leeren
                $txtDownloadDescription.Inlines.Clear()
                
                # Beschreibung hinzufügen
                if (-not [string]::IsNullOrWhiteSpace($downloadData.description)) {
                    $run = New-Object System.Windows.Documents.Run
                    $run.Text = $downloadData.description
                    $txtDownloadDescription.Inlines.Add($run)
                }
                
                # Zusatzinformationen hinzufügen wenn verfügbar
                $hasAdditionalInfo = $false
                if (-not [string]::IsNullOrWhiteSpace($downloadData.erschienen) -or 
                    -not [string]::IsNullOrWhiteSpace($downloadData.dateiname) -or 
                    -not [string]::IsNullOrWhiteSpace($downloadData.dateigroesse)) {
                    $hasAdditionalInfo = $true
                }
                
                if ($hasAdditionalInfo) {
                    # Leerzeilen hinzufügen wenn Beschreibung vorhanden
                    if (-not [string]::IsNullOrWhiteSpace($downloadData.description)) {
                        $lineBreak1 = New-Object System.Windows.Documents.LineBreak
                        $lineBreak2 = New-Object System.Windows.Documents.LineBreak
                        $txtDownloadDescription.Inlines.Add($lineBreak1)
                        $txtDownloadDescription.Inlines.Add($lineBreak2)
                    }
                    
                    # Erschienen
                    if (-not [string]::IsNullOrWhiteSpace($downloadData.erschienen)) {
                        $boldRun = New-Object System.Windows.Documents.Run
                        $boldRun.Text = "Erschienen: "
                        $boldRun.FontWeight = [System.Windows.FontWeights]::Bold
                        $txtDownloadDescription.Inlines.Add($boldRun)
                        
                        $valueRun = New-Object System.Windows.Documents.Run
                        $valueRun.Text = $downloadData.erschienen
                        $txtDownloadDescription.Inlines.Add($valueRun)
                        
                        $lineBreak = New-Object System.Windows.Documents.LineBreak
                        $txtDownloadDescription.Inlines.Add($lineBreak)
                    }
                    
                    # Dateiname
                    if (-not [string]::IsNullOrWhiteSpace($downloadData.dateiname)) {
                        $boldRun = New-Object System.Windows.Documents.Run
                        $boldRun.Text = "Dateiname: "
                        $boldRun.FontWeight = [System.Windows.FontWeights]::Bold
                        $txtDownloadDescription.Inlines.Add($boldRun)
                        
                        $valueRun = New-Object System.Windows.Documents.Run
                        $valueRun.Text = $downloadData.dateiname
                        $txtDownloadDescription.Inlines.Add($valueRun)
                        
                        $lineBreak = New-Object System.Windows.Documents.LineBreak
                        $txtDownloadDescription.Inlines.Add($lineBreak)
                    }
                    
                    # Dateigröße
                    if (-not [string]::IsNullOrWhiteSpace($downloadData.dateigroesse)) {
                        $boldRun = New-Object System.Windows.Documents.Run
                        $boldRun.Text = "Dateigröße: "
                        $boldRun.FontWeight = [System.Windows.FontWeights]::Bold
                        $txtDownloadDescription.Inlines.Add($boldRun)
                        
                        $valueRun = New-Object System.Windows.Documents.Run
                        $valueRun.Text = $downloadData.dateigroesse
                        $txtDownloadDescription.Inlines.Add($valueRun)
                    }
                }
                
                # Border anzeigen wenn Inhalt vorhanden
                if ($txtDownloadDescription.Inlines.Count -gt 0) {
                    $borderDownloadDescription.Visibility = 'Visible'
                    Write-Log -Message "Beschreibung und Zusatzinformationen angezeigt für: $($selectedItem.Content)" -Level 'DEBUG'
                }
                else {
                    $borderDownloadDescription.Visibility = 'Collapsed'
                }
            }
        }
        else {
            $btnDownload.IsEnabled = $false
            # Beschreibung ausblenden wenn keine Auswahl
            $borderDownloadDescription = $Window.FindName('borderDownloadDescription')
            if ($null -ne $borderDownloadDescription) {
                $borderDownloadDescription.Visibility = 'Collapsed'
            }
        }
    }
    
    # Handler registrieren und Status merken
    $cmbDirectDownloads.Add_SelectionChanged($script:ComboBoxHandler)
    $script:ComboBoxEventRegistered = $true
    Write-Log -Message "Neuer ComboBox Event-Handler registriert" -Level 'DEBUG'
}
else {
    Write-Log -Message "ComboBox 'cmbDirectDownloads' konnte nicht gefunden werden" -Level 'WARN'
}

# Downloads-ComboBox initialisieren (nur wenn JSON-Datei vorhanden ist)
$downloadsJsonPath = $script:Config.Paths.DownloadsJSON
if (Test-Path $downloadsJsonPath) {
    Initialize-DownloadsComboBox
    Write-Log -Message "Downloads-ComboBox mit vorhandenen Daten initialisiert" -Level 'DEBUG'
}
else {
    Write-Log -Message "Keine Downloads-JSON gefunden, ComboBox bleibt leer bis zum ersten Update" -Level 'DEBUG'
}

# Dokumente-Liste initialisieren
Initialize-DocumentsList

# Settings initialisieren
Initialize-Settings

# Initialen Status der Checkbox setzen und Event-Handler registrieren
if ($null -ne $chkShowDebugLogs) {
    $chkShowDebugLogs.IsChecked = (Get-Setting -Key 'ShowDebugLogs' -DefaultValue $false)
    $chkShowDebugLogs.Add_Click({
            $isChecked = $this.IsChecked
            Set-Setting -Key 'ShowDebugLogs' -Value $isChecked
            Write-Log -Message "Debug-Meldungen werden jetzt $(if ($isChecked) { 'angezeigt' } else { 'ausgeblendet' })" -Level 'INFO'
        })
}

# Update-Termine beim Start laden (falls vorhanden)
Initialize-UpdateDates

# Automatischen Update-Check durchführen
Initialize-UpdateCheck

# Performance-Optimierungen initialisieren
Initialize-RunspacePool

# Window-Closing Event für ordnungsgemäße Bereinigung
$window.Add_Closing({
        Write-Log -Message "Anwendung wird beendet, bereinige Ressourcen..." -Level 'INFO'
    
        # Tray-Icon bereinigen
        Close-TrayIcon
    
        # Settings sofort speichern falls noch ausstehend
        if ($script:SettingsNeedSave) {
            Save-Settings
        }
    
        # Event-Handler bereinigen (Memory Leak Prevention)
        if ($script:ComboBoxEventRegistered -and $null -ne $script:ComboBoxHandler -and $null -ne $cmbDirectDownloads) {
            try {
                $cmbDirectDownloads.Remove_SelectionChanged($script:ComboBoxHandler)
                Write-Log -Message "ComboBox Event-Handler beim Cleanup entfernt" -Level 'DEBUG'
            }
            catch {
                Write-Log -Message "Fehler beim Entfernen des ComboBox Event-Handlers: $($_.Exception.Message)" -Level 'WARN'
            }
        }
    
        # Runspace-Pool schließen
        Close-RunspacePool
    
        # Thread-sichere Timer-Bereinigung
        [System.Threading.Monitor]::Enter($script:SettingsLock)
        try {
            if ($null -ne $script:SettingsSaveTimer) {
                $script:SettingsSaveTimer.Stop()
                $script:SettingsSaveTimer = $null
                Write-Log -Message "Settings-Timer thread-sicher gestoppt" -Level 'DEBUG'
            }
        }
        catch {
            Write-Log -Message "Fehler beim Thread-sicheren Timer-Stopp: $($_.Exception.Message)" -Level 'WARN'
        }
        finally {
            [System.Threading.Monitor]::Exit($script:SettingsLock)
        }
    
        Write-Log -Message "DATEV-Toolbox 2.0 ordnungsgemäß beendet" -Level 'INFO'
    })

# Window StateChanged Event für Minimize-to-Tray
$window.Add_StateChanged({
    if ($window.WindowState -eq [System.Windows.WindowState]::Minimized) {
        $window.Hide()
        $window.ShowInTaskbar = $false
        
        # Benachrichtigung anzeigen
        Show-TrayNotification -Title "DATEV-Toolbox" `
            -Message "In den Systembereich minimiert. Doppelklick zum Anzeigen." `
            -Icon 'Info' `
            -Duration 3000
        
        Write-Log -Message "Fenster in System-Tray minimiert" -Level 'DEBUG'
    }
})

# Log-Rotation beim Start durchführen (falls Error-Log zu groß ist)
Rotate-LogFile -LogFilePath $script:Config.Paths.ErrorLog -MaxSizeInMB 5 -MaxArchives 5

# Startup-Log schreiben
Write-Log -Message "DATEV-Toolbox 2.0 gestartet (Performance-optimiert)" -Level 'INFO'

# Tray-Icon initialisieren (VOR ShowDialog!)
Initialize-TrayIcon

# GUI anzeigen und auf Benutzerinteraktion warten
# Verwende Show() + Application.Run() statt ShowDialog() für Tray-Icon-Kompatibilität
$window.Show()

# WPF-Application-Loop für Tray-Icon-Support
$app = [System.Windows.Application]::Current
if ($null -eq $app) {
    $app = New-Object System.Windows.Application
}
$app.Run($window) | Out-Null
#endregion

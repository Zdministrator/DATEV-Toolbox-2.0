﻿<#
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
    Version:        2.1.4
    Autor:          Norman Zamponi
    PowerShell:     5.1+ (kompatibel)
    .NET Framework: 4.5+ (für WPF)
    
.LINK
    https://github.com/Zdministrator/DATEV-Toolbox-2.0
#>

#Requires -Version 5.1

# DATEV-Toolbox 2.0

# Version und Update-Konfiguration
$script:AppVersion = "2.1.4"
$script:AppName = "DATEV-Toolbox 2.0"
$script:GitHubRepo = "Zdministrator/DATEV-Toolbox-2.0"
$script:UpdateCheckUrl = "https://github.com/$script:GitHubRepo/raw/main/version.json"
$script:ScriptDownloadUrl = "https://github.com/$script:GitHubRepo/raw/main/DATEV-Toolbox 2.0.ps1"

#region Zentrale Konfiguration
# DATEV-Pfad-Definitionen (müssen vor ButtonMappings definiert werden)
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

# Alle URLs, Pfade und Konfigurationswerte zentral verwaltet
$script:Config = @{
    URLs = @{
        GitHub = @{
            Repository = "https://github.com/$script:GitHubRepo"
            VersionCheck = $script:UpdateCheckUrl
            ScriptDownload = $script:ScriptDownloadUrl
            DownloadsConfig = "https://github.com/$script:GitHubRepo/raw/refs/heads/main/datev-downloads.json"
        }
        DATEV = @{
            # Online-Services
            HelpCenter = "https://apps.datev.de/help-center/"
            ServiceKontakte = "https://apps.datev.de/servicekontakt-online/contacts"
            MyUpdates = "https://apps.datev.de/myupdates/home"
            MyDATEV = "https://apps.datev.de/mydatev"
            DUO = "https://duo.datev.de/"
            LAO = "https://apps.datev.de/lao"
            Lizenzverwaltung = "https://apps.datev.de/lizenzverwaltung"
            Rechteraum = "https://apps.datev.de/rechteraum"
            RVO = "https://apps.datev.de/rvo-administration"
            SmartLogin = "https://go.datev.de/smartlogin-administration"
            Bestandsmanagement = "https://apps.datev.de/mydata/"
            WeitereApps = "https://www.datev.de/web/de/mydatev/datev-cloud-anwendungen/"
            
            # Download-Bereiche
            Downloadbereich = "https://www.datev.de/download/"
            SmartDocs = "https://www.datev.de/web/de/service-und-support/software-bereitstellung/download-bereich/it-loesungen-und-security/datev-smartdocs-skripte-zur-analyse-oder-reparatur/"
            DatentraegerPortal = "https://www.datev.de/web/de/service-und-support/software-bereitstellung/datentraeger-portal/"
            
            # Update-Termine
            Jahresplanung = "https://apps.datev.de/myupdates/assets/files/Jahresplanung_2025.ics"
        }
    }
    
    Timeouts = @{
        UpdateCheck = 10
        DownloadJSON = 15
        FileDownload = 30
        ICSDownload = 15
        UpdateInterval = 24  # Stunden
        GpupdateTimeout = 2  # Minuten
    }
    
    Paths = @{
        AppData = Join-Path $env:APPDATA 'DATEV-Toolbox 2.0'
        Downloads = Join-Path $env:USERPROFILE "Downloads\DATEV-Toolbox"
        Updates = Join-Path (Join-Path $env:APPDATA 'DATEV-Toolbox 2.0') 'Updates'
        SettingsFile = Join-Path (Join-Path $env:APPDATA 'DATEV-Toolbox 2.0') 'settings.json'
        ErrorLog = Join-Path (Join-Path $env:APPDATA 'DATEV-Toolbox 2.0') 'Error-Log.txt'
        DownloadsJSON = Join-Path (Join-Path $env:APPDATA 'DATEV-Toolbox 2.0') 'datev-downloads.json'
        ICSFile = Join-Path (Join-Path $env:APPDATA 'DATEV-Toolbox 2.0') 'Jahresplanung_2025.ics'
    }
    
    Limits = @{
        MaxBackups = 5
        MinFileSize = 1000  # Bytes für Download-Validierung
        MaxUpdateRetries = 3
    }
    
    SystemTools = @{
        TaskManager = @{ Command = 'taskmgr.exe'; Description = 'Task-Manager' }
        ResourceMonitor = @{ Command = 'resmon.exe'; Description = 'Ressourcenmonitor' }
        EventViewer = @{ Command = 'eventvwr.msc'; Description = 'Ereignisanzeige' }
        Services = @{ Command = 'services.msc'; Description = 'Dienste' }
        MSConfig = @{ Command = 'msconfig.exe'; Description = 'Systemkonfiguration' }
        DiskCleanup = @{ Command = 'cleanmgr.exe'; Description = 'Datenträgerbereinigung' }
        TaskScheduler = @{ Command = 'taskschd.msc'; Description = 'Aufgabenplanung' }
        Gpupdate = @{ Command = 'gpupdate.exe'; Arguments = '/force'; Description = 'Gruppenrichtlinien-Update' }
    }
    
    # Button-zu-Aktion-Mapping für vereinfachte Event-Handler-Registrierung
    ButtonMappings = @{
        # DATEV Online Services - Hilfe und Support (URL-Handler)
        'btnHilfeCenter' = @{ Type = 'URL'; UrlKey = 'HelpCenter' }
        'btnServicekontakte' = @{ Type = 'URL'; UrlKey = 'ServiceKontakte' }
        'btnMyUpdates' = @{ Type = 'URL'; UrlKey = 'MyUpdates' }
        
        # DATEV Online Services - Cloud (URL-Handler)
        'btnMyDATEV' = @{ Type = 'URL'; UrlKey = 'MyDATEV' }
        'btnDUO' = @{ Type = 'URL'; UrlKey = 'DUO' }
        'btnLAO' = @{ Type = 'URL'; UrlKey = 'LAO' }
        'btnLizenzverwaltung' = @{ Type = 'URL'; UrlKey = 'Lizenzverwaltung' }
        'btnRechteraum' = @{ Type = 'URL'; UrlKey = 'Rechteraum' }
        'btnRVO' = @{ Type = 'URL'; UrlKey = 'RVO' }
        'btnSmartLogin' = @{ Type = 'URL'; UrlKey = 'SmartLogin' }
        'btnBestandsmanagement' = @{ Type = 'URL'; UrlKey = 'Bestandsmanagement' }
        'btnWeitereApps' = @{ Type = 'URL'; UrlKey = 'WeitereApps' }
        
        # DATEV Online Downloads (URL-Handler)
        'btnDATEVDownloadbereich' = @{ Type = 'URL'; UrlKey = 'Downloadbereich' }
        'btnDATEVSmartDocs' = @{ Type = 'URL'; UrlKey = 'SmartDocs' }
        'btnDatentraegerPortal' = @{ Type = 'URL'; UrlKey = 'DatentraegerPortal' }
        
        # DATEV Programme (DATEV-Handler)
        'btnDATEVArbeitsplatz' = @{ Type = 'DATEV'; ProgramName = 'DATEVArbeitsplatz'; Description = 'DATEV-Arbeitsplatz' }
        'btnInstallationsmanager' = @{ Type = 'DATEV'; ProgramName = 'Installationsmanager'; Description = 'Installationsmanager' }
        'btnServicetool' = @{ Type = 'DATEV'; ProgramName = 'Servicetool'; Description = 'Servicetool' }
        'btnKonfigDBTools' = @{ Type = 'DATEV'; ProgramName = 'KonfigDBTools'; Description = 'KonfigDB-Tools' }
        'btnEODBconfig' = @{ Type = 'DATEV'; ProgramName = 'EODBconfig'; Description = 'EODBconfig' }
        'btnEOAufgabenplanung' = @{ Type = 'DATEV'; ProgramName = 'EOAufgabenplanung'; Description = 'EO Aufgabenplanung' }
        'btnNGENALL40' = @{ Type = 'DATEV'; ProgramName = 'NGENALL40'; Description = 'NGENALL 4.0' }
        
        # System Tools (SystemTool-Handler)
        'btnTaskManager' = @{ Type = 'SystemTool'; Command = 'taskmgr.exe'; Description = 'Task-Manager' }
        'btnResourceMonitor' = @{ Type = 'SystemTool'; Command = 'resmon.exe'; Description = 'Ressourcenmonitor' }
        'btnEventViewer' = @{ Type = 'SystemTool'; Command = 'eventvwr.msc'; Description = 'Ereignisanzeige' }
        'btnServices' = @{ Type = 'SystemTool'; Command = 'services.msc'; Description = 'Dienste' }
        'btnMsconfig' = @{ Type = 'SystemTool'; Command = 'msconfig.exe'; Description = 'Systemkonfiguration' }
        'btnDiskCleanup' = @{ Type = 'SystemTool'; Command = 'cleanmgr.exe'; Description = 'Datenträgerbereinigung' }
        'btnTaskScheduler' = @{ Type = 'SystemTool'; Command = 'taskschd.msc'; Description = 'Aufgabenplanung' }
        
        # Funktions-Handler (Function-Handler)
        'btnLeistungsindex' = @{ Type = 'Function'; FunctionName = 'Start-Leistungsindex' }
        'btnGpupdate' = @{ Type = 'Function'; FunctionName = 'Start-Gpupdate' }
        
        # TextBlock-Handler (verwenden MouseLeftButtonDown statt Add_Click)
        'btnUpdateDownloads' = @{ Type = 'TextBlock'; FunctionName = 'Update-DATEVDownloads' }
        'btnOpenDownloadFolder' = @{ Type = 'TextBlock'; FunctionName = 'Open-DownloadFolder' }
        'btnUpdateDates' = @{ Type = 'TextBlock'; FunctionName = 'Update-UpdateDates' }
        
        # Einstellungs-Handler (jetzt auch zentral verwaltet)
        'btnCheckUpdate' = @{ Type = 'Function'; FunctionName = 'Start-UpdateCheck' }
        'btnDownload' = @{ Type = 'Function'; FunctionName = 'Start-DirectDownload' }
        'btnOpenFolder' = @{ Type = 'Function'; FunctionName = 'Open-AppDataFolder' }
        'btnShowChangelog' = @{ Type = 'Function'; FunctionName = 'Show-ChangelogDialog' }
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

# Benötigte .NET-Assembly für WPF-GUI laden
Add-Type -AssemblyName PresentationFramework
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
        } else {
            Write-Log -Message "Keine settings.json gefunden, verwende Standard-Einstellungen" -Level 'INFO'
            $script:Settings = Get-DefaultSettings
            Save-Settings
        }
        
        # Performance-Cache für häufig verwendete Settings
        $script:IsDebugEnabled = $script:Settings['ShowDebugLogs']
        $script:SettingsNeedSave = $false
        
        Write-Log -Message "Einstellungen initialisiert (Debug: $script:IsDebugEnabled)" -Level 'INFO'
    } catch {
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
        DownloadPath = Join-Path $env:USERPROFILE "Downloads\DATEV-Toolbox"
        AutoUpdate = $true
        ShowDebugLogs = $false
        LogLevel = "INFO"
        WindowPosition = @{
            Left = 100
            Top = 100
        }
        LastUpdateCheck = (Get-Date).AddDays(-1).ToString("yyyy-MM-dd")
    }
}

function Save-Settings {
    <#
    .SYNOPSIS
    Speichert Settings sofort (interne Funktion)
    #>
    try {
        $settingsPath = $script:Config.Paths.SettingsFile
        $settingsDir = Split-Path $settingsPath -Parent
        
        if (-not (Test-Path $settingsDir)) {
            New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
        }
        
        $script:Settings | ConvertTo-Json -Depth 3 | Set-Content $settingsPath -Encoding UTF8
        $script:SettingsNeedSave = $false
        Write-Log -Message "Einstellungen gespeichert: $settingsPath" -Level 'DEBUG'
    } catch {
        Write-Log -Message "Fehler beim Speichern der Einstellungen: $($_.Exception.Message)" -Level 'ERROR'
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
    Setzt einen Einstellungswert (mit verzögertem Speichern)
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
    
    $oldValue = $script:Settings[$Key]
    $script:Settings[$Key] = $Value
    
    # Cache-Update für Performance-kritische Settings
    if ($Key -eq 'ShowDebugLogs') {
        $script:IsDebugEnabled = $Value
    }
    
    # Verzögertes Speichern markieren
    $script:SettingsNeedSave = $true
    
    # Timer für verzögertes Speichern starten (falls nicht bereits aktiv)
    if ($null -eq $script:SettingsSaveTimer) {
        $script:SettingsSaveTimer = New-Object System.Windows.Threading.DispatcherTimer
        $script:SettingsSaveTimer.Interval = [TimeSpan]::FromSeconds(2)
        $script:SettingsSaveTimer.Add_Tick({
            if ($script:SettingsNeedSave) {
                Save-Settings
            }
            $script:SettingsSaveTimer.Stop()
            $script:SettingsSaveTimer = $null
        })
        $script:SettingsSaveTimer.Start()
    } else {
        # Timer bereits aktiv, nur neu starten
        $script:SettingsSaveTimer.Stop()
        $script:SettingsSaveTimer.Start()
    }
    
    Write-Log -Message "Einstellung '$Key' gesetzt: $Value (war: $oldValue)" -Level 'DEBUG'
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
        Height="700" Width="420" 
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
                                <TextBlock Text="DATEV Programme" FontWeight="Bold" FontSize="12"/>
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
                                <TextBlock Text="DATEV Tools" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>                            <StackPanel Orientation="Vertical" Margin="8">
                                <Button Name="btnKonfigDBTools" Content="KonfigDB-Tools" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Öffnet die DATEV Konfigurations-Datenbank Tools"/>
                                <Button Name="btnEODBconfig" Content="EODBconfig" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Startet die DATEV Enterprise Objects Datenbank-Konfiguration"/>
                                <Button Name="btnEOAufgabenplanung" Content="EO Aufgabenplanung" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Öffnet die DATEV Enterprise Objects Aufgabenplanung"/>
                            </StackPanel>
                        </GroupBox>
                          <!-- Performance Tools -->
                        <GroupBox Margin="3,3,3,5">
                            <GroupBox.Header>
                                <TextBlock Text="Performance Tools" FontWeight="Bold" FontSize="12"/>
                            </GroupBox.Header>                            <StackPanel Orientation="Vertical" Margin="8">
                                <Button Name="btnNGENALL40" Content="Native Images erzwingen" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Erzwingt die Neuerstellung der .NET Native Images für bessere Performance"/>
                                <Button Name="btnLeistungsindex" Content="Leistungsindex ermitteln" Height="25" Margin="0,3,0,3" 
                                        ToolTip="Führt eine Leistungsanalyse der DATEV-Installation durch (2 Durchläufe)"/>
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
                                <TextBlock Text="Direkt Downloads" FontWeight="Bold" FontSize="12" VerticalAlignment="Center"/>
                                <TextBlock Name="btnUpdateDownloads" Text="🔄" FontSize="14" Margin="8,0,0,0" 
                                           ToolTip="Direkt-Downloads aktualisieren" VerticalAlignment="Center" 
                                           Cursor="Hand" Foreground="Black"/>
                            </StackPanel>
                        </GroupBox.Header>                        <StackPanel Orientation="Vertical" Margin="8">                            <ComboBox Name="cmbDirectDownloads" Margin="0,0,0,10" Height="25"/>
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
                    </GroupBox>                </StackPanel>
            </TabItem>            <TabItem Header="System">
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
# Logging-System (Performance-optimiert)
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
        $script:LogStringBuilder.Clear()
        $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        
        switch ($Level) {
            'INFO' { $prefix = '[INFO] ' }
            'WARN' { $prefix = '[WARNUNG] ' }
            'ERROR' { $prefix = '[FEHLER] ' }
            'DEBUG' { $prefix = '[DEBUG] ' }
        }
        
        [void]$script:LogStringBuilder.Append($timestamp).Append(' ').Append($prefix).Append($Message).Append("`r`n")
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
        ProgramName = $ProgramName
        PossiblePaths = $PossiblePaths
        Description = $Description
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
        Command = $Command
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

function Register-TextBlockHandler {
    param($TextBlock, $FunctionName)
    $TextBlock.Tag = $FunctionName
    $TextBlock.Add_MouseLeftButtonDown({
        $functionName = $this.Tag
        Write-Log -Message "TextBlock '$($this.Name)' geklickt - rufe auf: $functionName" -Level 'INFO'
        & $functionName
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
            } else {
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
                        } else {
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
                        } else {
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
                
                'TextBlock' {
                    # TextBlock-Elemente verwenden MouseLeftButtonDown statt Add_Click
                    if ($buttonConfig.ContainsKey('FunctionName')) {
                        $functionName = $buttonConfig.FunctionName
                        # Direkte Registrierung ohne Closure
                        Register-TextBlockHandler -TextBlock $buttonElement -FunctionName $functionName
                        Write-Log -Message "TextBlock-Handler für '$buttonName' registriert" -Level 'DEBUG'
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
            } else {
                # Cache-Eintrag ist ungültig, entfernen
                $script:CachedDATEVPaths.Remove($ProgramName)
                $script:PathCacheExpiry.Remove($ProgramName)
                Write-Log -Message "Cache-Eintrag für $ProgramName ungültig geworden, entfernt" -Level 'DEBUG'
            }
        } else {
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
                    Path = $expandedPath
                    Source = 'DATEVPP-Environment'
                    Found = Get-Date
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
                    Path = $testPath
                    Source = "StandardPath-$basePath"
                    Found = Get-Date
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
    try {
        Write-Log -Message "Suche nach Leistungsindex (irw.exe)..." -Level 'INFO'
        
        $foundPath = Get-DATEVExecutablePath -ProgramName 'Leistungsindex'
        
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
    Führt gpupdate /force aus, um Gruppenrichtlinien sofort zu aktualisieren (asynchron)
    .DESCRIPTION
    Überarbeitete Version mit korrekter Prozess-Überwachung, Memory-Management und Benutzerinteraktion
    #>
    try {
        Write-Log -Message "Starte Gruppenrichtlinien-Update (gpupdate /force)..." -Level 'INFO'
        
        # Prüfen ob bereits ein gpupdate läuft
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
        
        # gpupdate /force starten mit verbesserter Konfiguration
        $processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processStartInfo.FileName = "gpupdate.exe"
        $processStartInfo.Arguments = "/force"
        $processStartInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
        $processStartInfo.UseShellExecute = $false
        $processStartInfo.RedirectStandardOutput = $true
        $processStartInfo.RedirectStandardError = $true
        $processStartInfo.CreateNoWindow = $true
        
        $process = [System.Diagnostics.Process]::Start($processStartInfo)
        
        if ($null -eq $process) {
            throw "Konnte gpupdate-Prozess nicht starten"
        }
        
        Write-Log -Message "Gruppenrichtlinien-Update läuft im Hintergrund (PID: $($process.Id))..." -Level 'INFO'
        
        # Progress-Dialog anzeigen (nicht-blockierend)
        $progressDialog = New-Object System.Windows.Window
        $progressDialog.Title = "Gruppenrichtlinien-Update"
        $progressDialog.Width = 400
        $progressDialog.Height = 150
        $progressDialog.WindowStartupLocation = 'CenterOwner'
        $progressDialog.Owner = $window
        $progressDialog.ResizeMode = 'NoResize'
        $progressDialog.WindowStyle = 'ToolWindow'
        
        $progressStackPanel = New-Object System.Windows.Controls.StackPanel
        $progressStackPanel.Margin = '10'
        
        $progressLabel = New-Object System.Windows.Controls.Label
        $progressLabel.Content = "Gruppenrichtlinien werden aktualisiert..."
        $progressLabel.HorizontalAlignment = 'Center'
        $progressStackPanel.Children.Add($progressLabel) | Out-Null
        
        $progressBar = New-Object System.Windows.Controls.ProgressBar
        $progressBar.IsIndeterminate = $true
        $progressBar.Height = 20
        $progressBar.Margin = '0,10'
        $progressStackPanel.Children.Add($progressBar) | Out-Null
        
        $cancelButton = New-Object System.Windows.Controls.Button
        $cancelButton.Content = "Abbrechen"
        $cancelButton.Width = 80
        $cancelButton.HorizontalAlignment = 'Center'
        $cancelButton.Margin = '0,10,0,0'
        $progressStackPanel.Children.Add($cancelButton) | Out-Null
        
        $progressDialog.Content = $progressStackPanel
        
        # Timer für Prozess-Überwachung (korrigierte Implementierung)
        $timer = New-Object System.Windows.Threading.DispatcherTimer
        $timer.Interval = [TimeSpan]::FromSeconds(1)
        
        # Korrekte Datenstruktur für Timer-Callback
        $timer.Tag = @{
            Process = $process
            StartTime = Get-Date
            ProgressDialog = $progressDialog
            OutputData = New-Object System.Text.StringBuilder
            ErrorData = New-Object System.Text.StringBuilder
        }
        
        # Cancel-Button Event-Handler
        $cancelButton.Add_Click({
            $timerData = $timer.Tag
            $currentProcess = $timerData.Process
            
            try {
                if ($null -ne $currentProcess -and -not $currentProcess.HasExited) {
                    $currentProcess.Kill()
                    Write-Log -Message "Gruppenrichtlinien-Update abgebrochen (PID: $($currentProcess.Id))" -Level 'INFO'
                }
            }
            catch {
                Write-Log -Message "Fehler beim Abbrechen des Prozesses: $($_.Exception.Message)" -Level 'WARN'
            }
            
            $timer.Stop()
            $timerData.ProgressDialog.Close()
        })
        
        # Timer-Tick Event-Handler (korrigierte Logik)
        $timer.Add_Tick({
            param($timerSender, $timerEventArgs)
            
            try {
                $timerData = $timerSender.Tag
                $currentProcess = $timerData.Process
                $startTime = $timerData.StartTime
                $currentDialog = $timerData.ProgressDialog
                
                # Timeout-Prüfung
                $elapsed = (Get-Date) - $startTime
                if ($elapsed -gt [TimeSpan]::FromMinutes($script:Config.Timeouts.GpupdateTimeout)) {
                    $timerSender.Stop()
                    Write-Log -Message "Gruppenrichtlinien-Update Timeout nach $($script:Config.Timeouts.GpupdateTimeout) Minuten erreicht" -Level 'WARN'
                    
                    # Prozess beenden
                    try {
                        if ($null -ne $currentProcess -and -not $currentProcess.HasExited) {
                            $currentProcess.Kill()
                            $currentProcess.WaitForExit(5000) # 5 Sekunden warten
                        }
                    }
                    catch {
                        Write-Log -Message "Fehler beim Beenden des Timeout-Prozesses: $($_.Exception.Message)" -Level 'WARN'
                    }
                    finally {
                        if ($null -ne $currentProcess) {
                            $currentProcess.Dispose()
                        }
                    }
                    
                    $currentDialog.Close()
                    
                    [System.Windows.MessageBox]::Show(
                        "Das Gruppenrichtlinien-Update wurde nach $($script:Config.Timeouts.GpupdateTimeout) Minuten abgebrochen.`n`nDer Prozess dauerte ungewöhnlich lange.",
                        "Timeout",
                        [System.Windows.MessageBoxButton]::OK,
                        [System.Windows.MessageBoxImage]::Warning
                    )
                    return
                }
                
                # Prozess-Status prüfen
                if ($null -eq $currentProcess) {
                    $timerSender.Stop()
                    $currentDialog.Close()
                    Write-Log -Message "Prozess-Referenz verloren" -Level 'ERROR'
                    return
                }
                
                # Prüfen ob Prozess beendet ist
                if ($currentProcess.HasExited) {
                    $timerSender.Stop()
                    $currentDialog.Close()
                    
                    $exitCode = $currentProcess.ExitCode
                    
                    # Output lesen falls verfügbar
                    $output = ""
                    $errorOutput = ""
                    try {
                        if (-not $currentProcess.StandardOutput.EndOfStream) {
                            $output = $currentProcess.StandardOutput.ReadToEnd()
                        }
                        if (-not $currentProcess.StandardError.EndOfStream) {
                            $errorOutput = $currentProcess.StandardError.ReadToEnd()
                        }
                    }
                    catch {
                        Write-Log -Message "Konnte Prozess-Output nicht lesen: $($_.Exception.Message)" -Level 'DEBUG'
                    }
                    
                    # Prozess-Ressourcen freigeben
                    try {
                        $currentProcess.Dispose()
                    }
                    catch {
                        Write-Log -Message "Fehler beim Dispose des Prozesses: $($_.Exception.Message)" -Level 'WARN'
                    }
                    
                    # Ergebnis auswerten und anzeigen
                    if ($exitCode -eq 0) {
                        Write-Log -Message "Gruppenrichtlinien erfolgreich aktualisiert (Exit-Code: $exitCode)" -Level 'INFO'
                        [System.Windows.MessageBox]::Show(
                            "Gruppenrichtlinien wurden erfolgreich aktualisiert.`n`nDie neuen Richtlinien sind jetzt aktiv.",
                            "Gruppenrichtlinien aktualisiert",
                            [System.Windows.MessageBoxButton]::OK,
                            [System.Windows.MessageBoxImage]::Information
                        )
                    }
                    else {
                        Write-Log -Message "Gruppenrichtlinien-Update beendet mit Exit-Code: $exitCode" -Level 'WARN'
                        if (-not [string]::IsNullOrEmpty($errorOutput)) {
                            Write-Log -Message "Gpupdate Fehler-Output: $errorOutput" -Level 'WARN'
                        }
                        
                        $message = "Gruppenrichtlinien-Update wurde mit Warnungen abgeschlossen.`nExit-Code: $exitCode"
                        if (-not [string]::IsNullOrEmpty($errorOutput)) {
                            $message += "`n`nFehler: $($errorOutput.Substring(0, [Math]::Min(200, $errorOutput.Length)))"
                        }
                        
                        [System.Windows.MessageBox]::Show(
                            $message,
                            "Gruppenrichtlinien-Update",
                            [System.Windows.MessageBoxButton]::OK,
                            [System.Windows.MessageBoxImage]::Warning
                        )
                    }
                }
                
                # Progress-Dialog-Status aktualisieren (elapsed time)
                $elapsedText = "Gruppenrichtlinien werden aktualisiert... ({0:mm\:ss})" -f $elapsed
                $currentDialog.Dispatcher.Invoke([Action]{
                    $progressLabel.Content = $elapsedText
                })
                
            }
            catch {
                $timerSender.Stop()
                if ($null -ne $timerData.ProgressDialog) {
                    $timerData.ProgressDialog.Close()
                }
                Write-Log -Message "Fehler im Timer-Callback: $($_.Exception.Message)" -Level 'ERROR'
                
                [System.Windows.MessageBox]::Show(
                    "Fehler bei der Überwachung des Gruppenrichtlinien-Updates:`n$($_.Exception.Message)",
                    "Fehler",
                    [System.Windows.MessageBoxButton]::OK,
                    [System.Windows.MessageBoxImage]::Error
                )
            }
        })
        
        # Timer starten und Progress-Dialog anzeigen
        $timer.Start()
        $progressDialog.ShowDialog() | Out-Null
        
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

# Funktion zum Anzeigen des Changelogs
function Show-ChangelogDialog {
    <#
    .SYNOPSIS
    Zeigt das Changelog der aktuellen Version und der letzten Updates an
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
        $changelogText = "DATEV-Toolbox 2.0 - Changelog`n"
        $changelogText += "=" * 50 + "`n`n"
        
        # Aktuelle Version
        $changelogText += "📦 Version $($versionData.version) ($(Get-Date $versionData.releaseDate -Format 'dd.MM.yyyy'))`n"
        $changelogText += "-" * 30 + "`n"
        foreach ($change in $versionData.changelog) {
            $changelogText += "• $change`n"
        }
        $changelogText += "`n"
        
        # Vorherige Versionen
        if ($versionData.previousVersions) {
            foreach ($prevVersion in $versionData.previousVersions) {
                $changelogText += "📦 Version $($prevVersion.version) ($(Get-Date $prevVersion.releaseDate -Format 'dd.MM.yyyy'))`n"
                $changelogText += "-" * 30 + "`n"
                foreach ($change in $prevVersion.changelog) {
                    $changelogText += "• $change`n"
                }
                $changelogText += "`n"
            }
        }
        
        # Changelog in MessageBox anzeigen
        [System.Windows.MessageBox]::Show(
            $changelogText,
            "DATEV-Toolbox 2.0 - Changelog",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Information
        )
        
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
        UpdateDir = $updateDir
        BackupPath = Join-Path $updateDir "DATEV-Toolbox-$timestamp.backup"
        TempUpdatePath = Join-Path $updateDir "DATEV-Toolbox-$($UpdateInfo.NewVersion).download"
        UpdateBatchPath = Join-Path $updateDir "Update-$timestamp.bat"
        Timestamp = $timestamp
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
    } else {
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
        version = $UpdateInfo.NewVersion
        date = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
        backupPath = $BackupPath
    }
    
    # Array erweitern (PowerShell 5.1 kompatibel)
    $currentHistory = $settingsHash.updateHistory
    if ($currentHistory -is [array]) {
        $settingsHash.updateHistory = $currentHistory + $newHistoryEntry
    } else {
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
          if ($shouldCheck) {            # Stillen Update-Check durchführen
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
                }            }
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
            } else {
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
                downloads = $downloadsData.downloads
                lastUpdated = $downloadsData.lastUpdated
            }
        }
        else {
            Write-Log -Message "Keine datev-downloads.json im AppData-Ordner gefunden. Bitte erst aktualisieren." -Level 'WARN'
            return @{
                downloads = @()
                lastUpdated = $null
            }
        }
    }
    catch {
        Write-Log -Message "Fehler beim Laden der DATEV Downloads: $($_.Exception.Message)" -Level 'ERROR'
        return @{
            downloads = @()
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
                url         = $download.url
                description = $download.description
            }
            $cmbDirectDownloads.Items.Add($item) | Out-Null
        }
        
        # Platzhalter als Standardauswahl setzen
        $cmbDirectDownloads.SelectedIndex = 0
        
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

# Event-Handler für DATEV Downloads ComboBox
if ($null -ne $cmbDirectDownloads) {
    $cmbDirectDownloads.Add_SelectionChanged({
            if ($null -ne $cmbDirectDownloads.SelectedItem -and
                $cmbDirectDownloads.SelectedIndex -gt 0 -and
                $null -ne $cmbDirectDownloads.SelectedItem.Tag) {
                $btnDownload.IsEnabled = $true
                $selectedItem = $cmbDirectDownloads.SelectedItem
                Write-Log -Message "Download ausgewählt: $($selectedItem.Content)" -Level 'DEBUG'
            }
            else {
                $btnDownload.IsEnabled = $false
            }
        })
}
else {
    Write-Log -Message "ComboBox 'cmbDirectDownloads' konnte nicht gefunden werden" -Level 'WARN'
}

# Downloads-ComboBox initialisieren (nur wenn JSON-Datei vorhanden ist)
$downloadsJsonPath = $script:Config.Paths.DownloadsJSON
if (Test-Path $downloadsJsonPath) {
    Initialize-DownloadsComboBox
    Write-Log -Message "Downloads-ComboBox mit vorhandenen Daten initialisiert" -Level 'DEBUG'
} else {
    Write-Log -Message "Keine Downloads-JSON gefunden, ComboBox bleibt leer bis zum ersten Update" -Level 'DEBUG'
}

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
    
    # Settings sofort speichern falls noch ausstehend
    if ($script:SettingsNeedSave) {
        Save-Settings
    }
    
    # Runspace-Pool schließen
    Close-RunspacePool
    
    # Timer stoppen falls aktiv
    if ($null -ne $script:SettingsSaveTimer) {
        $script:SettingsSaveTimer.Stop()
        $script:SettingsSaveTimer = $null
    }
    
    Write-Log -Message "DATEV-Toolbox 2.0 ordnungsgemäß beendet" -Level 'INFO'
})

# Startup-Log schreiben
Write-Log -Message "DATEV-Toolbox 2.0 gestartet (Performance-optimiert)" -Level 'INFO'

# GUI anzeigen und auf Benutzerinteraktion warten
$window.ShowDialog() | Out-Null
#endregion

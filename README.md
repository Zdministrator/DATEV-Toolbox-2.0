# DATEV-Toolbox 2.0

Eine moderne WPF-basierte PowerShell-Anwendung für DATEV-Umgebungen mit automatischen Updates, direkten Downloads und umfassenden Tools.

## 📸 Anwendungsvorschau

![DATEV-Toolbox Screenshot](images/screenshot-main.png)

*Die DATEV-Toolbox 2.0 bietet eine intuitive tab-basierte Benutzeroberfläche für alle wichtigen DATEV-Tools und -Programme*

## 📋 Features

- **🆕 System Tray Integration**: Minimize-to-Tray mit Benachrichtigungen und Quick-Actions-Menü (v2.3.0)
- **🆕 Tray-Icon mit Kontextmenü**: Quick-Actions für schnellen Zugriff auf wichtige Funktionen (WIP) (v2.3.0)
- **🆕 Balloon-Benachrichtigungen**: Info-Notifications beim Minimieren und für wichtige Events (v2.3.0)
- **🆕 Hintergrund-Betrieb**: Anwendung läuft permanent im Systembereich (v2.3.0)
- **🆕 Log-Rotation System**: Automatische Archivierung großer Log-Dateien (>5 MB) mit konfigurierbarer Archive-Verwaltung (v2.2.0)
- **🆕 FSLogix Download-Integration**: Microsoft FSLogix nutzt jetzt die gleiche Download-Funktion wie DATEV-Downloads (v2.2.0)
- **🆕 Sonstige nützliche Downloads**: Neuer Bereich für Microsoft-Tools (FSLogix, etc.) mit direkter Download-Funktion (v2.2.0)
- **🆕 Vertragsübersichten Online**: Direkter Zugriff auf DATEV Vertragsübersichten-Portal im DATEV-Online Tab (v2.2.0)
- **🆕 Erweiterbares Download-System**: Modularer Download-Handler für einfache Integration weiterer Downloads (v2.2.0)
- **🆕 Server-Anpassungs-Assistent**: Neuer Button für DATEV Server-Konfiguration (DvServerChange.exe) (v2.1.10)
- **🆕 Windows Updates Integration**: System-Tab unterstützt jetzt Windows Updates für Client und Server (v2.1.10)  
- **🆕 Dokumente lastUpdated-Anzeige**: Datum der letzten Aktualisierung im Dokumente-Tab (v2.1.10)
- **🆕 Download-Info mit Rich-Text**: Fette Schrift für Labels und strukturierte Metadaten-Anzeige (v2.1.9)
- **🆕 Neuer Dokumente-Tab**: Direkter Zugriff auf wichtige DATEV-Anleitungen und Dokumentationen (v2.1.8)
- **🆕 Scrollbares Changelog-Fenster**: Benutzerfreundliche Anzeige der Update-Historie (v2.1.7)
- **🆕 Zentrale Konfiguration**: Alle URLs, Pfade und Einstellungen konfigurierbar (v2.1.0)
- **🆕 Kompakte UI**: Optimierte GroupBox-Abstände für platzsparende Darstellung (v2.1.4)
- **WPF-GUI**: Moderne tab-basierte Benutzeroberfläche
- **DATEV Programme**: Direkter Start von DATEV-Arbeitsplatz, Installationsmanager und Servicetool
- **DATEV Tools**: Zugriff auf KonfigDB-Tools, EODBconfig, EO Aufgabenplanung und Server-Anpassungs-Assistent
- **Performance Tools**: Leistungsindex und NGENALL 4.0 für Systemoptimierung
- **System Tools**: Integrierte Windows-Systemtools (Task-Manager, Ressourcenmonitor, Windows Updates)
- **🆕 Erweiterte Gruppenrichtlinien-Updates**: Progress-Dialog mit Abbruch-Funktion und Prozess-Überwachung (v2.1.4)
- **Automatische Updates**: Selbst-aktualisierendes System mit GitHub-Integration
- **🆕 System Tray**: Minimize-to-Tray, Benachrichtigungen und Quick-Actions-Kontextmenü (v2.3.0)
- **DATEV Online Tools**: Schnellzugriff auf wichtige DATEV-Portale und -Services
- **🆕 Erweiterte Downloads**: Verwaltung und Download von DATEV-Software mit Aktualisierungsdatum
- **🆕 Dokumente-Tab**: Direkter Zugriff auf wichtige DATEV Help-Center Dokumentationen mit Aktualisierungsdatum
- **Update-Termine**: Anzeige anstehender DATEV-Updates
- **🆕 Scrollbares Changelog**: Benutzerfreundliche Update-Historie mit bis zu 10 Versionen
- **Logging-System**: Umfassendes Protokollsystem mit verschiedenen Log-Leveln
- **🆕 Tray-Icon Einstellungen**: MinimizeToTray und ShowNotifications für anpassbares Verhalten (v2.3.0)
- **Einstellungsverwaltung**: Persistente Speicherung von Konfigurationen

## 🚀 Installation und Start

### Voraussetzungen
- **PowerShell 5.1+** (Windows PowerShell oder PowerShell Core)
- **.NET Framework 4.5+** (für WPF-Unterstützung)
- **Windows-Betriebssystem**

### Ausführung
```powershell
# Direkte Ausführung
pwsh.exe -File ".\DATEV-Toolbox 2.0.ps1"

# Oder über Windows PowerShell
powershell.exe -File ".\DATEV-Toolbox 2.0.ps1"
```

### Erste Schritte
1. **DATEV Tools nutzen**: Verwenden Sie den DATEV-Tab für direkten Zugriff auf Programme und Tools
2. **Direkt-Downloads aktualisieren**: Klicken Sie auf das 🔄-Symbol im Downloads-Tab
3. **Update-Termine laden**: Verwenden Sie das 🔄-Symbol im Einstellungen-Tab
4. **Updates prüfen**: Nutzen Sie "Nach Updates suchen" für manuelle Update-Checks

## 📁 Projektstruktur

```
DATEV-Toolbox 2.0/
├── DATEV-Toolbox 2.0.ps1    # Hauptanwendung
├── version.json              # Versionsinformationen und Changelog
├── datev-downloads.json      # Download-Konfiguration
├── datev-dokumente.json      # DATEV Help-Center Dokumenten-Sammlung
└── README.md                 # Diese Dokumentation
```

## 🔧 Konfiguration

Die Anwendung speichert alle Einstellungen und Logs im AppData-Ordner:
```
%APPDATA%\DATEV-Toolbox 2.0\
├── settings.json             # Benutzereinstellungen
├── Error-Log.txt            # Fehlerprotokoll
├── datev-downloads.json     # Lokale Download-Konfiguration
├── datev-dokumente.json     # Lokale Dokumenten-Sammlung
├── Jahresplanung_2025.ics   # DATEV Update-Termine
└── Updates/                 # Update-Dateien und Backups
    ├── *.backup             # Automatische Backups (letzte 5)
    ├── *.download           # Temporäre Update-Downloads
    └── *.bat                # Update-Installationsskripte
```

## 📦 Verfügbare Tabs

### 🛠️ DATEV
Vollständige DATEV-Integration mit drei Kategorien:
- **DATEV Programme**: DATEV-Arbeitsplatz, Installationsmanager, Servicetool
- **DATEV Tools**: KonfigDB-Tools, EODBconfig, EO Aufgabenplanung, Server-Anpassungs-Assistent
- **Performance Tools**: Leistungsindex, NGENALL 4.0 (Native Images)

### 🌐 DATEV Online
Schnellzugriff auf wichtige DATEV-Online-Services:
- **Hilfe und Support**: DATEV Hilfe Center, Servicekontakte, myUpdates
- **Cloud**: myDATEV Portal, DUO, LAO, Lizenzverwaltung, Rechteraum, RVO
- **Verwaltung**: SmartLogin Administration, Bestandsmanagement, **🆕 Vertragsübersichten Online (v2.2.0)**

### 📥 Downloads
- **🆕 Sonstige nützliche Downloads**: Neuer Bereich für Microsoft-Tools (FSLogix, etc.) (v2.2.0)
- **🆕 FSLogix-Integration**: Microsoft FSLogix mit professioneller Download-Funktion (v2.2.0)
- **🆕 Modulares Download-System**: Einheitlicher Download-Handler für alle Dateitypen (v2.2.0)
- **Erweiterte Direkt-Downloads**: Verwaltung und Download von DATEV-Software
- **Aktualisierungsdatum**: Downloads zeigen das Datum der letzten Aktualisierung
- **Neueste Downloads**: Deinstallationsnacharbeiten-Tool V. 3.11 hinzugefügt
- **Automatische Updates**: Downloads werden von GitHub aktualisiert
- **Download-Ordner**: Direkter Zugriff auf heruntergeladene Dateien (~/Downloads/DATEV-Toolbox)

### 📋 Dokumente
Neuer Tab für direkten Zugriff auf wichtige DATEV-Dokumentationen:
- **DATEV Help-Center Integration**: Direkter Zugriff auf offizielle Dokumentationen
- **Umfassende Anleitungen**: Windows Server-Einrichtung, Betriebssystem-Kompatibilität
- **5 wichtige Dokumente**: Server-Installation, Office-Umstieg, Deinstallation und mehr
- **Automatische Updates**: Dokumenten-Liste wird von GitHub aktualisiert
- **🆕 Aktualisierungsdatum-Anzeige**: Datum der letzten Aktualisierung wird prominent angezeigt
- **Ein-Klick-Zugriff**: Öffnet Dokumente direkt im Browser

### ⚙️ System
Integrierte Windows- und System-Tools:
- **🆕 Aktionen**: Gruppenrichtlinien-Update (gpupdate /force) mit asynchroner Ausführung
- **🆕 Windows Updates**: Cross-Platform-Button für Windows Updates (Client & Server kompatibel)
- **System Tools**: Task-Manager, Ressourcenmonitor, Ereignisanzeige
- **Verwaltung**: Dienste, Systemkonfiguration, Datenträgerbereinigung

### 🔧 Einstellungen
- **Konfiguration**: Zugriff auf Einstellungsordner
- **Update-Management**: Manuelle Update-Checks
- **🆕 Scrollbares Changelog**: Benutzerfreundliche Update-Historie mit bis zu 10 Versionen
- **Update-Termine**: Anzeige anstehender DATEV-Updates

## 🔄 Update-System

Die Anwendung verfügt über ein robustes automatisches Update-System:

- **Automatische Checks**: Alle 24 Stunden
- **Sichere Downloads**: TLS 1.2 verschlüsselt von GitHub
- **Backup-System**: Automatische Backups vor Updates
- **Rollback-Funktion**: Wiederherstellung bei fehlgeschlagenen Updates
- **Update-Historie**: Verfolgung aller durchgeführten Updates

### Manuelle Updates
```powershell
# In der Anwendung: Einstellungen → "Nach Updates suchen"
```

## 📝 Logging

Das integrierte Logging-System protokolliert alle Aktivitäten:
- **INFO**: Normale Betriebsmeldungen
- **WARN**: Warnungen (werden in Error-Log.txt gespeichert)
- **ERROR**: Fehler (werden in Error-Log.txt gespeichert)

## 🤝 Entwicklung

### Entwicklung
Aktuelle Version: **2.3.0** (20.10.2025)

### Autor
**Norman Zamponi** | HEES GmbH | © 2025

### Repository
- **GitHub**: [Zdministrator/DATEV-Toolbox-2.0](https://github.com/Zdministrator/DATEV-Toolbox-2.0)
- **Updates**: Automatisch von GitHub main branch
- **Lizenz**: Proprietär

### Technologie-Stack
- **Sprache**: PowerShell 5.1+
- **GUI-Framework**: Windows Presentation Foundation (WPF)
- **Mindest-.NET**: .NET Framework 4.5+
- **Zielplattform**: Windows (Client & Server)
- **Architektur**: Event-driven, modular mit zentraler Konfiguration

### Systemanforderungen
- **PowerShell**: Version 5.1 oder höher (Windows PowerShell oder PowerShell Core)
- **Betriebssystem**: Windows 10/11 oder Windows Server 2016+
- **.NET Framework**: 4.5 oder höher (für WPF-Unterstützung)
- **Zusätzliche Assemblies**: System.Windows.Forms, System.Drawing (für Tray-Icon, v2.3.0)
- **DATEV-Installation**: Optional (für DATEV-Tool-Integration)
- **Internetverbindung**: Empfohlen (für automatische Updates und Downloads)
- **Berechtigungen**: Standard-Benutzerrechte (Admin nur für spezielle Tools)

### Code-Qualität & Features
- ✅ **Enterprise-Grade**: Log-Rotation, Memory-Management, Thread-Safety, System-Tray-Integration
- ✅ **PowerShell 5.1 Kompatibel**: Keine GetNewClosure-Abhängigkeiten
- ✅ **Fehlerbehandlung**: Try-Catch mit umfassendem Logging
- ✅ **Performance**: Caching, StringBuilder, asynchrone Downloads
- ✅ **Wartbarkeit**: Zentrale Konfiguration, modulare Handler-Architektur
- ✅ **Sicherheit**: TLS 1.2, Input-Validation, sichere URL-Verwaltung

### Beiträge & Feedback
Für Feature-Requests, Bug-Reports oder Verbesserungsvorschläge:
- **E-Mail**: norman.zamponi@hees.de
- **GitHub Issues**: [Issues öffnen](https://github.com/Zdministrator/DATEV-Toolbox-2.0/issues)

## 🔄 Update-Historie

### Version 2.3.0 (2025-10-20) - System Tray Integration
- **🎯 System-Tray-Icon**: NotifyIcon mit Tooltip "DATEV-Toolbox 2.0" im Systembereich
  - Permanente Hintergrund-Präsenz der Anwendung
  - Icon aus Skript extrahiert mit Fallback auf Windows Standard-Icon
  - Ordnungsgemäßer Resource-Cleanup mit Dispose-Pattern
- **📋 Kontextmenü Quick-Actions**: 4 Einträge für schnellen Zugriff
  - "Fenster anzeigen" - Stellt minimiertes Fenster wieder her
  - "DATEV-Arbeitsplatz" - Startet DATEV-Arbeitsplatz direkt
  - "Download-Ordner öffnen" - Öffnet DATEV-Toolbox Download-Ordner
  - "Beenden" - Graceful Shutdown mit vollständigem Cleanup
- **🔽 Minimize-to-Tray**: Fenster verschwindet in Systembereich beim Minimieren
  - Fenster wird aus Taskbar entfernt
  - Balloon-Benachrichtigung mit Hinweis (3 Sekunden)
  - Doppelklick auf Tray-Icon zum Wiederherstellen
- **🔔 Balloon-Benachrichtigungen**: Info-Notifications für wichtige Events
  - Konfigurierbare Icon-Typen (Info, Warning, Error)
  - Einstellbare Anzeigedauer (Standard: 3-5 Sekunden)
  - Integriert mit Logging-System
- **🔧 Threading-Architektur**: WPF + Windows.Forms Kompatibilität
  - Kritischer Bugfix: ShowDialog() → Show() + Application.Run()
  - Proper Message-Loop für NotifyIcon Event-Processing
  - Non-blocking Window-Display für Tray-Icon-Support
- **⚙️ Settings-Integration**: Neue Tray-Icon Einstellungen
  - MinimizeToTray (Standard: true) - Steuert Minimize-Verhalten
  - ShowNotifications (Standard: true) - Benachrichtigungen aktivieren/deaktivieren
  - Vorbereitet für zukünftige UI-Integration
- **📊 5 neue Funktionen**: 235 Zeilen dedizierter Tray-Icon Code
  - Initialize-TrayIcon - Icon-Creation, Kontextmenü, Event-Handler
  - Show-TrayNotification - Balloon-Tips mit Validierung
  - Show-MainWindow - Fenster-Restore mit Fokussierung
  - Close-Application - Graceful Shutdown-Sequenz
  - Close-TrayIcon - Resource-Cleanup mit Dispose()
- **✅ Tests**: 6/6 bestanden (100% Erfolgsrate)
  - Initialisierung, Kontextmenü, Minimize-to-Tray, Benachrichtigungen, Shutdown, Error-Handling

### Version 2.2.0 (2025-10-02) - Enterprise-Grade Erweiterungen
- **📝 Log-Rotation System**: Automatische Archivierung großer Log-Dateien (>5 MB)
  - Konfigurierbar: MaxSize (5 MB), MaxArchives (5)
  - Performance-optimiert: Check nur bei jedem 10. Schreibvorgang
  - Startup-Rotation: Große Logs werden beim Programmstart archiviert
  - Archive-Management: Automatische Cleanup-Funktion behält nur die letzten 5 Archive
- **📦 FSLogix Download-Integration**: Microsoft FSLogix nutzt professionelle Download-Funktion
  - Einheitlicher Download-Ordner: ~/Downloads/DATEV-Toolbox
  - Fortschritts-Tracking und Fehlerbehandlung
  - Überschreib-Prüfung mit Benutzer-Bestätigung
  - Konsistent mit DATEV Direkt-Downloads
- **🔧 Sonstige nützliche Downloads**: Neuer Bereich für Microsoft-Tools
  - Microsoft FSLogix Apps (Latest)
  - Einfach erweiterbar für weitere Tools (Edge, Teams, OneDrive, etc.)
  - Professionelles Download-System mit Background-Processing
- **📋 Vertragsübersichten Online**: DATEV-Online Tab erweitert
  - Direkter Zugriff auf https://apps.datev.de/vertragsuebersichten-online
  - Button im Bereich "Verwaltung und Technik"
  - Zentrale Verwaltung von DATEV-Verträgen und Lizenzen
- **🏗️ Modularer Download-Handler**: Erweiterbares Download-System
  - Register-DownloadHandler Funktion für einfache Integration
  - Zentrale Downloads-Sektion in Konfiguration
  - PowerShell 5.1 kompatibel (ohne GetNewClosure)
  - Type-basiertes Handler-System für maximale Flexibilität

### Version 2.1.10 (2025-08-21)
- **🔧 Server-Anpassungs-Assistent**: Neuer Button für DATEV Server-Konfiguration (DvServerChange.exe)
- **🔄 Windows Updates Integration**: System-Tab unterstützt jetzt Windows Updates für Client und Server
- **📋 Dokumente lastUpdated-Anzeige**: Datum der letzten Aktualisierung im Dokumente-Tab

### Version 2.1.9 (2025-08-21)
- **📥 Download-Info-Enhancement**: Fette Schrift und vollständige Metadaten für Downloads
- **🎨 Rich-Text-Formatierung**: WPF Inlines für professionelle Info-Darstellung mit fetten Labels
- **📊 Strukturierte Metadaten**: Erschienen, Dateiname und Dateigröße in der Download-Info
- **🔧 JSON-Datenintegration**: Vollständige Übertragung aller Download-Felder zur UI
- **💡 Intelligente Formatierung**: Automatische Leerzeilen zwischen Beschreibung und Zusatzinfos
- **👥 Verbesserte UX**: Konsistente Anzeige für Downloads mit und ohne Zusatzinformationen
- **🏗️ Code-Verbesserung**: Tag-Objekt-Erweiterung für vollständige Metadaten-Übertragung

### Version 2.1.8 (2025-08-13)
- **📋 Dokumente-Tab**: Neuer Tab für direkten Zugriff auf wichtige DATEV-Dokumentationen
- **📧 E-Mail-Hinweis**: Responsiver Hinweis für weitere Dokument-Vorschläge mit automatischem Zeilenumbruch
- **🔗 Hyperlink-Integration**: Neue Hyperlink-Event-Handler für bessere Benutzerinteraktion
- **🎨 Grid-Layout**: Optimierte Textdarstellung für verschiedene Fenstergrößen
- **🌐 DATEV Help-Center Integration**: 5 wichtige Anleitungen verfügbar (Server-Setup, etc.)
- **📥 Download-Erweiterung**: Deinstallationsnacharbeiten-Tool V. 3.11 hinzugefügt
- **🏗️ UI-Verbesserung**: Saubere Tab-Struktur für bessere Navigation

### Version 2.1.7 (2025-08-06)
- **Scrollbares Changelog**: Von MessageBox auf großes WPF-Fenster umgestellt
- **Größenverstellbares Fenster**: 800x600 Standard, mindestens 600x400
- **Bessere Lesbarkeit**: Monospace-Font und bis zu 10 Versionen anzeigbar
- **Memory-Management**: WebClient ordnungsgemäß disposed
- **Professional Look**: Deutlich benutzerfreundlichere Update-Historie

### Version 2.1.6 (2025-08-05)
- **⚡ Performance-Optimierung**: Caching für DATEV-Pfad-Suche implementiert
- **🧠 Memory-Management**: StringBuilder-Performance und Runspace-Pool
- **🔒 Thread-Sicherheit**: Settings-Verwaltung mit Monitor-Locks
- **🛡️ Fehlerbehandlung**: Robuste Event-Handler und Resource-Cleanup

### Version 2.1.5 (2025-08-05)
- **🐛 StringBuilder-Terminal-Ausgabe behoben**: Keine störenden Debug-Anzeigen mehr
- **🔄 GPUpdate-Funktion vereinfacht**: Von 200+ auf 50 Zeilen reduziert
- **🔗 Download-Links modernisiert**: Für neue DATEV myUpdates API-Struktur
- **🛠️ Code-Stabilisierung**: Alle kritischen Bugs behoben
- **⚡ Performance beibehalten**: Optimierungen aus v2.1.4 erhalten

### Version 2.1.4 (2025-07-18)
- **🎨 UI-Optimierung**: Kompaktere GroupBox-Abstände für bessere Raumnutzung
- **🔄 Robuste Prozess-Überwachung**: Verbesserte gpupdate-Funktion mit Progress-Dialog
- **🧠 Memory-Leak-Fixes**: Ordnungsgemäße Ressourcen-Freigabe
- **🔧 PowerShell 5.1 Kompatibilität**: WebClient-Funktionen angepasst

### Version 2.1.3 (2025-07-04)
- **✅ Vollständige Feature-Implementierung**: Alle Button-Handler funktionsfähig
- **🎛️ Event-Handler-System**: URL-, DATEV-, SystemTool- und Function-Handler
- **⚡ Performance-Optimierungen**: Caching und asynchrone Operationen

## 🛠️ Technische Details

### Architektur
- **PowerShell 5.1+ kompatibel**: Vollständige Rückwärtskompatibilität
- **WPF-basierte GUI**: Moderne tab-basierte Benutzeroberfläche
- **Event-Handler-System**: Zentrale Verwaltung aller UI-Interaktionen
- **Automatisches Update-System**: GitHub-Integration mit Backup-Funktionalität

### Systemanforderungen
- PowerShell 5.1+ kompatibel
- Windows mit .NET Framework 4.5+
- WPF-Unterstützung erforderlich
- DATEV-Installation (für DATEV-Tools, optional)
- Internetverbindung für Updates und Downloads

## 📄 Lizenz

Dieses Projekt ist für den internen Gebrauch bei HEES GmbH entwickelt.

---

**Hinweis**: Diese Anwendung verbindet sich automatisch mit GitHub für Updates und Download-Konfigurationen. Stellen Sie sicher, dass eine Internetverbindung verfügbar ist.

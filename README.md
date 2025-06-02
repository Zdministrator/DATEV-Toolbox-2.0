# DATEV-Toolbox 2.0

Eine moderne WPF-basierte PowerShell-Anwendung für DATEV-Umgebungen mit automatischen Updates, direkten Downloads und umfassenden Online-Tools.

## 📋 Features

- **WPF-GUI**: Moderne tab-basierte Benutzeroberfläche
- **DATEV Programme**: Direkter Start von DATEV-Arbeitsplatz, Installationsmanager und Servicetool
- **DATEV Tools**: Zugriff auf KonfigDB-Tools, EODBconfig und EO Aufgabenplanung
- **Performance Tools**: NGENALL 4.0 und Leistungsindex für Systemoptimierung
- **System Tools**: Integrierte Windows-Systemtools (Task-Manager, Ressourcenmonitor, etc.)
- **Automatische Updates**: Selbst-aktualisierendes System mit GitHub-Integration
- **DATEV Online Tools**: Schnellzugriff auf wichtige DATEV-Portale und -Services
- **Direkt-Downloads**: Verwaltung und Download von DATEV-Software
- **Update-Termine**: Anzeige anstehender DATEV-Updates
- **Logging-System**: Umfassendes Protokollsystem mit verschiedenen Log-Leveln
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
└── README.md                 # Diese Dokumentation
```

## 🔧 Konfiguration

Die Anwendung speichert alle Einstellungen und Logs im AppData-Ordner:
```
%APPDATA%\DATEV-Toolbox 2.0\
├── settings.json             # Benutzereinstellungen
├── Error-Log.txt            # Fehlerprotokoll
├── datev-downloads.json     # Lokale Download-Konfiguration
└── Updates/                 # Update-Dateien und Backups
    ├── *.backup             # Automatische Backups (letzte 5)
    ├── *.download           # Temporäre Update-Downloads
    └── *.bat                # Update-Installationsskripte
```

## 📦 Verfügbare Tabs

### 🛠️ DATEV
Vollständige DATEV-Integration mit drei Kategorien:
- **DATEV Programme**: DATEV-Arbeitsplatz, Installationsmanager, Servicetool
- **DATEV Tools**: KonfigDB-Tools, EODBconfig, EO Aufgabenplanung
- **Performance Tools**: NGENALL 4.0 (Native Images), Leistungsindex

### 🌐 DATEV Online
Schnellzugriff auf wichtige DATEV-Online-Services:
- **Hilfe und Support**: DATEV Hilfe Center, Servicekontakte, myUpdates
- **Cloud**: myDATEV Portal, DUO, LAO, Lizenzverwaltung, Rechteraum, RVO
- **Verwaltung**: SmartLogin Administration, Bestandsmanagement

### 📥 Downloads
- **Direkt-Downloads**: Verwaltung und Download von DATEV-Software
- **Automatische Updates**: Downloads werden von GitHub aktualisiert
- **Download-Ordner**: Direkter Zugriff auf heruntergeladene Dateien

### ⚙️ System
Integrierte Windows-Systemtools:
- **System Tools**: Task-Manager, Ressourcenmonitor, Ereignisanzeige
- **Verwaltung**: Dienste, Systemkonfiguration, Datenträgerbereinigung

### 🔧 Einstellungen
- **Konfiguration**: Zugriff auf Einstellungsordner
- **Update-Management**: Manuelle Update-Checks
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

### Version
Aktuelle Version: **2.0.7**

### Autor
**Norman Zamponi** | HEES GmbH | © 2025

### Repository
- **GitHub**: [Zdministrator/DATEV-Toolbox-2.0](https://github.com/Zdministrator/DATEV-Toolbox-2.0)
- **Updates**: Automatisch von GitHub main branch

### Systemanforderungen
- PowerShell 5.1+ kompatibel
- Windows mit .NET Framework 4.5+
- WPF-Unterstützung erforderlich
- DATEV-Installation (für DATEV-Tools, optional)

### Changelog (Neueste Versionen)
- **v2.0.7**: Kritischer Bugfix - Update-Prozess-Fehler behoben
- **v2.0.6**: DATEV Tools vollständig implementiert (8 neue Tools)
- **v2.0.5**: System Tools hinzugefügt
- **v2.0.4**: Performance-Optimierungen

## 📄 Lizenz

Dieses Projekt ist für den internen Gebrauch bei HEES GmbH entwickelt.

---

**Hinweis**: Diese Anwendung verbindet sich automatisch mit GitHub für Updates und Download-Konfigurationen. Stellen Sie sicher, dass eine Internetverbindung verfügbar ist.

### 🎯 Besondere Features
- **Intelligente DATEV-Pfad-Suche**: Automatische Erkennung von DATEV-Installationen
- **Robuste Fehlerbehandlung**: Benutzerfreundliche MessageBoxen bei Problemen
- **Vollständiges Logging**: Alle Aktionen werden protokolliert
- **Backup-System**: Automatische Backups vor Updates
- **Rollback-Funktion**: Wiederherstellung bei fehlgeschlagenen Updates

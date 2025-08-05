# DATEV-Toolbox 2.0

Eine moderne WPF-basierte PowerShell-Anwendung für DATEV-Umgebungen mit automatischen Updates, direkten Downloads und umfassenden Tools.

## 📋 Features

- **🆕 Zentrale Konfiguration**: Alle URLs, Pfade und Einstellungen konfigurierbar (v2.1.0)
- **🆕 Kompakte UI**: Optimierte GroupBox-Abstände für platzsparende Darstellung (v2.1.4)
- **WPF-GUI**: Moderne tab-basierte Benutzeroberfläche
- **DATEV Programme**: Direkter Start von DATEV-Arbeitsplatz, Installationsmanager und Servicetool
- **DATEV Tools**: Zugriff auf KonfigDB-Tools, EODBconfig und EO Aufgabenplanung
- **Performance Tools**: NGENALL 4.0 und Leistungsindex für Systemoptimierung
- **System Tools**: Integrierte Windows-Systemtools (Task-Manager, Ressourcenmonitor, etc.)
- **🆕 Erweiterte Gruppenrichtlinien-Updates**: Progress-Dialog mit Abbruch-Funktion und Prozess-Überwachung (v2.1.4)
- **Automatische Updates**: Selbst-aktualisierendes System mit GitHub-Integration
- **DATEV Online Tools**: Schnellzugriff auf wichtige DATEV-Portale und -Services
- **🆕 Erweiterte Downloads**: Verwaltung und Download von DATEV-Software mit Aktualisierungsdatum
- **Update-Termine**: Anzeige anstehender DATEV-Updates
- **🆕 Changelog-Viewer**: Anzeige der Update-Historie der letzten 3 Versionen
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
- **🆕 Erweiterte Direkt-Downloads**: Verwaltung und Download von DATEV-Software
- **Aktualisierungsdatum**: Downloads zeigen jetzt das Datum der letzten Aktualisierung
- **Neueste Downloads**: Belegtransfer V. 5.47, DATEV Datenübernahme nach LODAS V. 4.24
- **Automatische Updates**: Downloads werden von GitHub aktualisiert
- **Download-Ordner**: Direkter Zugriff auf heruntergeladene Dateien

### ⚙️ System
Integrierte Windows- und System-Tools:
- **🆕 Aktionen**: Gruppenrichtlinien-Update (gpupdate /force) mit asynchroner Ausführung
- **System Tools**: Task-Manager, Ressourcenmonitor, Ereignisanzeige
- **Verwaltung**: Dienste, Systemkonfiguration, Datenträgerbereinigung

### 🔧 Einstellungen
- **Konfiguration**: Zugriff auf Einstellungsordner
- **Update-Management**: Manuelle Update-Checks
- **🆕 Changelog-Viewer**: Anzeige der Update-Historie der letzten 3 Versionen
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
Aktuelle Version: **2.1.5**

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
- Internetverbindung für Updates und Downloads

### Neue Features in Version 2.1.5

#### 🐛 Bugfix-Release: StringBuilder und Code-Stabilisierung
- **StringBuilder-Terminal-Ausgabe behoben**: Keine störenden Kapazitäts-Anzeigen mehr beim Start
- **Saubere UI**: StringBuilder.Clear() und StringBuilder.Append() Operationen unterdrückt
- **GPUpdate vereinfacht**: Von 200+ auf 50 Zeilen Code reduziert, einfachere CMD-Ausführung
- **Download-Links aktualisiert**: Neue DATEV myUpdates API-Struktur berücksichtigt
- **Performance beibehalten**: Alle Optimierungen aus v2.1.4 bleiben erhalten
- **PowerShell 5.1 Kompatibilität**: Vollständig getestet und bestätigt

#### 📈 Verbesserungen aus vorherigen Versionen
- **Kompakte UI**: Optimierte GroupBox-Abstände für platzsparendere Darstellung (v2.1.4)
- **Zentrale Konfiguration**: Alle URLs, Pfade und Einstellungen konfigurierbar (v2.1.0)

## 🔄 Update-Historie

### Version 2.1.5 (2025-08-05)
- **StringBuilder-Terminal-Ausgabe behoben**: Keine störenden Debug-Anzeigen mehr
- **GPUpdate-Funktion vereinfacht**: Von 200+ auf 50 Zeilen reduziert
- **Download-Links modernisiert**: Für neue DATEV myUpdates API-Struktur
- **Code-Stabilisierung**: Alle kritischen Bugs behoben
- **Performance beibehalten**: Optimierungen aus v2.1.4 erhalten

### Version 2.1.4 (2025-07-18)
- **UI-Optimierung**: Kompaktere GroupBox-Abstände für bessere Raumnutzung
- **Robuste Prozess-Überwachung**: Verbesserte gpupdate-Funktion mit Progress-Dialog
- **Memory-Leak-Fixes**: Ordnungsgemäße Ressourcen-Freigabe
- **PowerShell 5.1 Kompatibilität**: WebClient-Funktionen angepasst

### Version 2.1.3 (2025-07-04)
- **Vollständige Feature-Implementierung**: Alle Button-Handler funktionsfähig
- **Event-Handler-System**: URL-, DATEV-, SystemTool- und Function-Handler
- **Performance-Optimierungen**: Caching und asynchrone Operationen

## 🛠️ Technische Details
- **Code-Formatierung**: Einrückungen und Zeilenumbrüche korrigiert
- **Variable-Cleanup**: Ungenutzte Variablen entfernt

### Changelog (Neueste Versionen)
- **v2.1.4**: 🎨 UI-Optimierung + Erweiterte Prozess-Überwachung + Memory-Fixes (Qualitäts-Update)
- **v2.1.3**: 🔧 Code-Stabilisierung + Vollständige Funktions-Implementierung (Stabilität)
- **v2.1.2**: ⚡ Performance-Optimierungen + Caching + Memory-Management (Performance)
- **v2.1.1**: 🛡️ PowerShell 5.1 Kompatibilität + Event-Handler-Optimierung (Kompatibilität)
- **v2.1.0**: 🎯 Zentrale Konfiguration + Code-Qualität + Wartbarkeit (Major Update)

#### 🎨 UI-Verbesserungen (v2.1.4)
- **Kompakte Darstellung**: GroupBox-Abstände reduziert für bessere Raumausnutzung
- **Progress-Dialog**: Visueller Fortschritt für Gruppenrichtlinien-Updates mit Abbruch-Funktion
- **Benutzerfreundlichkeit**: Elapsed-Time-Anzeige und interaktive Kontrolle

#### 🔧 Prozess-Überwachung (v2.1.4)
- **Duplizierter Prozess-Check**: Verhindert mehrfache gpupdate-Ausführungen
- **Exit-Code-Auswertung**: Korrekte Prozess-Status-Erkennung mit Output-Capture
- **Memory-Leak-Fixes**: Ordnungsgemäße Ressourcen-Freigabe in allen kritischen Bereichen
- **Thread-sichere Updates**: Dispatcher-basierte UI-Updates für bessere Stabilität

#### 🔧 Aktionen-Bereich (v2.0.9)
- **Gruppenrichtlinien-Update**: Führt `gpupdate /force` asynchron aus
- **Asynchrone Ausführung**: GUI bleibt während der Ausführung bedienbar
- **PID-Tracking**: Detailliertes Logging mit Prozess-IDs
- **Timeout-Schutz**: Automatischer Timeout nach 2 Minuten
- **Robuste Fehlerbehandlung**: Runspace-basierte Prozessüberwachung

#### 📥 Erweiterte Downloads (v2.0.9)
- **Aktualisierungsdatum**: Download-Liste zeigt Stand der Daten an
- **Deutsche Datumsformatierung**: Benutzerfreundliches Format (dd.MM.yyyy)
- **Neue Downloads**: Belegtransfer V. 5.47, LODAS V. 4.24

#### 📋 Changelog-Viewer (v2.0.9)
- **Update-Historie**: Anzeige der letzten 3 Versionen
- **GitHub-Integration**: Lädt aktuelle Changelog-Daten
- **Deutsche Formatierung**: Übersichtliche Darstellung mit Emojis
- **Offline-Sicherheit**: Fallback bei Netzwerkproblemen

#### 🐛 Kritische Bugfixes (v2.0.9)
- **Update-Prozess**: `Set-Settings` → `Save-Settings` Fehler behoben
- **Settings-Management**: Globale Variable korrekt aktualisiert
- **Update-Stabilität**: Vollständige Wiederherstellung des Update-Systems

### Changelog (Neueste Versionen)
- **v2.0.9**: Kritischer Update-Bugfix + Changelog-Viewer + Aktionen-Bereich
- **v2.0.8**: Gruppenrichtlinien-Update + erweiterte Downloads + Datumsanzeige
- **v2.0.7**: PSObject zu Hashtable Konvertierungsfehler behoben
- **v2.0.6**: DATEV Tools vollständig implementiert (8 neue Tools)
- **v2.0.5**: System Tools hinzugefügt

## 📄 Lizenz

Dieses Projekt ist für den internen Gebrauch bei HEES GmbH entwickelt.

---

**Hinweis**: Diese Anwendung verbindet sich automatisch mit GitHub für Updates und Download-Konfigurationen. Stellen Sie sicher, dass eine Internetverbindung verfügbar ist.

### 🎯 Besondere Features
- **🆕 Zentrale Konfiguration**: Alle URLs, Pfade und Einstellungen an einem Ort (v2.1.0)
- **🆕 Asynchrone Gruppenrichtlinien-Updates**: Ohne GUI-Blockierung
- **🆕 Changelog-Integration**: Vollständige Update-Historie verfügbar
- **🆕 Erweiterte Download-Verwaltung**: Mit Aktualisierungsdatum
- **Intelligente DATEV-Pfad-Suche**: Automatische Erkennung von DATEV-Installationen
- **Robuste Fehlerbehandlung**: Benutzerfreundliche MessageBoxen bei Problemen
- **Vollständiges Logging**: Alle Aktionen werden mit PID-Tracking protokolliert
- **Backup-System**: Automatische Backups vor Updates mit Rollback-Funktion
- **Runspace-basierte Überwachung**: Moderne asynchrone Prozessbehandlung

# DATEV Wartungsaufgaben-Automatisierung

## Übersicht

Dieses PowerShell-Skript automatisiert die Einrichtung von Windows-Aufgabenplanung für DATEV-Datenbankwartung gemäß **Abschnitt 2.3.1** der DATEV-Dokumentation "Microsoft SQL Server (DATEV): Datenbanken optimieren".

## Funktionen

### 🔍 Automatische DATEV-Erkennung
- Erkennt DATEV-Installationen über `%DATEVPP%` Umgebungsvariable
- Identifiziert SQL Server Edition (Express/Standard)
- Scannt verfügbare Wartungsskripte:
  - `RunMaintenanceWE.cmd` (wöchentlich, empfohlen)
  - `RunMaintenance.cmd` (täglich)

### 🖥️ Benutzerfreundliche WPF-GUI
- **DATEV-Erkennung Panel**: Status und verfügbare Skripte
- **Aufgaben-Konfiguration**: Name, Beschreibung, Skript-Auswahl
- **Zeitplan-Konfiguration**: Häufigkeit, Wochentag, Uhrzeit
- **Echtzeit-Protokollierung**: Detaillierte Statusmeldungen
- **Konflikt-Erkennung**: Warnung vor Zeitplan-Überschneidungen

### ⚙️ Intelligente Konfiguration
- **Empfohlene Einstellungen**:
  - Wöchentlich: Samstag 02:00 Uhr
  - Täglich: 23:00 Uhr
- **Automatische Namensgebung**: `DATEV_Wartung_[Häufigkeit]_[Datum]`
- **Kollisionserkennung**: Warnung bei Überschneidung mit:
  - Sicherungsläufen (01:00-05:00)
  - Programmaktualisierungen
  - Bestehenden DATEV-Aufgaben

### 🛡️ Sicherheit & Validierung
- **Administrator-Rechte**: Automatische UAC-Elevation
- **Systemvoraussetzungen**: PowerShell 5.1+, Task Scheduler Service
- **Eingabevalidierung**: Vollständige Überprüfung aller Parameter
- **Fehlerbehandlung**: Umfassende Exception-Behandlung

## Systemanforderungen

- **Betriebssystem**: Windows 10/11
- **PowerShell**: Version 5.1 oder höher
- **Berechtigung**: Administrator-Rechte erforderlich
- **DATEV**: Installierte DATEV-Software mit Wartungsskripten
- **.NET Framework**: 4.7.2 oder höher

## Installation & Verwendung

### 1. Vorbereitung
```powershell
# Als Administrator ausführen
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 2. Skript starten
```powershell
# Direkt ausführen
.\DATEV-Wartungsaufgaben-Automatisierung.ps1

# Oder mit PowerShell ISE/VSCode
```

### 3. GUI-Bedienung

#### Schritt 1: DATEV-Erkennung
1. Klicken Sie auf **"Scannen"**
2. Überprüfen Sie die erkannten Pfade und Skripte
3. Wählen Sie das gewünschte Wartungsskript aus

#### Schritt 2: Aufgaben-Konfiguration
1. **Aufgabenname**: Wird automatisch generiert, kann angepasst werden
2. **Beschreibung**: Beschreibung der Wartungsaufgabe
3. **Wartungsskript**: Auswahl aus erkannten Skripten
4. **Privilegien**: "Mit höchsten Privilegien ausführen" (empfohlen)

#### Schritt 3: Zeitplan festlegen
1. **Häufigkeit**: Wöchentlich (empfohlen) oder Täglich
2. **Wochentag**: Bei wöchentlicher Ausführung (Standard: Samstag)
3. **Uhrzeit**: Startzeit der Wartung (Standard: 02:00)
4. **Konflikte prüfen**: Überprüfung auf Zeitplan-Kollisionen

#### Schritt 4: Ausführung
1. **Vorschau**: Zusammenfassung der Konfiguration anzeigen
2. **Aufgabe erstellen**: Windows-Aufgabe wird erstellt
3. **Protokoll**: Detaillierte Statusmeldungen verfolgen

## Ausgabe & Protokollierung

### Log-Datei
- **Speicherort**: `%TEMP%\DATEV-Wartungsaufgaben-[Zeitstempel].log`
- **Format**: `[Datum Zeit] [Level] Nachricht`
- **Level**: INFO, WARNING, ERROR, SUCCESS

### Beispiel-Log
```
[2025-01-07 11:30:00] [INFO] DATEV Wartungsaufgaben-Automatisierung wird gestartet...
[2025-01-07 11:30:01] [SUCCESS] DATEV-Installation gefunden: C:\DATEV
[2025-01-07 11:30:02] [SUCCESS] Skript gefunden: RunMaintenanceWE.cmd (Standard)
[2025-01-07 11:30:05] [SUCCESS] Wartungsaufgabe 'DATEV_Wartung_Wöchentlich_20250107' erfolgreich erstellt!
```

## Erstellte Windows-Aufgabe

### Eigenschaften
- **Speicherort**: `Aufgabenplanung (lokal) > Aufgabenplanungsbibliothek > DATEV eG`
- **Sicherheitskontext**: SYSTEM-Account
- **Privilegien**: Höchste Privilegien
- **Timeout**: 3 Stunden
- **Startbedingung**: Unabhängig von Benutzeranmeldung

### Beispiel-Konfiguration
```
Name: DATEV_Wartung_Wöchentlich_20250107
Beschreibung: Automatische DATEV-Datenbankwartung (erstellt durch DATEV-Toolbox 2.0)
Trigger: Wöchentlich, Samstag 02:00
Aktion: C:\DATEV\PROGRAMM\B0000454\Maintenance\RunMaintenanceWE.cmd
```

## Fehlerbehebung

### Häufige Probleme

#### "DATEV-Installation nicht gefunden"
- **Lösung**: DATEVPP Umgebungsvariable prüfen
- **Befehl**: `echo %DATEVPP%` in CMD
- **Alternative**: Manuelle Pfad-Eingabe in Registry

#### "Keine Wartungsskripte gefunden"
- **Ursache**: Unvollständige DATEV-Installation
- **Lösung**: DATEV-Installation reparieren/vervollständigen
- **Pfad prüfen**: `%DATEVPP%\PROGRAMM\B000045x\Maintenance`

#### "Task Scheduler nicht verfügbar"
- **Lösung**: Task Scheduler Service starten
- **Befehl**: `net start schedule`
- **Service**: "Aufgabenplanung" in services.msc

#### "Zugriff verweigert"
- **Ursache**: Fehlende Administrator-Rechte
- **Lösung**: PowerShell als Administrator starten
- **UAC**: Benutzerkontensteuerung bestätigen

### Debug-Modus
```powershell
# Detaillierte Fehlerausgabe
$VerbosePreference = 'Continue'
$DebugPreference = 'Continue'
.\DATEV-Wartungsaufgaben-Automatisierung.ps1
```

## Wartung & Updates

### Aufgabe überprüfen
```powershell
# Task Scheduler öffnen
taskschd.msc

# Oder PowerShell
Get-ScheduledTask -TaskPath "\DATEV eG\" | Format-Table
```

### Aufgabe bearbeiten
1. Task Scheduler öffnen (`taskschd.msc`)
2. Navigation: `DATEV eG` Ordner
3. Aufgabe auswählen und "Eigenschaften" öffnen
4. Einstellungen nach Bedarf anpassen

### Aufgabe löschen
```powershell
# PowerShell
Unregister-ScheduledTask -TaskName "DATEV_Wartung_*" -TaskPath "\DATEV eG\" -Confirm:$false
```

## Technische Details

### PowerShell-Module
- **DATEV-Detection**: Automatische Erkennung und Pfad-Ermittlung
- **Task-Creation**: Windows-Aufgabenplanung über COM-Objekte
- **Validation**: Umfassende Eingabe- und Systemvalidierung
- **Logging**: Detaillierte Protokollierung aller Aktionen
- **GUI-Controller**: WPF-Event-Handling und Datenvalidierung

### COM-Objekte
- **Schedule.Service**: Task Scheduler COM-Interface
- **Task Definition**: Aufgaben-Konfiguration
- **Triggers**: Zeitplan-Definition
- **Actions**: Auszuführende Aktionen

### WPF-Komponenten
- **XAML-Definition**: Inline GUI-Layout
- **Event-Handler**: Button-Clicks und Eingabe-Validierung
- **Data-Binding**: Dynamische Inhalts-Updates
- **Progress-Indication**: Fortschrittsanzeige während Erstellung

## Support & Kontakt

Bei Fragen oder Problemen:
1. **Log-Datei** prüfen (`%TEMP%\DATEV-Wartungsaufgaben-*.log`)
2. **DATEV-Dokumentation** konsultieren (Dokument 1071153)
3. **System-Administrator** kontaktieren
4. **DATEV-Support** bei installationsspezifischen Problemen

---

**Version**: 1.0  
**Erstellt**: Januar 2025  
**Kompatibilität**: DATEV-Toolbox 2.0  
**Lizenz**: Für DATEV-Kunden zur freien Verwendung
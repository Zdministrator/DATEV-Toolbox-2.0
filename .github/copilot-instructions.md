<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# DATEV-Toolbox 2.0 - Copilot Instructions

## 🌐 Kommunikation & Sprache
- **Sprache**: Immer Deutsch verwenden in der Kommunikation mit dem Benutzer
- **Code-Kommentare**: Deutsche Kommentare für bessere Verständlichkeit
- **Dokumentation**: Alle Texte und Beschreibungen auf Deutsch
- **Fehlermeldungen**: Benutzerfreundliche deutsche Fehlermeldungen bevorzugen

## 🎯 Projekt-Kontext
Dies ist eine WPF-basierte PowerShell-Anwendung für DATEV-Umgebungen mit automatischen Updates, direkten Downloads und umfassenden Tools.

## 💻 PowerShell-Kompatibilität
- **PowerShell 5.1+ Kompatibilität**: Code muss mit Windows PowerShell 5.1 und PowerShell Core kompatibel sein
- **Keine PowerShell 7+ exklusiven Features**: Verwende keine Features die nur in PowerShell 7+ verfügbar sind
- **WPF-Integration**: Code nutzt `Add-Type -AssemblyName PresentationFramework` für GUI
- **Standard-Shell**: `pwsh.exe` wird als Standard verwendet

## 🏗️ Architektur-Prinzipien

### Code-Struktur
- **Regionen verwenden**: Code in logische `#region` / `#endregion` Blöcke gliedern
- **Funktions-basiert**: Jede Funktionalität in separate Funktionen auslagern
- **Event-Handler**: WPF Event-Handler konsistent implementieren
- **Fehlerbehandlung**: Immer try-catch mit `Write-Log` verwenden

### Naming Conventions
- **Funktionen**: `Verb-Noun` Pattern (z.B. `Start-DATEVProgram`, `Get-Settings`)
- **Variablen**: `$camelCase` für lokale, `$script:PascalCase` für Script-Scope
- **GUI-Elemente**: `$btnElementName`, `$txtElementName`, `$cmbElementName`
- **Pfade**: Immer absolute Pfade mit `Join-Path` verwenden

## 🔧 DATEV-Spezifische Entwicklung

### DATEV-Integration
- **Umgebungsvariable**: `$env:DATEVPP` für DATEV-Hauptpfad nutzen
- **Fallback-Pfade**: Immer Standard DATEV-Pfade als Backup definieren
- **Programm-Suche**: Intelligente Pfad-Suche mit mehreren Möglichkeiten
- **Fehlerbehandlung**: Benutzerfreundliche MessageBoxen bei DATEV-Problemen

### Unterstützte DATEV-Tools
- DATEV-Arbeitsplatz, Installationsmanager, Servicetool
- KonfigDB-Tools, EODBconfig, EO Aufgabenplanung
- NGENALL 4.0, Leistungsindex (spezielle Doppel-Ausführung)

## 📝 Logging-System

### Log-Level
- **INFO**: Normale Betriebsmeldungen
- **WARN**: Warnungen (werden zusätzlich in Error-Log.txt gespeichert)
- **ERROR**: Fehler (werden zusätzlich in Error-Log.txt gespeichert)

### Logging-Pattern
```powershell
Write-Log -Message "Beschreibung der Aktion" -Level 'INFO'
Write-Log -Message "Warnung: Problem erkannt" -Level 'WARN'
Write-Log -Message "Fehler: $($_.Exception.Message)" -Level 'ERROR'
```

## 🔄 Update-System

### JSON-Handling
- **PSObject zu Hashtable**: Immer sichere Konvertierung von `ConvertFrom-Json` Objekten
- **Settings-Management**: Einstellungen als Hashtable behandeln, nicht als PSObject
- **Version-Vergleich**: Semantic Versioning mit `Compare-Version` Funktion

### Update-Prozess
- **Backup-System**: Automatische Backups vor Updates
- **Rollback-Fähigkeit**: Wiederherstellung bei fehlgeschlagenen Updates
- **Batch-Skript**: Verzögertes Update über externes Batch-Skript

## 🎨 GUI-Entwicklung

### XAML-Struktur
- **Tab-basiert**: Hauptnavigation über TabControl
- **GroupBox-Organisation**: Verwandte Buttons in GroupBoxes gruppieren
- **ScrollViewer**: Für längere Inhalte ScrollViewer verwenden
- **Responsive Design**: Margin und Padding konsistent verwenden

### Button-Integration
- **Event-Handler**: Konsistente Add_Click Pattern
- **Referenzen**: Alle GUI-Elemente mit `FindName()` referenzieren
- **Null-Checks**: Immer prüfen ob GUI-Element gefunden wurde

## 📁 Datei-Management

### AppData-Struktur
```
%APPDATA%\DATEV-Toolbox 2.0\
├── settings.json           # Benutzereinstellungen
├── Error-Log.txt          # Fehlerprotokoll
├── datev-downloads.json   # Lokale Download-Konfiguration
├── Jahresplanung_2025.ics # DATEV Update-Termine
└── Updates/               # Update-Dateien und Backups
```

### Download-Management
- **Download-Ordner**: `~/Downloads/DATEV-Toolbox`
- **Asynchrone Downloads**: WebClient mit Event-Handlers
- **TLS 1.2**: Immer für sichere Downloads erzwingen

## 🛡️ Sicherheit & Robustheit

### Fehlerbehandlung
- **Try-Catch**: Jede kritische Operation absichern
- **User-Friendly**: MessageBoxes mit klaren Fehlerbeschreibungen
- **Logging**: Alle Fehler ins Log und Error-Log.txt schreiben
- **Graceful Degradation**: Funktionalität auch bei Teilfehlern erhalten

### Input-Validation
- **Pfad-Validierung**: Immer `Test-Path` vor Datei-Operationen
- **URL-Validierung**: URI-Parsing für Download-URLs
- **Version-Validierung**: Semantic Versioning Pattern prüfen

## 🔗 GitHub-Integration

### Update-Mechanismus
- **Update-Check-URL**: `https://github.com/Zdministrator/DATEV-Toolbox-2.0/raw/main/version.json`
- **Download-URL**: `https://github.com/Zdministrator/DATEV-Toolbox-2.0/raw/main/DATEV-Toolbox 2.0.ps1`
- **Downloads-Config**: `https://github.com/Zdministrator/DATEV-Toolbox-2.0/raw/main/datev-downloads.json`

### Version-Management
- **Semantic Versioning**: MAJOR.MINOR.PATCH Format
- **Changelog**: Strukturierte Änderungshistorie in version.json
- **Release-Daten**: ISO 8601 Format (yyyy-MM-dd)

## 📋 Code-Qualität

### Best Practices
- **Kommentare**: Jede Funktion mit Purpose-Kommentar
- **Parameter-Validation**: `[Parameter(Mandatory = $true)]` wo nötig
- **Type-Safety**: Explizite Typen für kritische Variablen
- **Memory-Management**: WebClient und andere Ressourcen ordnungsgemäß entsorgen

### Performance
- **Asynchrone Operationen**: Downloads und Updates nicht blockierend
- **Resource-Cleanup**: Temporäre Dateien nach Gebrauch löschen
- **Efficient Logging**: Log-Level für Performance-kritische Bereiche beachten

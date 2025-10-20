# 🎯 Implementierungsplan: Tray-Icon mit Notifications

**Projekt:** DATEV-Toolbox 2.0  
**Feature:** System-Tray-Integration mit Benachrichtigungen  
**Datum:** 20.10.2025  
**Geschätzte Dauer:** 2-3 Stunden  

---

## 📋 Übersicht

Integration eines System-Tray-Icons mit Kontextmenü, Minimize-to-Tray-Funktionalität und Benachrichtigungssystem in die bestehende DATEV-Toolbox 2.0.

---

## 🎯 Ziele

- ✅ System-Tray-Icon mit Windows.Forms.NotifyIcon
- ✅ Minimize-to-Tray beim Minimieren des Fensters
- ✅ Kontextmenü mit Quick-Actions
- ✅ Balloon-Benachrichtigungen
- ✅ Doppelklick zum Wiederherstellen
- ✅ Ordnungsgemäße Resource-Verwaltung
- ❌ **KEINE** Update-Benachrichtigungen (explizit ausgeschlossen)

---

## 📊 Implementierungsschritte

### **Phase 1: Vorbereitung** ⏱️ ~15 Min

#### Schritt 1.1: Assembly-Laden erweitern
- **Datei:** `DATEV-Toolbox 2.0.ps1`
- **Zeile:** ~10-13 (Region: Assemblies laden)
- **Aktion:** `System.Windows.Forms` und `System.Drawing` hinzufügen

```powershell
# VORHER:
Add-Type -AssemblyName PresentationFramework

# NACHHER:
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
```

**Risiko:** ⚠️ Niedrig - Standard-Assemblies in allen Windows-Versionen verfügbar  
**Test:** Assembly-Load erfolgreich, keine Fehler

---

### **Phase 2: Tray-Icon-System** ⏱️ ~45 Min

#### Schritt 2.1: Neue Region erstellen
- **Position:** Nach Region "Logging-Funktionen" (~Zeile 100)
- **Aktion:** Neue Region `#region Tray-Icon System` einfügen

#### Schritt 2.2: Globale Variable
```powershell
$script:TrayIcon = $null
```

#### Schritt 2.3: Funktion `Initialize-TrayIcon`
**Verantwortlichkeiten:**
- NotifyIcon-Objekt erstellen
- Icon aus Skript oder Windows-Standard laden
- Tooltip setzen ("DATEV-Toolbox 2.0")
- Kontextmenü mit Quick-Actions erstellen
- Event-Handler registrieren

**Kontextmenü-Einträge:**
1. ➡️ **Fenster anzeigen** → `Show-MainWindow`
2. --- *Separator* ---
3. 🖥️ **DATEV-Arbeitsplatz** → `Start-DATEVProgram`
4. 📁 **Download-Ordner öffnen** → `Open-DownloadFolder`
5. --- *Separator* ---
6. ❌ **Beenden** → `Close-Application`

**Error-Handling:**
- Try-Catch um gesamte Initialisierung
- Fallback auf Standard-Windows-Icon falls Custom-Icon fehlt
- Logging aller Schritte (DEBUG/INFO/ERROR)

#### Schritt 2.4: Funktion `Show-TrayNotification`
**Parameter:**
- `[string]$Title` (Mandatory)
- `[string]$Message` (Mandatory)
- `[ValidateSet('None', 'Info', 'Warning', 'Error')]$Icon` (Default: 'Info')
- `[int]$Duration` (Default: 5000ms)

**Funktionalität:**
- Null-Check für TrayIcon
- Icon-Typ-Konvertierung (String → ToolTipIcon)
- BalloonTip anzeigen
- Logging der Benachrichtigung

#### Schritt 2.5: Funktion `Show-MainWindow`
**Verantwortlichkeiten:**
- Fenster anzeigen (`$window.Show()`)
- WindowState auf Normal setzen
- ShowInTaskbar aktivieren
- Fenster aktivieren/fokussieren
- Logging

#### Schritt 2.6: Funktion `Close-Application`
**Verantwortlichkeiten:**
- Tray-Icon bereinigen (via `Close-TrayIcon`)
- Fenster schließen (`$window.Close()`)
- Logging der Shutdown-Sequenz

#### Schritt 2.7: Funktion `Close-TrayIcon`
**Verantwortlichkeiten:**
- TrayIcon unsichtbar machen
- Dispose() aufrufen
- Variable auf `$null` setzen
- Error-Handling mit Try-Catch

**Code-Qualität:**
- ✅ Alle Funktionen mit Comment-Based Help
- ✅ Try-Catch um kritische Operationen
- ✅ Konsistentes Logging (DEBUG/INFO/WARN/ERROR)
- ✅ Parameter-Validierung

---

### **Phase 3: Window-Events Integration** ⏱️ ~30 Min

#### Schritt 3.1: StateChanged-Event
- **Position:** Nach `$window.Add_Closing` (~Zeile 1950)
- **Aktion:** Event-Handler für Minimize-to-Tray

```powershell
$window.Add_StateChanged({
    if ($window.WindowState -eq [System.Windows.WindowState]::Minimized) {
        $window.Hide()
        $window.ShowInTaskbar = $false
        
        Show-TrayNotification -Title "DATEV-Toolbox" `
            -Message "In den Systembereich minimiert. Doppelklick zum Anzeigen." `
            -Icon 'Info' `
            -Duration 3000
        
        Write-Log -Message "Fenster in System-Tray minimiert" -Level 'DEBUG'
    }
})
```

**Verhalten:**
- Bei Minimize: Fenster ausblenden + aus Taskbar entfernen
- Benachrichtigung anzeigen (3 Sekunden)
- Logging

#### Schritt 3.2: Closing-Event erweitern
- **Position:** Innerhalb `$window.Add_Closing` (~Zeile 1943)
- **Aktion:** `Close-TrayIcon` vor Settings-Speicherung aufrufen

```powershell
$window.Add_Closing({
    Write-Log -Message "Anwendung wird beendet, bereinige Ressourcen..." -Level 'INFO'
    
    # Tray-Icon bereinigen
    Close-TrayIcon
    
    # Settings sofort speichern falls noch ausstehend
    # ...existing code...
})
```

#### Schritt 3.3: Tray-Icon-Initialisierung
- **Position:** Nach `$window.Add_StateChanged`, vor Log-Rotation (~Zeile 1960)
- **Aktion:** `Initialize-TrayIcon` aufrufen

```powershell
# Tray-Icon initialisieren
Initialize-TrayIcon
```

---

### **Phase 4: Settings-Integration (Optional)** ⏱️ ~15 Min

#### Schritt 4.1: Default-Settings erweitern
- **Funktion:** `Get-DefaultSettings` (~Zeile 170)
- **Aktion:** Neue Settings hinzufügen

```powershell
return @{
    DownloadPath      = Join-Path $env:USERPROFILE "Downloads\DATEV-Toolbox"
    AutoUpdate        = $true
    ShowDebugLogs     = $false
    LogLevel          = "INFO"
    MinimizeToTray    = $true      # NEU
    ShowNotifications = $true      # NEU
    WindowPosition    = @{
        Left = 100
        Top  = 100
    }
    LastUpdateCheck   = (Get-Date).AddDays(-1).ToString("yyyy-MM-dd")
}
```

#### Schritt 4.2: Settings-Nutzung (Zukünftig)
**Hinweis:** Aktuell nicht implementiert, aber vorbereitet für:
- Checkbox "In System-Tray minimieren" im Einstellungen-Tab
- Checkbox "Benachrichtigungen anzeigen"
- Logik: Nur minimieren wenn `$settings.MinimizeToTray -eq $true`

---

## 🧪 Test-Plan

### Manuelle Tests

#### Test 1: Initialisierung
- [ ] Script starten
- [ ] Tray-Icon sichtbar in Taskleiste
- [ ] Tooltip "DATEV-Toolbox 2.0" angezeigt
- [ ] Kein Fehler im Log

#### Test 2: Kontextmenü
- [ ] Rechtsklick auf Tray-Icon
- [ ] Alle 6 Menü-Einträge sichtbar
- [ ] "Fenster anzeigen" funktioniert
- [ ] "DATEV-Arbeitsplatz" startet Tool
- [ ] "Download-Ordner öffnen" öffnet Ordner
- [ ] "Beenden" schließt Anwendung

#### Test 3: Minimize-to-Tray
- [ ] Fenster minimieren
- [ ] Fenster verschwindet aus Taskbar
- [ ] Tray-Icon bleibt sichtbar
- [ ] Benachrichtigung erscheint (3 Sek)
- [ ] Doppelklick auf Tray-Icon öffnet Fenster

#### Test 4: Benachrichtigungen
- [ ] Minimize-Benachrichtigung (Info, 3 Sek)
- [ ] Verschiedene Icon-Typen testen (Info/Warning/Error)
- [ ] Dauer korrekt (3000ms / 5000ms)

#### Test 5: Shutdown
- [ ] "Beenden" aus Kontextmenü
- [ ] Tray-Icon verschwindet
- [ ] Anwendung schließt vollständig
- [ ] Keine Fehler im Log

#### Test 6: Error-Handling
- [ ] Mehrfaches Minimieren/Wiederherstellen
- [ ] Schnelles Öffnen/Schließen
- [ ] Keine Exception in Log

### Logging-Validierung
```powershell
# Erwartete Log-Einträge:
[DEBUG] Initialisiere System-Tray-Icon...
[DEBUG] Icon aus Skript extrahiert
[INFO]  System-Tray-Icon erfolgreich initialisiert (Icon: ...)
[DEBUG] Fenster in System-Tray minimiert
[DEBUG] Tray-Benachrichtigung angezeigt: ...
[DEBUG] Hauptfenster angezeigt und aktiviert
[DEBUG] Tray-Icon ordnungsgemäß entfernt
```

---

## 📁 Betroffene Dateien

### Zu modifizierende Dateien
1. **`DATEV-Toolbox 2.0.ps1`**
   - Assembly-Laden (Zeile ~10-13)
   - Neue Region Tray-Icon System (nach Zeile ~100)
   - Window-Events (Zeile ~1940-1960)
   - Default-Settings (Zeile ~170)

### Zu erstellende Dateien
- ✅ `TRAY-ICON-IMPLEMENTATION-PLAN.md` (diese Datei)

---

## ⚠️ Risiken & Mitigationen

### Risiko 1: Icon-Loading fehlschlägt
**Wahrscheinlichkeit:** Niedrig  
**Impact:** Niedrig  
**Mitigation:**
- Fallback auf `[System.Drawing.SystemIcons]::Application`
- Try-Catch mit Logging
- Anwendung funktioniert auch ohne Icon

### Risiko 2: Resource-Leak bei Dispose
**Wahrscheinlichkeit:** Sehr niedrig  
**Impact:** Niedrig  
**Mitigation:**
- Expliziter `Dispose()` Call
- Null-Check vor Dispose
- Try-Catch um Cleanup-Code

### Risiko 3: Event-Handler-Konflikte
**Wahrscheinlichkeit:** Sehr niedrig  
**Impact:** Mittel  
**Mitigation:**
- Nur ein StateChanged-Event
- Klare Trennung der Responsibilities
- Logging für Debugging

### Risiko 4: Performance bei vielen Benachrichtigungen
**Wahrscheinlichkeit:** Sehr niedrig  
**Impact:** Sehr niedrig  
**Mitigation:**
- Benachrichtigungen nur bei wichtigen Events
- Kurze Anzeigedauer (3-5 Sek)
- Keine Auto-Benachrichtigungen

---

## 🔄 Rollback-Strategie

Falls Probleme auftreten:

### Option 1: Feature-Deaktivierung
```powershell
# Kommentiere aus:
# Initialize-TrayIcon
# $window.Add_StateChanged(...)
# Close-TrayIcon
```

### Option 2: Git-Revert
```bash
git checkout HEAD~1 "DATEV-Toolbox 2.0.ps1"
```

### Option 3: Manuelle Entfernung
- Assembly-Zeilen entfernen
- Tray-Icon-Region löschen
- Event-Handler auskommentieren

---

## 📈 Erfolgs-Kriterien

- ✅ Alle 6 Tests erfolgreich bestanden
- ✅ Keine Fehler/Warnungen im Log
- ✅ Tray-Icon sichtbar und funktional
- ✅ Minimize-to-Tray funktioniert
- ✅ Benachrichtigungen werden angezeigt
- ✅ Ordnungsgemäßer Shutdown
- ✅ Keine Regression in bestehender Funktionalität

---

## 🚀 Deployment

### Pre-Deployment Checklist
- [ ] Git-Branch erstellen: `feature/tray-icon`
- [ ] Backup der aktuellen `DATEV-Toolbox 2.0.ps1`
- [ ] Alle Tests vorbereitet

### Deployment-Schritte
1. Assembly-Laden erweitern (Phase 1)
2. Tray-Icon-System implementieren (Phase 2)
3. Window-Events integrieren (Phase 3)
4. Tests durchführen
5. Settings erweitern (Phase 4, Optional)
6. Git commit & push

### Post-Deployment
- [ ] Alle Tests erfolgreich
- [ ] Logging überprüft
- [ ] Performance OK
- [ ] User-Feedback einholen

---

## 📝 Notizen

### Zukünftige Erweiterungen
- Einstellungen-Tab: Checkboxes für MinimizeToTray/ShowNotifications
- Keyboard-Shortcuts (Strg+M für Minimize)
- Custom-Icon-Datei statt Skript-Icon
- Erweiterte Benachrichtigungen (Progress, Click-Actions)
- Tray-Icon-Animation bei Aktivität

### Ausgeschlossene Features
- ❌ Update-Benachrichtigungen
- ❌ Auto-Start mit Windows
- ❌ System-Service-Integration

---

## 👥 Verantwortlichkeiten

- **Entwicklung:** GitHub Copilot
- **Testing:** Norman Zamponi
- **Review:** Norman Zamponi
- **Approval:** Norman Zamponi

---

## 📅 Zeitplan

| Phase | Dauer | Start | Ende |
|-------|-------|-------|------|
| Phase 1: Vorbereitung | 15 Min | - | - |
| Phase 2: Tray-Icon-System | 45 Min | - | - |
| Phase 3: Window-Events | 30 Min | - | - |
| Phase 4: Settings (Optional) | 15 Min | - | - |
| Testing | 30 Min | - | - |
| **GESAMT** | **~2-3h** | - | - |

---

## ✅ Review-Checkliste

Vor Merge/Deployment:

- [ ] Code-Review durchgeführt
- [ ] Alle Tests bestanden
- [ ] Logging validiert
- [ ] Performance getestet
- [ ] Dokumentation aktualisiert
- [ ] Git-Commit mit aussagekräftiger Message
- [ ] Feature-Branch in main gemergt

---

**Status:** 📋 Planung abgeschlossen - Bereit zur Implementierung  
**Erstellt:** 20.10.2025  
**Letzte Aktualisierung:** 20.10.2025

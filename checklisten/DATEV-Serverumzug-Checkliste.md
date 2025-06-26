# DATEV Serverumzug ohne Server-Anpassungs-Assistent - Checkliste

> **⚠️ Achtung**: Diese Checkliste ist nur für technisch versierte Anwender geeignet.  
> Bei unzureichendem technischen Wissen: Administrator oder DATEV Solution Partner kontaktieren.

**Quelle**: [DATEV Help Center - Dok.-Nr. 1080071](https://apps.datev.de/help-center/documents/1080071)  
**Letzte Aktualisierung**: 16.06.2025

---

## 📋 Voraussetzungen prüfen

- [ ] Computernamen von Quellserver und Zielserver sind identisch
- [ ] Namen sämtlicher Freigaben des Quellservers wurden für Zielserver notiert
- [ ] Zielserver wurde nach DATEV-Empfehlungen vorbereitet ([Dok.-Nr. 1070547](https://apps.datev.de/help-center/documents/1070547))
- [ ] Bei AD-Umzug: Anleitung für neue Domain berücksichtigen ([Dok.-Nr. 1071587](https://apps.datev.de/help-center/documents/1071587))

---

## 🔄 3.1 Vorbereitungen

### Datensicherung und Notprogramm
- [ ] **Datensicherung**: Vollsicherung aller DATEV-Datenbestände auf Quellserver durchführen  
  📖 [Leitfaden zur Datensicherung (Dok.-Nr. 1013210)](https://apps.datev.de/help-center/documents/1013210)
  
- [ ] **Notprogramm**: Aktuelles Notprogramm für Benutzerverwaltung und Rechteverwaltung erstellen  
  📖 [Notprogramm erstellen und ausführen (Dok.-Nr. 9218776)](https://apps.datev.de/help-center/documents/9218776)

---

## 🛑 3.2 Microsoft SQL Server am Quellserver stoppen

### DATEV SQL-Manager verwenden
- [ ] Als Administrator oder Benutzer mit Administrator-Rechten anmelden
- [ ] Windows-Taste drücken → Startmenü öffnen
- [ ] `dsqlm` eingeben
- [ ] **DATEV SQL-Manager (Administrator)** aus Trefferliste auswählen
  > Falls nicht gefunden: [Dok.-Nr. 1007043](https://apps.datev.de/help-center/documents/1007043)
  
- [ ] Menü: **Ansicht** → **Expertenmodus aktivieren**
- [ ] Menü: **Ansicht** → **Übersicht aktivieren**
- [ ] In Übersicht: `<Servername/Computername> (LOKAL)` wählen
- [ ] `<Instanzname>\DATEV_DBENGINE` wählen

### Datenbanken trennen und herunterfahren
- [ ] Rechtsklick auf SQL-Instanz → **Alle Datenbanken trennen** wählen
- [ ] Kontrollkästchen **"Trennen trotz bestehender Datenbankverbindungen?"** aktivieren → **OK**
- [ ] Rechtsklick auf SQL-Instanz → **Herunterfahren** wählen
- [ ] Im Fenster Herunterfahren → **Ja** klicken

---

## 🔑 3.3 Lizenz-Manager-Server Datenverzeichnis umziehen (optional)

> ✅ **Voraussetzung**: Der DATEV Lizenz-Manager-Server wird auf den Zielserver umgezogen

### Lizenzpool kopieren
- [ ] Lizenz-Manager-Server stoppen
- [ ] Verzeichnis `%DATEVDP%\Daten\LimaServ\LizPool\Standard` sichern
- [ ] Gesichertes Verzeichnis auf neuen Server kopieren:  
  Zielverzeichnis: `C:\ProgramData\DATEV\Daten\LimaServ\LizPool\Standard`

### Lizenz-Manager-Server am Quellserver deinstallieren

#### Option A: Automatische Deinstallation (empfohlen)
- [ ] SmartDocs-Tool für automatische Deinstallation verwenden
- [ ] Bei Problemen: `Smartdoc@service.datev.de` kontaktieren
- [ ] Nach erfolgreicher Deinstallation → **Master-Softwareschutz-Modul umstecken**

#### Option B: Manuelle Deinstallation
- [ ] Windows-Taste drücken
- [ ] `Programmdeinstallation` eingeben → **Programmdeinstallation** auswählen
- [ ] Kontrollkästchen **Lizenz-Manager Server** aktivieren → **Deinstallieren**
- [ ] Nach erfolgreicher Deinstallation → **Beenden**
- [ ] Konfigurationsdateien herunterladen: [Lizenz-Manager Konfigurationsdateien](https://www.datev.de/web/de/service-und-support/software-bereitstellung/download-bereich/it-loesungen-und-security/lizenz-manager-konfigurationsdateien/)
- [ ] Verzeichnis entpacken → Im Ordner `KONFIG` die Datei `Lizenz-Manager-Server entfernen.reg` ausführen

### Master-Softwareschutz-Modul umstecken
- [ ] Master-Softwareschutz-Modul vom alten Server abziehen
- [ ] Master-Softwareschutz-Modul am neuen Server anstecken

---

## 🗂️ 3.4 Freigaben am Quellserver entfernen

- [ ] DATEV-Freigaben am Quellserver entfernen (normalerweise `WINDVSW1`)

---

## 💾 3.5 Daten und Rechner der Domain "zwischenparken"

### Daten zwischenparken
Folgende Verzeichnisse auf einen Arbeitsplatz-PC mit ausreichender Festplattenkapazität oder externen Datenträger kopieren:

- [ ] **Inhalt des Verzeichnisses** der zuvor freigegebenen Freigabe (i.d.R. `WinDVSW1`)
- [ ] **ConfigDB** mit vollständigem Inhalt
- [ ] **Verzeichnis** `<LW>:\ProgramData\DATEV\DATEN\B0001502`  
  (wobei `<LW>:` das Laufwerk der lokalen Datenhaltung ist, meist `C:`)

> 📝 **Hinweis**: Die Serverdaten werden somit "zwischengeparkt" und können nach Austausch des Servers auf den neuen Server kopiert werden.

---

## 🆕 3.6 Zielserver installieren

- [ ] Neuen Server-PC an das Netzwerk anschließen
- [ ] Server-Betriebssystem auf dem Fileserver installieren
  > ⚠️ **Wichtig**: Demselben Computernamen wie dem alten Server geben  
  > Ab diesem Zeitpunkt darf sich der alte Server gleichen Namens nicht mehr im Netzwerk befinden (Namenskonflikt!)

- [ ] Neuen Server nach DATEV-Vorgaben konfigurieren
- [ ] Freigaben mit denselben Namen wie beim vorherigen Server erstellen
- [ ] **Noch keine DATEV-Komponente installieren**

---

## 🔄 3.7 Rechner der Domain hinzufügen und Daten übertragen

### Rechner hinzufügen und Daten übertragen
- [ ] Arbeitsstationen sowie vorhandene Windows Terminalserver in Domain des neuen Fileservers aufnehmen bzw. an Domain anmelden
- [ ] Per Login-Skript sicherstellen, dass Server-Freigaben wieder dieselben Netzlaufwerksbuchstaben erhalten wie beim vorherigen Server
- [ ] "Geparkte Daten" (aus Schritt 3.5) in die dafür vorgesehenen Freigaben/Verzeichnisse auf Zielserver kopieren (Verzeichnisstruktur muss angelegt werden)

### Active Directory übertragen
- [ ] **Bei unverändertem Domain-Namen**: 
  - [ ] AD nach Microsoft-Vorgabe auf Zielserver übertragen **ODER**
  - [ ] Benutzer am Zielserver im AD neu einrichten

---

## 🔧 3.8 Installationslinks anpassen und DATEV Serverplattform installieren

### DATEV Serverplattform installieren
- [ ] Netzlaufwerk der Freigabe (`WinDVSW1`) zuordnen
- [ ] Datei `Datev.Installation.Tools.Change.Extension.exe` ausführen  
  (i.d.R. unter `L:\DATEV\DATEN\INSTMAN\DEPOT\B0000047\002351524`)

#### Alternative bei fehlendem Depot:
- [ ] **DATEV Basis-Installer** verwenden ([Dok.-Nr. 1009250](https://apps.datev.de/help-center/documents/1009250)) **ODER**
- [ ] **ISO-Datei** für Mittelstand compact verwenden ([Dok.-Nr. 1008475](https://apps.datev.de/help-center/documents/1008475))

### Installation durchführen
- [ ] DATEV-Freigabe von Ziel- und Quellserver überprüfen → **OK** bestätigen
- [ ] Installation über Installationslink unter `L:\DATEV\<Programmversion>` starten  
  (alternativ über Basis-Installer oder ISO)
- [ ] **Serverplattform** installieren (optional mit Lizenz-Manager-Server)

---

## 🔐 3.9 NTFS-Berechtigung auf Datenbank-Dateien einschränken

### Werkzeug herunterladen und ausführen
- [ ] Werkzeug [serversec.exe](https://download.datev.de/download/serversec.exe) herunterladen
  > Bei Problemen: [Dok.-Nr. 1018340](https://apps.datev.de/help-center/documents/1018340)
  
- [ ] **OK** klicken im Fenster "Pfad für Entkomprimierung"  
  (Standardordner: `C:\TEMP`)

### Administrative Eingabeaufforderung verwenden
- [ ] Windows-Taste drücken
- [ ] `cmd` eingeben
- [ ] Rechtsklick auf **Eingabeaufforderung** → **Als Administrator ausführen**
- [ ] Befehl ausführen: `C:\TEMP\SERVERSEC.EXE <LW:>\WINDVSW1`  
  (wobei `<LW:>` das lokale Laufwerk ist, auf dem sich der freigegebene DATEV-Ordner befindet)
- [ ] Eingabeaufforderung schließen, nachdem die Rechte für die Datenbanken gesetzt sind

---

## ✅ Abschluss-Checkliste

- [ ] Alle Schritte erfolgreich durchgeführt
- [ ] Server-Funktionalität testen
- [ ] DATEV-Programme starten und Funktionalität prüfen
- [ ] Datensicherung des neuen Systems erstellen
- [ ] Dokumentation des Umzugs für zukünftige Referenz

---

## 📞 Support-Kontakte

- **Bei technischen Problemen**: Administrator oder DATEV Solution Partner
- **SmartDocs-Probleme**: `Smartdoc@service.datev.de`
- **Service-TAN**: [DATEV Service-TAN](https://apps.datev.de/servicekontakt-online/service-tan)

---

*Diese Checkliste basiert auf der offiziellen DATEV-Dokumentation (Dok.-Nr. 1080071) und dient als Orientierungshilfe für den Serverumzug ohne Server-Anpassungs-Assistent.*

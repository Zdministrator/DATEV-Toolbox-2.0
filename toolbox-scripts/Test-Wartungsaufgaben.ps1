#Requires -Version 5.1

<#
.SYNOPSIS
    Test-Skript für DATEV Wartungsaufgaben-Automatisierung
    
.DESCRIPTION
    Führt grundlegende Tests der Hauptfunktionen durch, ohne tatsächlich Aufgaben zu erstellen
    
.NOTES
    Version: 1.0
    Author: DATEV-Toolbox 2.0
#>

# Test-Funktionen aus dem Hauptskript laden
$scriptPath = Join-Path $PSScriptRoot "DATEV-Wartungsaufgaben-Automatisierung.ps1"

if (-not (Test-Path $scriptPath)) {
    Write-Error "Hauptskript nicht gefunden: $scriptPath"
    exit 1
}

# Nur die Funktionen laden, ohne GUI zu starten
$scriptContent = Get-Content $scriptPath -Raw
$functionsOnly = $scriptContent -replace 'Start-MainApplication.*$', ''

# Temporäre Datei für Funktionen erstellen
$tempScript = [System.IO.Path]::GetTempFileName() + ".ps1"
Set-Content -Path $tempScript -Value $functionsOnly

try {
    # Funktionen laden
    . $tempScript
    
    Write-Host "=== DATEV Wartungsaufgaben-Automatisierung - Funktionstest ===" -ForegroundColor Green
    Write-Host ""
    
    # Test 1: DATEV-Installation suchen
    Write-Host "Test 1: DATEV-Installation suchen..." -ForegroundColor Yellow
    $datevFound = Find-DATEVInstallation
    if ($datevFound) {
        Write-Host "✓ DATEV-Installation gefunden: $Global:DATEVPath" -ForegroundColor Green
    } else {
        Write-Host "✗ DATEV-Installation nicht gefunden" -ForegroundColor Red
    }
    Write-Host ""
    
    # Test 2: Wartungsskripte scannen
    Write-Host "Test 2: Wartungsskripte scannen..." -ForegroundColor Yellow
    $scripts = Get-MaintenanceScripts
    if ($scripts.Count -gt 0) {
        Write-Host "✓ $($scripts.Count) Wartungsskripte gefunden:" -ForegroundColor Green
        foreach ($script in $scripts) {
            $status = if ($script.Recommended) { "[EMPFOHLEN]" } else { "" }
            Write-Host "  - $($script.Name) ($($script.Edition)) $status" -ForegroundColor Cyan
        }
    } else {
        Write-Host "✗ Keine Wartungsskripte gefunden" -ForegroundColor Red
    }
    Write-Host ""
    
    # Test 3: Task Scheduler initialisieren
    Write-Host "Test 3: Task Scheduler initialisieren..." -ForegroundColor Yellow
    $taskSchedulerOk = Initialize-TaskScheduler
    if ($taskSchedulerOk) {
        Write-Host "✓ Task Scheduler erfolgreich initialisiert" -ForegroundColor Green
    } else {
        Write-Host "✗ Task Scheduler konnte nicht initialisiert werden" -ForegroundColor Red
    }
    Write-Host ""
    
    # Test 4: Zeitplan-Konflikte prüfen
    Write-Host "Test 4: Zeitplan-Konflikte prüfen..." -ForegroundColor Yellow
    $testTime = Get-Date -Hour 2 -Minute 0 -Second 0  # 02:00 Uhr
    $conflicts = Test-TaskScheduleConflicts -ScheduledTime $testTime -Frequency "Weekly"
    if ($conflicts.Count -eq 0) {
        Write-Host "✓ Keine Konflikte für 02:00 Uhr (wöchentlich)" -ForegroundColor Green
    } else {
        Write-Host "⚠ Potentielle Konflikte erkannt: $($conflicts -join ', ')" -ForegroundColor Yellow
    }
    Write-Host ""
    
    # Test 5: Systemvoraussetzungen prüfen
    Write-Host "Test 5: Systemvoraussetzungen prüfen..." -ForegroundColor Yellow
    $prereqsOk = Test-Prerequisites
    if ($prereqsOk) {
        Write-Host "✓ Alle Systemvoraussetzungen erfüllt" -ForegroundColor Green
    } else {
        Write-Host "✗ Systemvoraussetzungen nicht erfüllt" -ForegroundColor Red
    }
    Write-Host ""
    
    # Test 6: GUI-Komponenten testen (ohne Anzeige)
    Write-Host "Test 6: GUI-Komponenten validieren..." -ForegroundColor Yellow
    try {
        Add-Type -AssemblyName PresentationFramework -ErrorAction Stop
        Add-Type -AssemblyName PresentationCore -ErrorAction Stop
        Add-Type -AssemblyName WindowsBase -ErrorAction Stop
        Write-Host "✓ WPF-Assemblies erfolgreich geladen" -ForegroundColor Green
        
        # XAML-Syntax prüfen
        $xamlContent = $xaml
        if ($xamlContent -and $xamlContent.Length -gt 1000) {
            Write-Host "✓ XAML-Definition vorhanden ($(($xamlContent.Length / 1024).ToString('F1')) KB)" -ForegroundColor Green
        } else {
            Write-Host "✗ XAML-Definition fehlerhaft oder zu klein" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ WPF-Assemblies konnten nicht geladen werden: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""
    
    # Zusammenfassung
    Write-Host "=== Test-Zusammenfassung ===" -ForegroundColor Green
    $totalTests = 6
    $passedTests = 0
    
    if ($datevFound) { $passedTests++ }
    if ($scripts.Count -gt 0) { $passedTests++ }
    if ($taskSchedulerOk) { $passedTests++ }
    if ($conflicts.Count -eq 0) { $passedTests++ }
    if ($prereqsOk) { $passedTests++ }
    
    try {
        Add-Type -AssemblyName PresentationFramework -ErrorAction Stop
        $passedTests++
    } catch { }
    
    $successRate = ($passedTests / $totalTests) * 100
    
    Write-Host "Erfolgreich: $passedTests/$totalTests Tests ($($successRate.ToString('F0'))%)" -ForegroundColor $(if ($successRate -ge 80) { "Green" } elseif ($successRate -ge 60) { "Yellow" } else { "Red" })
    
    if ($successRate -ge 80) {
        Write-Host ""
        Write-Host "🎉 Das Skript ist bereit für den produktiven Einsatz!" -ForegroundColor Green
        Write-Host "Starten Sie die GUI mit: .\DATEV-Wartungsaufgaben-Automatisierung.ps1" -ForegroundColor Cyan
    } elseif ($successRate -ge 60) {
        Write-Host ""
        Write-Host "⚠ Das Skript funktioniert grundsätzlich, aber es gibt Einschränkungen." -ForegroundColor Yellow
        Write-Host "Prüfen Sie die fehlgeschlagenen Tests und beheben Sie die Probleme." -ForegroundColor Yellow
    } else {
        Write-Host ""
        Write-Host "❌ Das Skript ist nicht einsatzbereit." -ForegroundColor Red
        Write-Host "Beheben Sie die kritischen Probleme vor der Verwendung." -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Log-Datei: $Global:LogPath" -ForegroundColor Gray
    
}
finally {
    # Temporäre Datei löschen
    if (Test-Path $tempScript) {
        Remove-Item $tempScript -Force
    }
}
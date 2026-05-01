# BeastSandbox — iOS App

Hacker-Terminal Sandbox App für iPhone.
License-geschützt, mit Terminal, File Manager, Code Editor, Network Tools & Settings.

---

## Voraussetzungen
- Mac mit Xcode 15+
- Apple ID (kostenlos reicht für ESign/Sideload)

---

## Schritt 1 — Projekt öffnen
```
Doppelklick auf: BeastSandbox.xcodeproj
```

## Schritt 2 — Bundle ID + Team setzen
1. Links in Xcode: `BeastSandbox` Target anklicken
2. Tab: **Signing & Capabilities**
3. Team: deine Apple ID auswählen (oder "None" für unsigned build)
4. Bundle Identifier: `com.beastmeds.BeastSandbox` (oder ändern)

## Schritt 3 — License Keys bearbeiten
Datei: `LicenseGateView.swift`, Zeile ~13:
```swift
private let validKeys: Set<String> = [
    "BSMP-2024-AAAA-0001",
    "BSMP-2024-BBBB-0002",
    "BSMP-DEMO-FREE-TEST"
    // add more here
]
```

## Schritt 4 — .ipa bauen
```
Xcode Menü → Product → Archive
→ Distribute App
→ Ad Hoc ODER Development
→ Export → .ipa wird gespeichert
```

Für **unsigned .ipa** (für ESign):
```
Product → Archive → Distribute App
→ "Custom" → "Copy App" 
→ dann manuell in .ipa umpacken:
   mkdir Payload
   cp -r BeastSandbox.app Payload/
   zip -r BeastSandbox.ipa Payload/
```

## Schritt 5 — ESign installieren
1. `.ipa` auf iPhone übertragen (AirDrop, Files App, etc.)
2. In ESign öffnen
3. Mit deinem eigenen Zertifikat signieren
4. Installieren

---

## App Features
- **License Gate** — beim ersten Start, Key wird in UserDefaults gespeichert
- **Terminal** — Shell-Simulator mit ~15 Befehlen + History
- **File Manager** — virtuelles `/sandbox` Filesystem, Ordner/Dateien anlegen
- **Code Editor** — JS/JSON/SH Editor mit Run-Funktion
- **Network Tools** — Ping, HTTP Request, Port Scan (simuliert)
- **Settings** — License anzeigen / widerrufen

---

## License Keys verwalten
Keys sind hardcoded in `LicenseGateView.swift`.
Für dynamische Keys (Server-Validierung) → API-Call in `activate()` einbauen.

---

BeastSMP © 2024 — beastmeds

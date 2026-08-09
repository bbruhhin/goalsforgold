# GoalsFORGold – by My Swiss-Ski

Zielvereinbarungs-Webapp für Trainer:innen und Athlet:innen: Saisonziele, SOLL/IST-Zustand,
Massnahmen pro Phase, Check-ins mit Selbst-/Fremdbild, Stats und Flow-Check.
Basiert auf dem Zielvereinbarungsblatt und dem Flow-Prinzip (Csíkszentmihályi).

## Dateien

| Datei | Zweck |
|---|---|
| `index.html` | die komplette App (HTML, CSS, JS, Bilder eingebettet) |
| `manifest.webmanifest` | Webapp-Manifest (Name, Icons, Farben) |
| `sw.js` | Service Worker – Offline-Cache |
| `icon-192.png`, `icon-512.png` | App-Icons (Android/Chrome) |
| `apple-touch-icon.png` | Home-Screen-Icon (iPhone/iPad) |
| `favicon.png` | Browser-Tab-Icon |

## Deployment auf GitHub Pages

1. Neues Repository auf GitHub anlegen (z. B. `goalsforgold`).
2. Diese Dateien ins Repository pushen:

```bash
git init
git add index.html manifest.webmanifest sw.js icon-192.png icon-512.png apple-touch-icon.png favicon.png README.md
git commit -m "GoalsFORGold Webapp"
git branch -M main
git remote add origin https://github.com/DEIN-BENUTZERNAME/goalsforgold.git
git push -u origin main
```

3. Im Repository: **Settings → Pages → Source: Deploy from a branch**, Branch `main`, Ordner `/ (root)`, speichern.
4. Nach 1–2 Minuten ist die App erreichbar unter
   `https://DEIN-BENUTZERNAME.github.io/goalsforgold/`

## Auf dem Home-Screen installieren

- **iPhone/iPad (Safari):** Seite öffnen → Teilen-Symbol → «Zum Home-Bildschirm» –
  das GoalsFORGold-Icon (Negativ-Logo auf Schwarz) erscheint wie eine App, im Vollbild ohne Browserleiste.
- **Android (Chrome):** Seite öffnen → Menü ⋮ → «App installieren» bzw. «Zum Startbildschirm hinzufügen».

Dank Service Worker funktioniert die App nach dem ersten Besuch auch offline.

## Wichtige Hinweise

- **Datenhaltung:** Alle Daten liegen lokal im Browser (localStorage) des jeweiligen Geräts.
  Es gibt keinen Server – Coach und Athlet:innen auf verschiedenen Geräten sehen
  jeweils ihre eigene lokale Kopie.
- **Login:** Die Anmeldung (Coach-Konto, Athlet:innen-Passwörter) gilt pro Gerät/Browser
  und ist als Komfort-/Demo-Funktion zu verstehen, nicht als echter Sicherheitsschutz.
- Für echten Mehrbenutzer-Betrieb (gemeinsame Daten, echte Einladungs-Mails) wäre der
  nächste Schritt ein Backend, z. B. Firebase oder Supabase.

# GoalsFORGold – Backend einrichten (Supabase)

Dauer: ca. 10 Minuten. Danach teilen sich Coaches und Athlet:innen dieselben Daten
über alle Geräte hinweg, mit echten Konten.

## Was du machst (einmalig)

1. **Konto & Projekt erstellen:** https://supabase.com → «Start your project» →
   mit GitHub oder E-Mail anmelden → **New project**:
   - Name: `goalsforgold`
   - Datenbank-Passwort: irgendein sicheres (wird nur für Admin gebraucht, notieren)
   - Region: `Central EU (Frankfurt)`
   - Plan: **Free**
2. **Schema einspielen:** Im Projekt links **SQL Editor** → «New query» →
   den kompletten Inhalt von `supabase/schema.sql` einfügen → **Run**.
   (Es muss «Success. No rows returned» erscheinen.)
3. **E-Mail-Bestätigung ausschalten** (empfohlen für den Start):
   Links **Authentication → Sign In / Providers → Email** →
   «Confirm email» **deaktivieren** → Save.
   (Kann später wieder aktiviert werden, dann verschickt Supabase echte Bestätigungs-Mails.)
4. **Zugangsdaten kopieren:** Links **Project Settings → API**:
   - **Project URL** (z. B. `https://abcdefgh.supabase.co`)
   - **anon public** Key (langer String, beginnt mit `eyJ…`)

## Was Claude danach macht

Die beiden Werte in `index.html` beim Block `const BACKEND = {…}` eintragen
und deployen. Ab dann:

- **Login** läuft über echte Supabase-Konten (die lokalen Demo-Passwörter gelten nicht mehr).
- **Coach-Rechte** bekommen automatisch alle E-Mail-Adressen aus der Tabelle
  `coach_emails` (aktuell bjoern.bruhin@swiss-ski.ch und silvano.stadler@swiss-ski.ch) –
  einfach einmal mit dieser E-Mail registrieren.
- **Athlet:innen**: Der Coach legt sie mit E-Mail an; die Athletin registriert sich
  mit derselben E-Mail und ist automatisch mit ihrem Datensatz verknüpft –
  egal auf welchem Gerät.
- **Erst-Migration:** Beim ersten Coach-Login lädt die App das lokale Team
  (inkl. Anna Flatscher und Konfiguration) automatisch in die Cloud hoch.

## Sicherheit

- Der `anon`-Key darf öffentlich sein – der Zugriffsschutz passiert in der
  Datenbank über Row Level Security (Coaches sehen alles, Athlet:innen nur sich selbst).
- Den **service_role**-Key niemals in die App oder das Repo geben.

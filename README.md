# wg-putz-bot 🧽

Minimalistischer Telegram-Bot zur Organisation eines wöchentlichen WG-Putzplans.

Kein Gamification-System.
Keine Punktelogik.
Nur transparente Verantwortlichkeit + Erinnerung.

---

## Idee

Jede Woche übernimmt eine Person das Putzen.

Der Bot:

- fragt montags automatisch nach einer freiwilligen Person
- speichert, wer übernimmt
- erinnert sonntags mit @Mention an die Verantwortung und bittet um Bestätigung
- ermöglicht einfache Statistik-Abfragen

Ziel: Soziale Transparenz statt Excel-Tabelle.

---

## Funktionsweise

### Montag – 09:00

Bot postet:

> Neue Woche, neues Glück.
> Wer übernimmt diese Woche?

Mit einem Inline-Button:

- 🧽 Ich übernehme

Speichert die Person für diese Kalenderwoche — nur eine Person kann übernehmen.

---

### Sonntag – 18:00

Falls jemand eingetragen ist:

> @username — hast du diese Woche wirklich geputzt? 👀

Mit zwei Inline-Buttons:

- ✅ Ja, erledigt — loggt das Cleaning für die Statistik
- ❌ 😬 Ups, vergessen — nur eine konversationelle Antwort

Nur die zugewiesene Person kann die Bestätigung abgeben.

---

## Commands

In der Telegram-Gruppe:

```
/putzplan
```
Aktiviert den Bot für diese Gruppe.

```
/stats
```
Zeigt, wer wie oft übernommen hat.

```
/update
```
Aktualisiert den Bot per Remote-Update.

```
/hä
```
Zeigt alle verfügbaren Befehle an.

---

## Technische Architektur

```
bot.rb          → Einstiegspunkt
scheduler.rb    → Zeitgesteuerte Logik (Montag / Sonntag)
commands.rb     → Slash-Commands
callbacks.rb    → Button-Handling
db.rb           → SQLite + Tabellen
helpers.rb      → week_key, upsert_user, mention
```

---

## Persistenz

SQLite via Sequel.

Tabellen:

- users — Telegram-id → Name/Username, wird bei jeder Interaktion aktualisiert
- cleanings — Log aller bestätigten Putzen
- weekly_assignments — Wer übernimmt für eine gegebene Woche
- bot_meta — Chat-Registrierung + Scheduler-Dedup-State

Wochen werden über `cwyear + cweek` identifiziert.

---

## Setup

### Schnellinstallation (Raspberry Pi)

```bash
git clone https://github.com/froilainhaeckse/wg-putz-bot.git
cd wg-putz-bot
echo 'TELEGRAM_BOT_TOKEN=DEIN_TOKEN' > .env
./install.sh
```

Das Skript installiert alle Abhängigkeiten, richtet einen systemd-Service ein und startet den Bot automatisch — auch nach einem Reboot.

### Manuelle Installation

#### 1. Repository klonen

```bash
git clone https://github.com/froilainhaeckse/wg-putz-bot.git
cd wg-putz-bot
```

#### 2. Dependencies installieren

```bash
bundle install
```

Falls nötig (Raspberry Pi):

```bash
sudo apt install ruby ruby-dev build-essential libsqlite3-dev
```

#### 3. Token setzen

`.env` erstellen:

```
TELEGRAM_BOT_TOKEN=DEIN_TOKEN
```

#### 4. Starten

```bash
bundle exec ruby bot.rb
```

Bot läuft als Long-Polling-Prozess.

---

## Bot verwalten

Nach der Installation mit `install.sh` läuft der Bot als systemd-Service. Zur Steuerung:

```bash
./bot-ctl.sh start      # Bot starten
./bot-ctl.sh stop       # Bot stoppen
./bot-ctl.sh restart    # Neustart (z.B. nach git pull)
./bot-ctl.sh status     # Aktueller Zustand
./bot-ctl.sh logs       # Live-Logs verfolgen
```

### Deinstallation

```bash
./uninstall.sh
```

Stoppt den Service und entfernt ihn aus systemd. Projektdateien und Datenbank bleiben erhalten.

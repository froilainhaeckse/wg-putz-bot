# wg-putz-bot 🧽

Minimalistischer Telegram-Bot zur Organisation eines wöchentlichen WG-Putzplans.

---

## Idee

Jede Woche übernimmt eine Person das Putzen.

Der Bot:

- fragt montags automatisch nach einer freiwilligen Person
- speichert, wer übernimmt
- erinnert sonntags mit @Mention an die Verantwortung
- ermöglicht einfache Statistik-Abfragen

Ziel: Soziale Transparenz statt Excel-Tabelle.

---

## Funktionsweise

### Montag – 09:00

Bot postet:

> Neue Woche, neues Glück.  
> Wer übernimmt diese Woche?

Mit Inline-Button:

🧽 Ich übernehme

Beim Klick:

- Person wird gespeichert
- Woche wird markiert
- Bestätigung wird gepostet

---

### Sonntag – 18:00

Falls jemand eingetragen ist:

> @username — hast du diese Woche wirklich geputzt? 👀

- Nur einmal pro Woche  
- Kein Spam  

---

## Commands

In der Telegram-Gruppe:

```
/putzplan
```
Initialisiert den Bot für diese Gruppe.

```
/stats
```
Zeigt, wer wie oft übernommen hat.

```
/fairness
```
Berechnet Differenz zwischen Maximum und Minimum an Übernahmen.

---

## Technische Architektur

```
bot.rb          → Einstiegspunkt
scheduler.rb    → Zeitgesteuerte Logik (Montag / Sonntag)
commands.rb     → Slash-Commands
callbacks.rb    → Button-Handling
db.rb           → SQLite + Tabellen
helpers.rb      → week_key etc.
```

---

## Persistenz

SQLite via Sequel.

Tabellen:

- cleanings
- weekly_assignments
- bot_meta

Wochen werden über `cwyear + cweek` identifiziert.

---

## Setup

### 1. Repository klonen

```
git clone https://github.com/froilainhaeckse/wg-putz-bot.git
cd wg-putz-bot
```

### 2. Dependencies installieren

```
bundle install
```

Falls nötig (Raspberry Pi):

```
sudo apt install ruby-full build-essential libsqlite3-dev
```

### 3. Token setzen

`.env` erstellen:

```
TELEGRAM_BOT_TOKEN=DEIN_TOKEN
```

oder als Environment Variable exportieren.

### 4. Starten

```
ruby bot.rb
```

Bot läuft als Long-Polling-Prozess.

---

## Laufzeitverhalten

- Scheduler-Thread prüft jede Minute die Zeitbedingungen
- Posts werden über `bot_meta` gegen Mehrfachausführung geschützt
- Telegram @Mention wird genutzt, falls `username` existiert
- Falls kein Username vorhanden ist, wird der Vorname verwendet

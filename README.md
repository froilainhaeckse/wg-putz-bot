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
- erlaubt optional „nicht da“ zu markieren
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

Mit zwei Inline-Buttons:

- 🧽 Ich übernehme  
- 🚫 Diese Woche nicht da  

**Ich übernehme**
- speichert die Person für diese Kalenderwoche
- nur eine Person kann übernehmen

**Diese Woche nicht da**
- markiert die Person für diese Woche als abwesend
- abwesende Personen können nicht übernehmen

Widersprüchliche Zustände werden verhindert  
(z. B. erst übernehmen, dann abwesend klicken).

---

### Sonntag – 18:00

Falls jemand eingetragen ist:

> @username — hast du diese Woche wirklich geputzt? 👀

- Nur einmal pro Woche  
- Kein Spam  
- @Mention falls Username vorhanden  

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
- absences
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

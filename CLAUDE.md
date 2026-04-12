# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A German-language Telegram bot for organizing a weekly WG (shared apartment) cleaning schedule. One person volunteers each week; the bot posts a prompt on Mondays, tracks who takes the task, and sends a reminder on Sundays. No gamification — just transparent accountability.

## Running the Bot

```bash
bundle install          # install dependencies
ruby bot.rb             # start (long-polling, runs forever)
```

Requires `TELEGRAM_BOT_TOKEN` set via `.env` file or environment variable.

There is no test suite and no linter configured.

## Architecture

`bot.rb` is the entry point. It starts the Telegram long-polling loop and dispatches updates:
- `Telegram::Bot::Types::Message` -> `handle_message()` in `commands.rb`
- `Telegram::Bot::Types::CallbackQuery` -> `handle_callback()` in `callbacks.rb`

**Scheduler** (`scheduler.rb`): A background `Thread` that wakes every 60 seconds and checks the current day/hour to fire two scheduled actions:
- `post_weekly_putzplan` — Monday 09:00, posts the weekly volunteer prompt with inline buttons
- `sunday_check` — Sunday 18:00, @mentions the assigned person as a reminder

Both use `bot_meta` keys (`last_week_posted_<chat_id>`, `last_sunday_check_<chat_id>`) as dedup guards so each action fires only once per week per chat.

**Database** (`db.rb`): SQLite via Sequel, file `putzplan.db`. Tables are auto-created on startup. Four tables:
- `cleanings` — historical log of who cleaned (used for `/stats`)
- `weekly_assignments` — who is assigned for a given week (keyed by `week_key`)
- `absences` — who marked themselves absent for a given week
- `bot_meta` — key/value store for chat registration and scheduler dedup state

**Week identification**: All weekly data uses `"#{cwyear}-#{cweek}"` format (ISO week numbering) via `week_key()` in `helpers.rb`.

## Callback Logic (Important Invariants)

`callbacks.rb` handles two inline button callbacks (`take_task`, `mark_absent`) with mutual exclusion:
- A user who already has a `weekly_assignment` cannot mark themselves absent
- A user who is already absent cannot take the task
- Only one person can be assigned per chat per week

## Bot Commands

- `/putzplan` — registers the chat and posts the volunteer prompt (only "take task" button, no absence button)
- `/stats` — shows per-user cleaning counts
- `/fairness` — mentioned in README but not yet implemented in `commands.rb`

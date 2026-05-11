# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A German-language Telegram bot for organizing a weekly WG (shared apartment) cleaning schedule. One person volunteers each week; the bot posts a prompt on Mondays, tracks who takes the task, and sends a Sunday check-in. No gamification — just transparent accountability.

## Running the Bot

```bash
bundle install          # install dependencies
bundle exec ruby bot.rb # start (long-polling, runs forever)
bundle exec rspec       # run the test suite
```

Requires `TELEGRAM_BOT_TOKEN` set via `.env` file or environment variable.

## Architecture

`bot.rb` is the entry point. It starts the Telegram long-polling loop and dispatches updates:
- `Telegram::Bot::Types::Message` -> `handle_message()` in `commands.rb`
- `Telegram::Bot::Types::CallbackQuery` -> `handle_callback()` in `callbacks.rb`

Both entry points call `upsert_user()` (in `helpers.rb`) before doing anything else, so the `users` table is always up-to-date with the caller's current Telegram name and handle.

**Scheduler** (`scheduler.rb`): A background `Thread` that wakes every 60 seconds and checks the current day/hour to fire two scheduled actions:
- `post_weekly_putzplan` — Monday 09:00, posts the weekly volunteer prompt with a "🧽 Ich übernehme" button
- `sunday_check` — Sunday 18:00, @mentions the assigned person and asks them to confirm via inline buttons

Both use `bot_meta` keys (`last_week_posted_<chat_id>`, `last_sunday_check_<chat_id>`) as dedup guards so each action fires only once per week per chat.

**Database** (`db.rb`): SQLite via Sequel, file `putzplan.db`. Tables are auto-created on startup. Four tables:
- `users` — Telegram id -> first_name / username map, updated on every interaction
- `cleanings` — historical log of confirmed cleanings (used for `/stats`)
- `weekly_assignments` — who took the task for a given week (keyed by `week_key`)
- `bot_meta` — key/value store for chat registration and scheduler dedup state

`cleanings` and `weekly_assignments` store only `user_id`; the current display name is always resolved via the `users` table. This means a user renaming themselves on Telegram is reflected everywhere automatically.

**Week identification**: All weekly data uses `"#{cwyear}-#{cweek}"` format (ISO week numbering) via `week_key()` in `helpers.rb`.

## Callback Logic (Important Invariants)

`callbacks.rb` handles three inline button callbacks:
- `take_task` (Monday prompt) — only one person can be assigned per chat per week
- `confirm_cleaned` (Sunday check-in) — only the assigned user can confirm; only logs once per week
- `confirm_forgot` (Sunday check-in) — purely conversational, no DB write

## Bot Commands

- `/putzplan` — registers the chat for weekly Monday prompts
- `/stats` — shows per-user cleaning counts, grouped by `user_id` with names from `users`
- `/update` — pulls latest code from origin/main, runs `bundle install`, exits so systemd restarts the bot
- `/hä` — help text

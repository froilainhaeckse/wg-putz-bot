def start_scheduler(bot)
  Thread.new do
    loop do
      sleep 60

      BOT_META.where(key: "chat_id").each do |entry|
        chat_id = entry[:value].to_i
        post_weekly_putzplan(bot, chat_id)
        sunday_check(bot, chat_id)
      end
    end
  end
end

def post_weekly_putzplan(bot, chat_id)
  today = Date.today
  return unless today.wday == 1 && Time.now.hour == 9

  current_week = week_key(today)

  last_entry = BOT_META.where(key: "last_week_posted_#{chat_id}").first
  return if last_entry && last_entry[:value] == current_week

  keyboard = [
    [Telegram::Bot::Types::InlineKeyboardButton.new(text: "🧽 Ich übernehme", callback_data: "take_task")]
  ]

  markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: keyboard)

  bot.api.send_message(
    chat_id: chat_id,
    text: "🧽 Neue Woche, neues Glück.\nWer übernimmt diese Woche?",
    reply_markup: markup
  )

  if last_entry
    BOT_META.where(key: "last_week_posted_#{chat_id}").update(value: current_week)
  else
    BOT_META.insert(key: "last_week_posted_#{chat_id}", value: current_week)
  end
end

def sunday_check(bot, chat_id)
  today = Date.today
  now = Time.now

  return unless today.wday == 0 &&
                now.hour == 18 &&
                now.min == 0

  current_week = week_key(today)

  meta_key = "last_sunday_check_#{chat_id}"
  last_entry = BOT_META.where(key: meta_key).first
  return if last_entry && last_entry[:value] == current_week

  assignment = WEEKLY_ASSIGNMENTS.where(chat_id: chat_id, week_key: current_week).first
  return unless assignment

  keyboard = [
    [Telegram::Bot::Types::InlineKeyboardButton.new(text: "✅ Ja, erledigt",        callback_data: "confirm_cleaned")],
    [Telegram::Bot::Types::InlineKeyboardButton.new(text: "❌ 😬 Ups, vergessen",   callback_data: "confirm_forgot")]
  ]

  markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: keyboard)

  bot.api.send_message(
    chat_id: chat_id,
    text: "🧽 Wochen-Check!\n\n#{mention(assignment[:user_first_name], assignment[:user_id])} — hast du diese Woche wirklich geputzt? 👀",
    parse_mode: "Markdown",
    reply_markup: markup
  )

  if last_entry
    BOT_META.where(key: meta_key).update(value: current_week)
  else
    BOT_META.insert(key: meta_key, value: current_week)
  end
end

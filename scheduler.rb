def start_scheduler(bot)
  Thread.new do
    loop do
      sleep 60

      chat_entry = BOT_META.where(key: "chat_id").first
      next unless chat_entry

      chat_id = chat_entry[:value].to_i

      post_weekly_putzplan(bot, chat_id)
      sunday_check(bot, chat_id)
    end
  end
end

def post_weekly_putzplan(bot, chat_id)
  today = Date.today
  return unless today.wday == 1 && Time.now.hour == 9

  current_week = week_key(today)

  last_week_entry = BOT_META.where(key: "last_week_posted_#{chat_id}").first
  return if last_week_entry && last_week_entry[:value] == current_week

  keyboard = [
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(
        text: "🧽 Ich übernehme",
        callback_data: "take_task"
      )
    ],
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(
        text: "🚫 Diese Woche nicht da",
        callback_data: "mark_absent"
      )
    ]
  ]

  markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(
    inline_keyboard: keyboard
  )

  bot.api.send_message(
    chat_id: chat_id,
    text: "🧽 Neue Woche, neues Glück.\nWer übernimmt diese Woche?",
    reply_markup: markup
  )

  if last_week_entry
    BOT_META.where(key: "last_week_posted_#{chat_id}").update(value: current_week)
  else
    BOT_META.insert(key: "last_week_posted_#{chat_id}", value: current_week)
  end
end

def sunday_check(bot, chat_id)
  today = Date.today
  return unless today.wday == 0 && Time.now.hour == 18

  current_week = week_key(today)

  meta_key = "last_sunday_check_#{chat_id}"
  last_entry = BOT_META.where(key: meta_key).first
  return if last_entry && last_entry[:value] == current_week

  assignment = WEEKLY_ASSIGNMENTS.where(
    chat_id: chat_id,
    week_key: current_week
  ).first

  return unless assignment

  mention =
    if assignment[:username_mention] && !assignment[:username_mention].empty?
      "@#{assignment[:username_mention]}"
    else
      assignment[:user_first_name]
    end

  bot.api.send_message(
    chat_id: chat_id,
    text: "🧽 Wochen-Check!\n\n#{mention} — hast du diese Woche wirklich geputzt? 👀"
  )

  if last_entry
    BOT_META.where(key: meta_key).update(value: current_week)
  else
    BOT_META.insert(key: meta_key, value: current_week)
  end
end

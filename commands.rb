def handle_message(bot, message)
  case message.text

  when "/putzplan"
    unless BOT_META.where(key: "chat_id").first
      BOT_META.insert(key: "chat_id", value: message.chat.id.to_s)
    end

    keyboard = [
      [Telegram::Bot::Types::InlineKeyboardButton.new(
        text: "🧽 Ich übernehme",
        callback_data: "take_task"
      )]
    ]

    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(
      inline_keyboard: keyboard
    )

    bot.api.send_message(
      chat_id: message.chat.id,
      text: "Wer putzt diese Woche?",
      reply_markup: markup
    )

  when "/stats"
    stats = CLEANINGS
              .where(chat_id: message.chat.id)
              .select_group(:user_id, :user_first_name)
              .select_append { count(id).as(count) }
              .all

    if stats.empty?
      bot.api.send_message(chat_id: message.chat.id, text: "Noch keine Putzdaten vorhanden.")
      return
    end

    text = "🧽 Cleaning Stats\n\n"
    stats.each do |entry|
      text += "#{mention(entry[:user_first_name], entry[:user_id])}: #{entry[:count]}x\n"
    end

    bot.api.send_message(chat_id: message.chat.id, text: text, parse_mode: "Markdown")
  end
end

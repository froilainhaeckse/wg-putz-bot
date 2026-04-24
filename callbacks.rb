def handle_callback(bot, query)
  chat_id = query.message.chat.id
  user_id = query.from.id
  user_name = query.from.first_name

  case query.data

  when "take_task"
    current_week = week_key(Date.today)
    if WEEKLY_ASSIGNMENTS.where(chat_id: chat_id, week_key: current_week).first
      bot.api.answer_callback_query(
        callback_query_id: query.id,
        text: "Diese Woche hat bereits jemand übernommen.",
        show_alert: true
      )
      return
    end

    WEEKLY_ASSIGNMENTS.insert(
      user_id: user_id,
      user_first_name: user_name,
      username_mention: query.from.username,
      chat_id: chat_id,
      week_key: current_week,
      created_at: Time.now
    )

    bot.api.send_message(
      chat_id: chat_id,
      text: "✅ #{mention(user_name, user_id)} übernimmt diese Woche das Putzen!",
      parse_mode: "Markdown"
    )
    bot.api.answer_callback_query(callback_query_id: query.id)

  when "confirm_cleaned"
    current_week = week_key(Date.today)
    meta_key = "last_cleaning_logged_#{chat_id}"
    last_entry = BOT_META.where(key: meta_key).first

    if last_entry && last_entry[:value] == current_week
      bot.api.answer_callback_query(callback_query_id: query.id, text: "Diese Woche wurde bereits geputzt!")
      return
    end

    CLEANINGS.insert(
      user_first_name: user_name,
      user_id: user_id,
      chat_id: chat_id,
      created_at: Time.now
    )

    if last_entry
      BOT_META.where(key: meta_key).update(value: current_week)
    else
      BOT_META.insert(key: meta_key, value: current_week)
    end

    bot.api.send_message(chat_id: chat_id, text: "✅ Stabil. Danke fürs Putzen, #{user_name}!")
    bot.api.answer_callback_query(callback_query_id: query.id)

  when "confirm_forgot"
    bot.api.send_message(chat_id: chat_id, text: "😬 Ehrlich immerhin. Vielleicht noch schnell erledigen?")
    bot.api.answer_callback_query(callback_query_id: query.id)

  end
end

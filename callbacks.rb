def handle_callback(bot, query)
  return unless query.data == "take_task"

  user = query.from.first_name
  today = Date.today
  current_week = week_key(today)

  CLEANINGS.insert(
    user_first_name: user,
    user_id: query.from.id,
    chat_id: query.message.chat.id,
    created_at: Time.now
  )

  existing = WEEKLY_ASSIGNMENTS.where(
    chat_id: query.message.chat.id,
    week_key: current_week
  ).first

  unless existing
    WEEKLY_ASSIGNMENTS.insert(
      user_id: query.from.id,
      user_first_name: query.from.first_name,
      username_mention: query.from.username,
      chat_id: query.message.chat.id,
      week_key: current_week,
      created_at: Time.now
    )
  end

  bot.api.send_message(
    chat_id: query.message.chat.id,
    text: "✅ #{user} übernimmt diese Woche das Putzen!"
  )

  bot.api.answer_callback_query(callback_query_id: query.id)
end

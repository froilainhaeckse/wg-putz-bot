def handle_callback(bot, query)
  today = Date.today
  current_week = week_key(today)
  chat_id = query.message.chat.id
  user_id = query.from.id
  user_name = query.from.first_name

  case query.data

  when "mark_absent"
    assignment = WEEKLY_ASSIGNMENTS.where(
      user_id: user_id,
      chat_id: chat_id,
      week_key: current_week
    ).first

    if assignment
      bot.api.answer_callback_query(
        callback_query_id: query.id,
        text: "Du hast diese Woche bereits übernommen.",
        show_alert: true
      )
      return
    end
    existing = ABSENCES.where(
      user_id: user_id,
      chat_id: chat_id,
      week_key: current_week
    ).first

    if existing
      bot.api.answer_callback_query(
        callback_query_id: query.id,
        text: "Du bist bereits als abwesend markiert."
      )
      return
    end

    ABSENCES.insert(
      user_id: user_id,
      chat_id: chat_id,
      week_key: current_week,
      created_at: Time.now
    )

    bot.api.send_message(
      chat_id: chat_id,
      text: "🚫 #{mention(user_name, user_id)} ist diese Woche nicht da.",
      parse_mode: "Markdown"
    )

    bot.api.answer_callback_query(callback_query_id: query.id)


  when "take_task"

    # 1️⃣ prüfen ob abwesend
    absence = ABSENCES.where(
      user_id: user_id,
      chat_id: chat_id,
      week_key: current_week
    ).first

    if absence
      bot.api.answer_callback_query(
        callback_query_id: query.id,
        text: "Du bist diese Woche als abwesend markiert.",
        show_alert: true
      )
      return
    end

    existing_assignment = WEEKLY_ASSIGNMENTS.where(
      chat_id: chat_id,
      week_key: current_week
    ).first

    if existing_assignment
      bot.api.answer_callback_query(
        callback_query_id: query.id,
        text: "Diese Woche hat bereits jemand übernommen.",
        show_alert: true
      )
      return
    end

    # 2️⃣ Cleaning speichern
    CLEANINGS.insert(
      user_first_name: user_name,
      user_id: user_id,
      chat_id: chat_id,
      created_at: Time.now
    )

    # 3️⃣ Weekly Assignment speichern (nur wenn noch keiner)
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

  end
end

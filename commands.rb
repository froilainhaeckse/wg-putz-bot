def handle_message(bot, message)
  case message.text

  when "/putzplan"
    if BOT_META.where(key: "chat_id", value: message.chat.id.to_s).first
      bot.api.send_message(chat_id: message.chat.id, text: "Bot ist bereits aktiviert! Jeden Montag um 09:00 wird nach Freiwilligen gefragt.")
    else
      BOT_META.insert(key: "chat_id", value: message.chat.id.to_s)
      bot.api.send_message(chat_id: message.chat.id, text: "Heyhey bin da :) Ab jetzt werde ich jeden Montag fragen, wer bock hat zu putzen.")
    end

  when "/update"
    bot.api.send_message(chat_id: message.chat.id, text: "⏳ Update wird ausgeführt...")

    output = `bash #{__dir__}/update.sh 2>&1`
    success = $?.success?

    if success
      bot.api.send_message(chat_id: message.chat.id, text: "✅ Update erfolgreich. Starte neu...")
      exit(0)
    else
      bot.api.send_message(chat_id: message.chat.id, text: "❌ Update fehlgeschlagen:\n#{output}")
    end

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

  when "/hä"
    help = "🧹 Befehle:\n\n" \
           "/putzplan — Bot für diese Gruppe aktivieren\n" \
           "/stats — Wer hat wie oft geputzt?\n" \
           "/update — Bot aktualisieren (Remote-Update)\n" \
           "/hä — Diese Hilfe anzeigen"

    bot.api.send_message(chat_id: message.chat.id, text: help)
  end
end

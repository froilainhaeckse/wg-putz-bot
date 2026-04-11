require "telegram/bot"
require "dotenv/load"

require_relative "db"
require_relative "helpers"
require_relative "scheduler"
require_relative "commands"
require_relative "callbacks"

TOKEN = ENV["TELEGRAM_BOT_TOKEN"]

Telegram::Bot::Client.run(TOKEN) do |bot|
  start_scheduler(bot)

  bot.listen do |update|
    case update
    when Telegram::Bot::Types::Message
      handle_message(bot, update)
    when Telegram::Bot::Types::CallbackQuery
      handle_callback(bot, update)
    end
  end
end

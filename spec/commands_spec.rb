require_relative "../helpers"
require_relative "../commands"

RSpec.describe "#handle_message" do
  include_context "with test db"

  let(:chat_id) { 2001 }
  let(:bot_api) { double("bot_api", send_message: nil) }
  let(:bot)     { double("bot", api: bot_api) }

  def make_message(text)
    double("message", text: text, chat: double("chat", id: chat_id))
  end

  context "/putzplan" do
    it "registers a new chat and sends a welcome message" do
      handle_message(bot, make_message("/putzplan"))
      expect(BOT_META.where(key: "chat_id", value: chat_id.to_s).first).not_to be_nil
      expect(bot_api).to have_received(:send_message)
        .with(hash_including(text: /Montag/))
    end

    it "sends an already-active message for a registered chat" do
      BOT_META.insert(key: "chat_id", value: chat_id.to_s)
      handle_message(bot, make_message("/putzplan"))
      expect(BOT_META.where(key: "chat_id", value: chat_id.to_s).count).to eq(1)
      expect(bot_api).to have_received(:send_message)
        .with(hash_including(text: /bereits aktiviert/))
    end
  end

  context "/stats" do
    it "reports no data when there are no cleanings" do
      handle_message(bot, make_message("/stats"))
      expect(bot_api).to have_received(:send_message)
        .with(hash_including(text: /Noch keine Putzdaten/))
    end

    it "lists cleaning counts per user" do
      2.times { CLEANINGS.insert(user_id: 1001, user_first_name: "Alice", chat_id: chat_id, created_at: Time.now) }
      CLEANINGS.insert(user_id: 1002, user_first_name: "Bob", chat_id: chat_id, created_at: Time.now)
      handle_message(bot, make_message("/stats"))
      expect(bot_api).to have_received(:send_message) do |args|
        expect(args[:text]).to include("Alice")
        expect(args[:text]).to include("Bob")
      end
    end

    it "only shows stats for the current chat" do
      CLEANINGS.insert(user_id: 1001, user_first_name: "Alice", chat_id: 9999, created_at: Time.now)
      handle_message(bot, make_message("/stats"))
      expect(bot_api).to have_received(:send_message)
        .with(hash_including(text: /Noch keine Putzdaten/))
    end
  end

  context "/hä" do
    it "sends help text listing the available commands" do
      handle_message(bot, make_message("/hä"))
      expect(bot_api).to have_received(:send_message)
        .with(hash_including(text: /Befehle/))
    end
  end
end

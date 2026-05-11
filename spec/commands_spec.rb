require_relative "../helpers"
require_relative "../commands"

RSpec.describe "#handle_message" do
  include_context "with test db"

  let(:chat_id) { 2001 }
  let(:bot_api) { double("bot_api", send_message: nil) }
  let(:bot)     { double("bot", api: bot_api) }
  let(:from)    { double("from", id: 1001, first_name: "Alice", username: "alice") }

  def make_message(text, sender: from)
    double("message", text: text, from: sender, chat: double("chat", id: chat_id))
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

    it "upserts the sender into the users table" do
      handle_message(bot, make_message("/putzplan"))
      expect(USERS.where(user_id: 1001).first[:first_name]).to eq("Alice")
    end
  end

  context "/stats" do
    it "reports no data when there are no cleanings" do
      handle_message(bot, make_message("/stats"))
      expect(bot_api).to have_received(:send_message)
        .with(hash_including(text: /Noch keine Putzdaten/))
    end

    it "lists cleaning counts per user with current names from users table" do
      USERS.insert(user_id: 1001, first_name: "Alice", updated_at: Time.now)
      USERS.insert(user_id: 1002, first_name: "Bob",   updated_at: Time.now)
      2.times { CLEANINGS.insert(user_id: 1001, chat_id: chat_id, created_at: Time.now) }
      CLEANINGS.insert(user_id: 1002, chat_id: chat_id, created_at: Time.now)
      handle_message(bot, make_message("/stats"))
      expect(bot_api).to have_received(:send_message) do |args|
        expect(args[:text]).to include("Alice")
        expect(args[:text]).to include("Bob")
        expect(args[:text]).to match(/Alice.*2x/)
        expect(args[:text]).to match(/Bob.*1x/)
      end
    end

    it "reflects renamed users without duplicating rows" do
      USERS.insert(user_id: 1001, first_name: "AliceNeu", updated_at: Time.now)
      3.times { CLEANINGS.insert(user_id: 1001, chat_id: chat_id, created_at: Time.now) }
      caller = double("from", id: 9999, first_name: "Caller", username: nil)
      handle_message(bot, make_message("/stats", sender: caller))
      expect(bot_api).to have_received(:send_message) do |args|
        expect(args[:text]).to include("AliceNeu")
        expect(args[:text].scan(/\d+x/).size).to eq(1)
      end
    end

    it "only shows stats for the current chat" do
      USERS.insert(user_id: 1001, first_name: "Alice", updated_at: Time.now)
      CLEANINGS.insert(user_id: 1001, chat_id: 9999, created_at: Time.now)
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

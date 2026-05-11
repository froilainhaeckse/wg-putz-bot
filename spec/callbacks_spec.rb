require "date"
require_relative "../helpers"
require_relative "../callbacks"

RSpec.describe "#handle_callback" do
  include_context "with test db"

  let(:user_id) { 1001 }
  let(:chat_id) { 2001 }
  let(:week)    { "2026-17" }
  let(:bot_api) { double("bot_api", send_message: nil, answer_callback_query: nil) }
  let(:bot)     { double("bot", api: bot_api) }
  let(:from)    { double("from", id: user_id, first_name: "Alice", username: "alice") }
  let(:message) { double("message", chat: double("chat", id: chat_id)) }

  before { allow(Date).to receive(:today).and_return(Date.new(2026, 4, 20)) }

  def make_query(data)
    double("query", id: "qid", data: data, from: from, message: message)
  end

  context "take_task" do
    it "saves the assignment and announces it" do
      handle_callback(bot, make_query("take_task"))
      expect(WEEKLY_ASSIGNMENTS.first[:user_id]).to eq(user_id)
      expect(CLEANINGS).to be_empty
      expect(bot_api).to have_received(:send_message)
        .with(hash_including(text: /übernimmt/))
    end

    it "rejects when someone is already assigned this week" do
      WEEKLY_ASSIGNMENTS.insert(user_id: 9999, user_first_name: "Bob", chat_id: chat_id, week_key: week, created_at: Time.now)
      handle_callback(bot, make_query("take_task"))
      expect(WEEKLY_ASSIGNMENTS.count).to eq(1)
      expect(bot_api).to have_received(:answer_callback_query)
        .with(hash_including(show_alert: true))
    end
  end

  context "confirm_cleaned" do
    it "logs the cleaning and sends a thank-you" do
      handle_callback(bot, make_query("confirm_cleaned"))
      expect(CLEANINGS.first[:user_id]).to eq(user_id)
      expect(bot_api).to have_received(:send_message)
        .with(hash_including(text: /Danke fürs Putzen/))
    end

    it "can only be logged once per week" do
      handle_callback(bot, make_query("confirm_cleaned"))
      handle_callback(bot, make_query("confirm_cleaned"))
      expect(CLEANINGS.count).to eq(1)
    end
  end

  context "confirm_forgot" do
    it "does not log anything and sends a nudge" do
      handle_callback(bot, make_query("confirm_forgot"))
      expect(CLEANINGS).to be_empty
      expect(bot_api).to have_received(:send_message)
        .with(hash_including(text: /Ehrlich/))
    end
  end
end

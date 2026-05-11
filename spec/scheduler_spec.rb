require "telegram/bot"
require "date"
require_relative "../helpers"
require_relative "../scheduler"

RSpec.describe "#post_weekly_putzplan" do
  include_context "with test db"

  let(:chat_id) { 2001 }
  let(:week)    { "2026-17" }
  let(:bot_api) { double("bot_api", send_message: nil) }
  let(:bot)     { double("bot", api: bot_api) }

  before do
    allow(Date).to receive(:today).and_return(Date.new(2026, 4, 20))
    allow(Time).to receive(:now).and_return(Time.new(2026, 4, 20, 9, 0, 0))
  end

  it "posts the volunteer prompt on Monday at 9am" do
    post_weekly_putzplan(bot, chat_id)
    expect(bot_api).to have_received(:send_message)
      .with(hash_including(chat_id: chat_id, text: /Neue Woche/))
  end

  it "does not post again when already posted this week" do
    BOT_META.insert(key: "last_week_posted_#{chat_id}", value: week)
    post_weekly_putzplan(bot, chat_id)
    expect(bot_api).not_to have_received(:send_message)
  end

  it "does not post on a non-Monday" do
    allow(Date).to receive(:today).and_return(Date.new(2026, 4, 21))
    post_weekly_putzplan(bot, chat_id)
    expect(bot_api).not_to have_received(:send_message)
  end
end

RSpec.describe "#sunday_check" do
  include_context "with test db"

  let(:chat_id) { 2001 }
  let(:week)    { "2026-17" }
  let(:bot_api) { double("bot_api", send_message: nil) }
  let(:bot)     { double("bot", api: bot_api) }
  let(:sunday)  { Date.new(2026, 4, 26) }
  let(:six_pm)  { Time.new(2026, 4, 26, 18, 0, 0) }

  before do
    allow(Date).to receive(:today).and_return(sunday)
    allow(Time).to receive(:now).and_return(six_pm)
  end

  def insert_assignment
    WEEKLY_ASSIGNMENTS.insert(user_id: 1001, user_first_name: "Alice", chat_id: chat_id, week_key: week, created_at: six_pm)
  end

  it "mentions the assigned person in the check-in message" do
    insert_assignment
    sunday_check(bot, chat_id)
    expect(bot_api).to have_received(:send_message)
      .with(hash_including(text: /Alice/))
  end

  it "does not post when no one is assigned this week" do
    sunday_check(bot, chat_id)
    expect(bot_api).not_to have_received(:send_message)
  end

  it "does not post again when already checked this week" do
    insert_assignment
    BOT_META.insert(key: "last_sunday_check_#{chat_id}", value: week)
    sunday_check(bot, chat_id)
    expect(bot_api).not_to have_received(:send_message)
  end

  it "saves the dedup key after posting" do
    insert_assignment
    sunday_check(bot, chat_id)
    meta = BOT_META.where(key: "last_sunday_check_#{chat_id}").first
    expect(meta[:value]).to eq(week)
  end
end

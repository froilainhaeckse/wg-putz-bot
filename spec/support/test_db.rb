require "sequel"

TEST_DB = Sequel.sqlite

TEST_DB.create_table(:cleanings) do
  primary_key :id
  String :user_first_name
  Integer :user_id
  Integer :chat_id
  DateTime :created_at
end

TEST_DB.create_table(:weekly_assignments) do
  primary_key :id
  Integer :user_id
  String :user_first_name
  Integer :chat_id
  String :week_key
  DateTime :created_at
  String :username_mention
end

TEST_DB.create_table(:bot_meta) do
  primary_key :id
  String :key
  String :value
end

RSpec.shared_context "with test db" do
  before do
    stub_const("CLEANINGS",          TEST_DB[:cleanings])
    stub_const("WEEKLY_ASSIGNMENTS", TEST_DB[:weekly_assignments])
    stub_const("BOT_META",           TEST_DB[:bot_meta])

    TEST_DB[:cleanings].delete
    TEST_DB[:weekly_assignments].delete
    TEST_DB[:bot_meta].delete
  end
end

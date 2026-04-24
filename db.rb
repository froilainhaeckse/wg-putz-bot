require "sequel"

DB = Sequel.sqlite("putzplan.db")

DB.create_table? :cleanings do
  primary_key :id
  String :user_first_name
  Integer :user_id
  Integer :chat_id
  DateTime :created_at
end

DB.create_table? :bot_meta do
  primary_key :id
  String :key
  String :value
end

DB.create_table? :weekly_assignments do
  primary_key :id
  Integer :user_id
  String :user_first_name
  Integer :chat_id
  String :week_key
  DateTime :created_at
  String :username_mention
end

CLEANINGS          = DB[:cleanings]
BOT_META           = DB[:bot_meta]
WEEKLY_ASSIGNMENTS = DB[:weekly_assignments]

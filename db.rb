require "sequel"

DB = Sequel.sqlite("putzplan.db")

DB.create_table? :users do
  primary_key :user_id
  String :first_name
  String :username
  DateTime :updated_at
end

DB.create_table? :cleanings do
  primary_key :id
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
  Integer :chat_id
  String :week_key
  DateTime :created_at
end

USERS              = DB[:users]
CLEANINGS          = DB[:cleanings]
BOT_META           = DB[:bot_meta]
WEEKLY_ASSIGNMENTS = DB[:weekly_assignments]

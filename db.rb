require "sequel"

DB = Sequel.sqlite("putzplan.db")

unless DB.table_exists?(:cleanings)
  DB.create_table :cleanings do
    primary_key :id
    String :user_first_name
    Integer :user_id
    Integer :chat_id
    DateTime :created_at
  end
end

CLEANINGS = DB[:cleanings]

DB.create_table? :bot_meta do
  primary_key :id
  String :key
  String :value
end

BOT_META = DB[:bot_meta]


unless DB.table_exists?(:weekly_assignments)
  DB.create_table :weekly_assignments do
    primary_key :id
    Integer :user_id
    String :user_first_name
    Integer :chat_id
    String :week_key
    DateTime :created_at
    String :username_mention
  end
end

WEEKLY_ASSIGNMENTS = DB[:weekly_assignments]

ABSENCES = DB[:absences]

unless DB.table_exists?(:absences)
  DB.create_table :absences do
    primary_key :id
    Integer :user_id
    Integer :chat_id
    String :week_key
    DateTime :created_at
  end
end

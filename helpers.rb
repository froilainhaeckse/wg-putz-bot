require "date"

def week_key(date)
  "#{date.cwyear}-#{date.cweek}"
end

def upsert_user(user_id, first_name, username)
  return unless user_id

  row = { first_name: first_name, username: username, updated_at: Time.now }
  if USERS.where(user_id: user_id).update(row) == 0
    USERS.insert(row.merge(user_id: user_id))
  end
end

def user_name(user_id)
  USERS.where(user_id: user_id).get(:first_name) || "Unbekannt"
end

def mention(user_id)
  "[#{user_name(user_id)}](tg://user?id=#{user_id})"
end

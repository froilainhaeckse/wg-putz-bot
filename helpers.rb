require "date"

def week_key(date)
  "#{date.cwyear}-#{date.cweek}"
end

def mention(name, user_id)
  "[#{name}](tg://user?id=#{user_id})"
end

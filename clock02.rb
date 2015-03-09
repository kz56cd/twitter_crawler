require 'clockwork'
include Clockwork

# 動作
handler do |job|
  case job
    when "kokoro.job"
      puts " - 10 - "
    when "pyon.job"
      puts " - 2 - "
      # puts `ruby -v` # shellによるコマンド呼び出し
    when "local.job"
      puts Time.now
  end
end

#スケジューリング
every(10.seconds, 'kokoro.job', :thread => true)
every(2.seconds, 'pyon.job', :thread => true)

# every(1.day, 'utc.job', :at => '10:38', :tz => 'UTC')
every(1.day, 'local.job', :at => '10:45', :thread => true) # ローカルタイムゾーンで実行
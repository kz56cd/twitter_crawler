# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# ------------------------------------------

# 本プロジェクトまでの絶対パス
# PROJECT_HOME_PATH = "/Users/0FRZ14015/Dropbox/_sample/ruby/pictlink_twitter_crawler_02/"

# env :TNS_ADMIN , "/Users/0FRZ14015/Dropbox/_sample/ruby/clockwork_nest03/"
# env :NLS_LANG , "Japanese_Japan.UTF8"

set :output, Whenever.path + "/file.log"
# set :output, "file.log"

# every 10.minutes do
every 25.minutes do

# every 1.day, :at => '5:15 pm' do
# every 1.day, :at => '10:10pm' do
# every 1.day do


# every '18 22 * * *' do

  # command "echo 'one' && echo 'two'"
  # command "nohup ruby " + PROJECT_HOME_PATH + "test.rb"

  # command "ruby -v"
  # command "ruby " + Whenever.path + "test.rb"
  command "export PATH='$HOME/.rbenv/bin:$PATH'"

  # command "ruby " + Whenever.path + "/crwl_manager.rb stop"
  # command "ruby " + Whenever.path + "/crwl_manager.rb start"
  command "ruby " + Whenever.path + "/crwl_manager.rb check" # リスタートすべきか確認する

  # puts "path : " + Whenever.path
end

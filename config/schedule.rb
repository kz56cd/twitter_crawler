set :output, Whenever.path + "/file.log"

every 25.minutes do
  command "export PATH='$HOME/.rbenv/bin:$PATH'"
  command "ruby " + Whenever.path + "/crwl_manager.rb check" # リスタートすべきか確認する
end



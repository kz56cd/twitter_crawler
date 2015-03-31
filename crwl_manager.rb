CMD_OPTION_START   = "start"
CMD_OPTION_STOP    = "stop"
CMD_OPTION_RESTART = "restart"
CMD_OPTION_LIST    = "list"

# |||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# RUN_FILE_NAME      = "start_crawling.rb"
RUN_FILE_NAME      = "/Users/0FRZ14015/Dropbox/_sample/ruby/pictlink_twitter_crawler/start_crawling.rb"
# |||||||||||||||||||||||||||||||||||||||||||||||||||||||||

#
# 入力されたオプションの評価
#
def checkInput()
  i = ARGV[0]
  case i
  when CMD_OPTION_START then
    doStart()      
  when CMD_OPTION_STOP then
    doStop()
  when CMD_OPTION_RESTART then
    doRestart()
  when CMD_OPTION_LIST then
    doList()
  else
    showErr(i)
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#
# ジョブの起動
#
def doStart()
  puts ">>>> do start <<<<"
  shell = "nohup clockwork " + RUN_FILE_NAME + " \&"
  exec(shell) # 「start_crawling」ジョブの開始
end


#
# ジョブの停止（ = 削除）
#
def doStop()
  puts ">>>> do stop <<<<"
  shell = "pkill -f " + RUN_FILE_NAME
  exec(shell)  # 「start_crawling」ジョブ全て削除
end


#
# ジョブの再起動
#
def doRestart()
  doStop()
  doStart()
end


#
# ジョブのリスト表示
#
def doList()
  puts ">>>> do list <<<<"
  shell = "pgrep -fl " + RUN_FILE_NAME
  exec(shell)
  # puts `pgrep -fl start_crawling`
end


#
# エラー表示
#
def showErr(i)

  err_str = ""
  if i.nil?
    err_str = "ERROR -- didnot input cmd option."
  else
    err_str = "ERROR -- not a cmd option : " + i
  end

  puts("+ + + + + + + + + + + + + + + + + + + + + ")
  puts(err_str + "\n\n")
  puts("You can use these options => ")
  puts(" 1) start       -> start job.")
  puts(" 2) stop        -> stop ALL job.")
  puts(" 3) restart     -> restart job. ")
  puts(" 4) list        -> show jobs.")
  puts("+ + + + + + + + + + + + + + + + + + + + + ")
end


checkInput()
CMD_OPTION_START         = "start"
CMD_OPTION_STOP          = "stop"
CMD_OPTION_RESTART       = "restart"
CMD_OPTION_LIST          = "list"
CMD_OPTION_CHECK_RESTART = "check"

# |||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# RUN_FILE_NAME      = "start_crawling.rb"

FILEROOT_PATH      = "/Users/0FRZ14015/Dropbox/_sample/ruby/pictlink_twitter_crawler/" 
RUN_FILE_NAME      = "start_crawling.rb"
NOHUP_FILE_NAME    = "nohup_cr.out"
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
  when CMD_OPTION_CHECK_RESTART then
    doCheckforRestart()
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
  # shell = "nohup clockwork " + FILEROOT_PATH + RUN_FILE_NAME + " \&"
  shell = "nohup clockwork " + FILEROOT_PATH + RUN_FILE_NAME + " \&\> " + FILEROOT_PATH + NOHUP_FILE_NAME + " \&" # (nohupファイルの作成場所を指定して）実行
  exec(shell) # 「start_crawling」ジョブの開始
end


#
# ジョブの停止（ = 削除）
#
def doStop()
  puts ">>>> do stop <<<<"
  shell = "pkill -f " + FILEROOT_PATH + RUN_FILE_NAME
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
  shell = "pgrep -fl " + FILEROOT_PATH + RUN_FILE_NAME
  exec(shell)
  # puts `pgrep -fl start_crawling`
end

#
# リスタートすべきかチェックする
#
def doCheckforRestart()

  puts "25分単位 - - - - -"

  t = Time.now.strftime("%H%M")
  puts "現在時刻 : " + t

  # 特定の時間（1日一回）のみコマンド発火させる
  if t == "1425" 
    puts "クローラ設定再読込 -> 再起動します。。。"
    # doRestart()
  else
    puts "発火スルー"
  end



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
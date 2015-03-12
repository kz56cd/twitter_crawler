require 'logger'

class MLog

  #
  # 目的 :
  # ログファイルとコンソール両方出力する
  #

  @l

  def initialize(date_str)
    @l = Logger.new("./data/log/log_" + date_str + ".log")

      # 
      # 例 : log_20150401.log
      #

  end
  
  def mputs(msg)
    puts msg
    @l.info(msg)
  end
end
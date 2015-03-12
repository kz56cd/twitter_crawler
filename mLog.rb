require 'logger'

class MLog

  #
  # 目的 :
  # ログファイル書込とコンソール出力、両方行う
  #

  @l

  def initialize(date_str, path)
    @l = Logger.new(checkDir(path + "log/") + "log_" + date_str + ".log")

      # 
      # 例 : log_20150401.log
      #

  end
  
  # ログ出力
  def mputs(msg)
    puts msg
    @l.info(msg)
  end

  # 改行
  def br
    puts ""
    @l.info("")
  end

  # 改行 (複数回)
  def brs(num)
    num.times do |i|
      puts ""
      @l.info("")  
    end  
  end

  def checkDir(path)
    FileUtils.mkdir_p(path) unless FileTest.exist?(path)    # ディレクトリが存在していなければ作成
    return path
  end

end
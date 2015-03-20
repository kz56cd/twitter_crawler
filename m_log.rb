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


# ----------------------------------------------------------

# require 'logger'

# class MLog

#   #
#   # 目的 :
#   # ログファイル書込とコンソール出力、両方行う
#   #

#   @l

#   def initialize(date_str, path)
#     # @l = Logger.new(checkDir(path + "log/") + "log_" + date_str + ".log")
#     @l = Logger.new(checkDir(path + "/log/") + "log_" + date_str + ".log")

#       # 
#       # 例 : log_20150401.log
#       #

#   end
  
#   # ログ出力
#   def mputs(msg)
#     puts msg
#     @l.info(msg)
#   end

#   # 改行
#   def br
#     puts ""
#     @l.info("")
#   end

#   # 改行 (複数回)
#   def brs(num)
#     num.times do |i|
#       puts ""
#       @l.info("")  
#     end  
#   end

#   def checkDir(path)
#     # カレントディレクトリを絶対パスで取得
#     apath = File.expand_path(path, __FILE__)
#     apath = apath.sub!("/" + __FILE__, "")
#     # apath = File.expand_path(path).to_s + "/" # 絶対パスに変換
#     File.chmod(0777, apath)
#     FileUtils.mkdir_p(apath) unless FileTest.exist?(apath)    # ディレクトリが存在していなければ作成
#     # File.chmod(0777, path)
#     return apath
#   end

# end
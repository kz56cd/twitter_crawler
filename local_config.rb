# require './clock_manager'

class LocalConfig

  @key_list = ""

  def initConf
    # clockManager = ClockManager.new()
    
    # =========================================================================== #
    # 検索キーワードを指定して実行
    # => 複数キーワードの場合は半角スペースを入れること
    # => 

    # extractedTweets.getTweetAll("スープ春雨", 2)
    # clockManager.setClock("回線焼きそば")

    # clockManager.setClock("光接続")
    # clockManager.setClock("もんじゃ焼き")
    # clockManager.setClock("するめ")
    @key_list = ["めだか" , "掃除機" , "春分の日　振替"]

    # =========================================================================== #

  end

  def getKeyword
    return @key_list
end

end
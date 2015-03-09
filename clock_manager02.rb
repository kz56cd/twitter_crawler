require './extracted_tweets'
require './local_config'
require 'clockwork'
include Clockwork

class ClockManager02

  @key = ""
  @extractedTweets
  @localConfig
  @key_list
  @cursor

  def initialize()
    @localConfig = LocalConfig.new()
    @localConfig.initConf()
    @cursor = -1
  end
  
  def setClock()
    # 動作
    handler do |job|
      case job
        # when "extracted.job"
        #   puts @key
        #   @extractedTweets.getTweetAll(@key, 2)
        #   @key = ""

        when "extracted.job"
          # 最後尾にきたらカーソルを戻す
          if @cursor == @key_list.length 
            @cursor = -1
          end

          @cursor = @cursor + 1
          puts @key_list[@cursor]
          puts "@cursor : " + @cursor.to_s

          # @extractedTweets.getTweetAll(@key_list[@cursor], 2)
          @extractedTweets.getTweetAll(@key_list[@cursor], 2, @cursor)
      end
    end

    # puts keyword

    # =>  (01) 検索キーワードの配列をconfigから取得する
    # =>  (02) その後、foreachで回してeveryを実行すれば
    # =>  (03) マルチスレッドで同時刻に走ることができる（はず）
    # *** indexを保持している必要あり ***
    

    # @key_list = @localConfig.getKeyword()   
    # for key in @key_list do
    #     @key = key
    #     puts "setClock : + " + @key
    #     every(30.seconds, 'extracted.job', :thread => true)
    # end

    @key_list = @localConfig.getKeyword()   
    @key_list.each_with_index do |key, i|
        @key = key
        puts "setClock : + " + @key
        every(30.seconds, 'extracted.job', :thread => true)
        sleep(3)
    end




    @extractedTweets = ExtractedTweets.new()
    # every(10.seconds, 'extracted.job', :thread => true)
    # every(2.seconds, 'extracted.job', :thread => true)
  end

  #   # setKey(keyword)

  #    # ローカルタイムゾーンで実行
  #   # every(1.day, 'local.job', :at => '12:00', :thread => true)

  #   # every(1.day, 'extracted.job', :at => ['12:00', '00:00'], :thread => true)


  # end

  # def setKey(keyword)
  #   key = keyword
  # end

  # def deleteKey
  #   key = ""
  # end
end
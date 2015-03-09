require './extracted_tweets'
require './local_config'
require 'clockwork'
include Clockwork

class ClockManager

  @key = ""
  @tag = ""
  @extractedTweets
  @localConfig
  @key_list
  @cursor

  def initialize(key , tag)
    @key = key
    @tag = tag
  end
  
  def setClock()
    # 動作
    handler do |job|
      case job
        when "extracted.job"
          @extractedTweets.getTweetAll(@key, 2 , @tag) # ツイート収集開始
      end
    end

    @extractedTweets = ExtractedTweets.new()

    # テスト用（インターバルによるジョブ発火）
    # every(30.seconds, 'extracted.job', :thread => true) # ジョブの登録 (マルチスレッド対応)

    # 本番（時間指定によるジョブ発火）
    every(1.day, 'extracted.job', :at => ['18:31', '18:32'], :thread => true) # ジョブの登録 (マルチスレッド対応)    
  end
end
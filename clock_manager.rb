require './extracted_tweets'
require './local_config'
require 'clockwork'
include Clockwork

class ClockManager

  @key      = ""
  @tag      = ""
  @csv_path = ""
  @start_time_list
  @extractedTweets

  # |||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  TWEET_GET_NUM = 3    # 一度の検索で取得するツイート数
  SLEEP_TIME    = 60     # 検索後の待機時間
  # |||||||||||||||||||||||||||||||||||||||||||||||||||||||||

  def initialize(key , tag, startTimeList, csv_path)
    @key             = key
    @tag             = tag
    @start_time_list = startTimeList
    @csv_path        = csv_path
  end
  
  def setClock()
    # 動作
    handler do |job|
      case job
        when "extracted.job"
          @extractedTweets.getTweetAll(@key, TWEET_GET_NUM, SLEEP_TIME, @tag, @csv_path) # ツイート収集開始
      end
    end

    @extractedTweets = ExtractedTweets.new()

    # ----------------------------------------------- #
    # テスト用（インターバルによるジョブ発火）
    #

    # every(60.seconds, 'extracted.job', :thread => true) # ジョブの登録 (マルチスレッド対応)
    every(1.day, 'extracted.job', :thread => true) # ジョブの登録 (マルチスレッド対応)

    # ----------------------------------------------- #
    # 本番（時間指定によるジョブ発火）
    #

    # every(1.day, 'extracted.job', :at => @start_time_list, :thread => true) # ジョブの登録 (マルチスレッド対応)   
  end
end
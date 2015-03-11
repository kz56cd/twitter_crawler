# require "active_support"
# require "active_support/all"
require 'active_support/time_with_zone'
require 'twitter'
require 'csv'

class ExtractedTweets	

	puts "||||||||||||||||||| func (get_extracted_tweet_all) start |||||||||||||||||||\n"

	@start_event_time     		  # 収集開始時の時刻
	@start_event_date     		  # 収集開始日
	@since_collect_scope_time   # 収集範囲 (スタート)
	@till_collect_scope_time    # 収集範囲 (エンド)
	@counter              		= 0
	@collect_type         		= ""

	HARF_DAY_TIME_FORMAT      = 43200
	COLLECT_TYPE_NOON         = "noon"
	COLLECT_TYPE_MIDNIGHT 	  = "midnight"
	TIME_DIFF_FORMAT      	  = "%Y-%m-%d %H:%M:%S"
	DATE_FORMAT           		= "%Y-%m-%d"
	
	# +++++++++++++++++++++++++++++ twitter APP KEYS +++++++++++++++++++++++++++++ 

	# 01
	# YOUR_CONSUMER_KEY       = "qeCCQxCEnZcnSkS75zbj9MA18"
	# YOUR_CONSUMER_SECRET    = "JYldeGC5R4cy3cEDzruXHVR0bJ97Qbjyc51n3OR1sUUTwb1n7q"
	# YOUR_ACCESS_TOKEN       = "3060999120-Fhvnr9ownWbSOhSJ0iOFPGpm3k5PPiFA3KpCSR0"
	# YOUR_ACCESS_SECRET      = "VMy3HEJrncS6wm7dWx5DhInNBWP70IHbtGZHeEwBnfSWf"

	# 02
	YOUR_CONSUMER_KEY       = "yIX9UZ1Tl4UmUbM79BlMDsASx"
	YOUR_CONSUMER_SECRET    = "xz2zFj6aqJZULloi582hft7IcO9mBumnpljbezAmdCVLEwibJQ"
	YOUR_ACCESS_TOKEN       = "3060999120-Cr7kW5p9tlt8DoClEyzjRsurv8hCD0jEjeRmLH2"
	YOUR_ACCESS_SECRET      = "ljzmkDUe6ZuAa5Hock2mZfkrV0bR6ziBsF9LiIAPRq3qw"

	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

	# def initialize()
 #    puts "START_EVENT_TIME : " + @start_event_time.to_s
 #  end


	#
	# twitterクライアントインスタンス取得（ * returnを省略した記法）
	#
	def getClient()
		client = Twitter::REST::Client.new do |config|
		  config.consumer_key        = YOUR_CONSUMER_KEY
		  config.consumer_secret     = YOUR_CONSUMER_SECRET
		  config.access_token        = YOUR_ACCESS_TOKEN
		  config.access_token_secret = YOUR_ACCESS_SECRET
		end
	end


	#
	#  キーワードに一致するtweetの取得
	#
	def getTweetAll(search_word, tweet_num, tag, csv_path)
		@start_event_time = Time.now
		# @start_event_date = Time.strptime(@start_event_time.to_s, DATE_FORMAT) 
		@start_event_date = Date.today
		puts " - - - - - - - - - - - - - - - - - - - - - - - - \nSTART_EVENT_TIME : " + @start_event_time.to_s
		
		# イニシャライズ
		since_id = 0
		max_id   = 0
		@counter = 0

		today 				= Date.today.to_s.delete("-")
		@collect_type = getCollectType()
		setCollectScopeTime() # つぶやき収集範囲の設定

		# csv_path = "./data/"
		# csv_name = csv_path + "tweet_20140309.csv"
		csv_name = csv_path + "tweet_" + tag + "_" + today + "_" + @collect_type + ".csv"
		puts "tag              : " + tag
		puts "name             : " + csv_name + "\n - - - - - - - - - - - - - - - - - - - - - - - - "


		# 通信させない際（テスト時等）はコメントアウト ------------------------------
		sleep 9999
		# ------------------------------------------------------------------------


		cli = getClient()

		# CSVファイル作成 / オープン
		CSV.open(csv_name, "wb") do |csv|
			puts 'csv open...'

			while @counter == 0  do
				begin

			    cli.search(search_word, :count => 1, :result_type => "recent", :max_id => max_id).take(tweet_num).each do |tweet|

					  # puts tweet.attrs
					  puts tweet.id.to_s
					  puts tweet.attrs[:user][:screen_name]
					  puts tweet.attrs[:user][:name]
					  puts tweet.text
					  puts tweet.created_at
					  puts "https://twitter.com/" + tweet.attrs[:user][:screen_name]
					  puts "=============================================="

					  # ================ 作業中 ================

					  # tweet.created_atはTimeクラスなので、このまま比較する 
					  if checkForTimeExceeding(tweet.created_at)
					  	
					  else 
					  	# CSV書込
					  	csv << [
						  	tweet.id.to_s, 
						  	tweet.attrs[:user][:screen_name],
						  	tweet.attrs[:user][:name],
						  	tweet.attrs[:user][:followers_count], 
						  	tweet.text, 
						  	tweet.created_at,
						  	"https://twitter.com/" + tweet.attrs[:user][:screen_name]
							]
					  end

					  # ================ / 作業中 ================

					  max_id = tweet.id
					end

			  # 検索ワードで Tweet を取得できなかった場合の例外処理
			  rescue Twitter::Error::ClientError
			  	puts 'rejected. retry.'
			    # 60秒待機し、リトライ
			    sleep(60)
			    retry
				end

				# 待機時間を設定
				puts '(sleep ...)'
				sleep 30
			
				# 確認用
				# puts "end (not sleep)"
				# counter = 1
			end

			puts "\n||||||||||||||||||| func (get_extracted_tweet_all) end |||||||||||||||||||"
		end	

		@counter = 0 # カウンタを戻す
	end


	#
	# 日付の比較
	#
	def checkForTimeExceeding(target_time)

		# since_time_str = ""
		# till_time_str  = ""
		# since_time = Time.new()
		# till_time  = Time.new()

		# if @collect_type == COLLECT_TYPE_NOON
		# 	# 当日00:00 ~ 当日12:00までのツイートを対象にする
		# 	since_time_str = @start_event_time.to_s + "00:00:00"
		# 	till_time_str  = @start_event_time.to_s + "12:00:00"
		# else
		# 	# 前日12:00 ~ 当日00:00までのツイートを対象にする
		# 	since_time_str = (@start_event_time - 1).to_s + "12:00:00"
		# 	till_time_str  = @start_event_time.to_s       + "00:00:00" 
		# end
		# puts "::::::::::ツイート収集範囲::::::::::" + since_time_str + " ~ " + till_time_str + "::::::::::"

		# Timeへ変換	
		# since_time = Time.strptime(since_time_str, TIME_DIFF_FORMAT)
		# till_time  = Time.strptime(till_time_str, TIME_DIFF_FORMAT)

		# 判定
		if target_time > @till_collect_scope_time
			puts "[ check ++++ 除外 (未来のツイート) ]"
			# puts "check ++++ 未来のツイート"
			return true
		elsif target_time > @since_collect_scope_time && target_time < @till_collect_scope_time
			puts "[ check ++++ 該当 ]"
			return false
		else
			puts "[ check ++++ 除外 (過去のツイート、処理を停止します) ]"
			@counter = 1
			return true
		end
	end

	#
	# 収集タイプ（昼 / 夜の収集か）の取得
	#
	def getCollectType()

		# start_event_Date  = Time.strptime(@start_event_time.to_s, DATE_FORMAT) 

		# イベント開始日（00時）のTimeインスタンスを生成
		midnight_time_str = @start_event_date.to_s + " 00:00:00" 
		midnight_time     = Time.strptime(midnight_time_str, TIME_DIFF_FORMAT) # Timeへ変換

		# 差分取得 / 判定
		diff = (@start_event_time - midnight_time).to_i
		# puts diff
		if diff < HARF_DAY_TIME_FORMAT # 昼をまたがっていない場合 
			return COLLECT_TYPE_MIDNIGHT
		else
			return COLLECT_TYPE_NOON
		end
	end


	#
	# つぶやき収集範囲の取得
	#
	def setCollectScopeTime()

		since_time_str = ""
		till_time_str  = ""

		if @collect_type == COLLECT_TYPE_NOON
			# 当日00:00 ~ 当日12:00までのツイートを対象にする
			since_time_str = @start_event_date.to_s + " 00:00:00"
			till_time_str  = @start_event_date.to_s + " 12:00:00"
		else
			# 前日12:00 ~ 当日00:00までのツイートを対象にする
			since_time_str = (@start_event_date - 1).to_s + " 12:00:00"
			till_time_str  = @start_event_date.to_s       + " 00:00:00" 
		end

		@since_collect_scope_time = Time.strptime(since_time_str, TIME_DIFF_FORMAT)
		@till_collect_scope_time  = Time.strptime(till_time_str, TIME_DIFF_FORMAT)
		puts "ツイート収集範囲 : " + @since_collect_scope_time.to_s + " ~ " + @till_collect_scope_time.to_s
	end

end
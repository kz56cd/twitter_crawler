require 'twitter'
require 'csv'
# require './local_config'

class ExtractedTweets	

	p ' - - - func (get_extracted_tweet_all) start - - - '

	YOUR_CONSUMER_KEY       = "qeCCQxCEnZcnSkS75zbj9MA18"
	YOUR_CONSUMER_SECRET    = "JYldeGC5R4cy3cEDzruXHVR0bJ97Qbjyc51n3OR1sUUTwb1n7q"
	YOUR_ACCESS_TOKEN       = "3060999120-Fhvnr9ownWbSOhSJ0iOFPGpm3k5PPiFA3KpCSR0"
	YOUR_ACCESS_SECRET      = "VMy3HEJrncS6wm7dWx5DhInNBWP70IHbtGZHeEwBnfSWf"

	# YOUR_CONSUMER_KEY       = "yIX9UZ1Tl4UmUbM79BlMDsASx"
	# YOUR_CONSUMER_SECRET    = "xz2zFj6aqJZULloi582hft7IcO9mBumnpljbezAmdCVLEwibJQ"
	# YOUR_ACCESS_TOKEN       = "3060999120-Cr7kW5p9tlt8DoClEyzjRsurv8hCD0jEjeRmLH2"
	# YOUR_ACCESS_SECRET      = "ljzmkDUe6ZuAa5Hock2mZfkrV0bR6ziBsF9LiIAPRq3qw"

	# twitterクライアントインスタンス取得（ * returnを省略した記法）
	def getClient()
		client = Twitter::REST::Client.new do |config|
		  config.consumer_key        = YOUR_CONSUMER_KEY
		  config.consumer_secret     = YOUR_CONSUMER_SECRET
		  config.access_token        = YOUR_ACCESS_TOKEN
		  config.access_token_secret = YOUR_ACCESS_SECRET
		end
	end

	 # ============ ok ============ 

	# client.update 'test from office.'
	# puts client.user_timeline("kz56cd")[0]['text']
	# puts client.user_timeline("kz56cd")[0].text

	 # ============ ok ============ 

	# |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

	# キーワードに一致するtweetの取得
	# def getTweetAll(search_word, tweet_num)
	def getTweetAll(search_word, tweet_num, tag)


		# イニシャライズ
		since_id = 0
		max_id = 0
		counter = 0
		csv_path = "./data/"
		# csv_name = csv_path + "tweet_20140309.csv"
		csv_name = csv_path + "tweet_" + tag + "_20140309.csv"
		puts "cursor : " + tag

		cli = getClient()

		# CSVファイル作成 / オープン
		CSV.open(csv_name, "wb") do |csv|

			while counter == 0  do
				begin

			    cli.search(search_word, :count => 1, :result_type => "recent", :max_id => max_id).take(tweet_num).each do |tweet|

					  # puts tweet.attrs
					  puts tweet.id
					  puts tweet.attrs[:user][:screen_name]
					  puts tweet.attrs[:user][:name]
					  puts tweet.text
					  puts tweet.created_at
					  puts "https://twitter.com/" + tweet.attrs[:user][:screen_name]
					  puts "=============================================="

					  csv << [
					  	tweet.id, 
					  	tweet.attrs[:user][:screen_name],
					  	tweet.attrs[:user][:name],
					  	tweet.attrs[:user][:followers_count], 
					  	tweet.text, 
					  	tweet.created_at,
					  	"https://twitter.com/" + tweet.attrs[:user][:screen_name]
						]

					  # 要改修 (GMTで換算するように変更予定)
					  if tweet.created_at.to_s.include?("2015-03-05 03") 
					  	puts "収集ここまで"
					  	counter = 1
					  end

					  max_id = tweet.id
					end

			  # 検索ワードで Tweet を取得できなかった場合の例外処理
			  rescue Twitter::Error::ClientError
			  	puts 'rejected. retry.'
			    # 60秒待機し、リトライ
			    sleep(60)
			    retry
				end
			

				# 60秒待機
				# puts '(sleep ...)'
				# sleep 4	
			
				# 確認用
				puts "end (not sleep)"
				counter = 1
			end

			p ' - - - func (get_extracted_tweet_all) end - - - '
		end	
	end


	# getTweetAll(client , ARGV[0], 2)
	# getTweetAll(client , "唐揚げ 爆発", 2)

	# localConfig = LocalConfig.new()
	# localConfig.abcd

end
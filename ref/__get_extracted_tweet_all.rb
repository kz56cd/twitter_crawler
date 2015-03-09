require 'twitter'
require 'csv'
# require 'pp'

p ' - - - func (get_extracted_tweet_all) start - - - '

YOUR_CONSUMER_KEY       = "qeCCQxCEnZcnSkS75zbj9MA18"
YOUR_CONSUMER_SECRET    = "JYldeGC5R4cy3cEDzruXHVR0bJ97Qbjyc51n3OR1sUUTwb1n7q"
YOUR_ACCESS_TOKEN       = "3060999120-Fhvnr9ownWbSOhSJ0iOFPGpm3k5PPiFA3KpCSR0"
YOUR_ACCESS_SECRET      = "VMy3HEJrncS6wm7dWx5DhInNBWP70IHbtGZHeEwBnfSWf"

# YOUR_CONSUMER_KEY       = "yIX9UZ1Tl4UmUbM79BlMDsASx"
# YOUR_CONSUMER_SECRET    = "xz2zFj6aqJZULloi582hft7IcO9mBumnpljbezAmdCVLEwibJQ"
# YOUR_ACCESS_TOKEN       = "3060999120-Cr7kW5p9tlt8DoClEyzjRsurv8hCD0jEjeRmLH2"
# YOUR_ACCESS_SECRET      = "ljzmkDUe6ZuAa5Hock2mZfkrV0bR6ziBsF9LiIAPRq3qw"

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = YOUR_CONSUMER_KEY
  config.consumer_secret     = YOUR_CONSUMER_SECRET
  config.access_token        = YOUR_ACCESS_TOKEN
  config.access_token_secret = YOUR_ACCESS_SECRET
end

 # ============ ok ============ 

# client.update 'test from office.'
# puts client.user_timeline("kz56cd")[0]['text']
# puts client.user_timeline("kz56cd")[0].text

 # ============ ok ============ 



# client.sample do |object|
#   puts object.text if object.is_a?(Twitter::Tweet)
# end

# topics = ["coffee", "tea"]
# client.filter(:track => topics.join(",")) do |object|
#   puts object.text if object.is_a?(Twitter::Tweet)
# end

# friends = client.friends
# 2.times.collect do
#   friends.take(20)
# end


# 制限かかってしまった

# user = client.user('kz56cd')
# user_friends_count = user.friends_count # 特定ユーザーがフォローしているユーザー数を取得

# friend_ids = Hash.new
# friend_ids = client.friend_ids("kz56cd") # 特定ユーザーがフォローしているユーザー情報

# friend_ids.each do |friend_id|
# 	a_user = client.user(friend_id)
# 	puts a_user.name
# 	# puts a_user.screen_name	
# 	# puts friend_id
# end

# ------------------------------------- 

# user = client.user('fp0pl')
# friends = user.follower_ids

# friends = client.follower_ids('fp0pl')
# puts friends





# friends.each do |elem|
#     text = elem['description'].gsub(',','|').gsub(/\n|\r|\r\n|\n\r/,' ')
#     print("#{elem['id']},#{elem['name']},#{text}\n")
# end


# |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# イニシャライズ
since_id = 0
max_id = 0
counter = 0
csv_name = "tweet_20140306.csv"

# CSVファイル作成 / オープン
CSV.open(csv_name, "wb") do |csv|

	while counter == 0  do
		begin
	    # 引数で受け取ったワードを元に、検索結果を取得し、古いものから順に並び替え
	    # ※最初はsince_id=0であるため、tweet ID 0以降のTweetから最新のもの上位100件を取得
	    # client.search(ARGV[0], :count => 100, :result_type => "recent", :since_id => since_id).results.reverse.map do |status|
	    
	    # results
	    # results = client.search(ARGV[0], :count => 2, :result_type => "recent", :since_id => since_id).attrs
	    # puts results

	    # results.keys.each do |key|
	    # 	puts key
	    # end

	    # results.each do |status|

	    # client.search(ARGV[0], :count => 1, :result_type => "recent", :since_id => since_id).attrs.each do |status|

	    # 	# puts status[0].to_h[:source]
	    # 	puts status[0]['statuses'].created_at

	    # 	# puts status
	    # 	# puts key
	    # end

	    # client.search(ARGV[0], :count => 2, :result_type => "mixed", :since_id => since_id).take(2).each do |tweet|
	    # client.search(ARGV[0], :count => 2, :result_type => "recent", :max_id => max_id).take(2).each do |tweet|
			
	    client.search(ARGV[0], :count => 1, :result_type => "recent", :max_id => max_id).take(3).each do |tweet|

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
			

	    # client.search(ARGV[0], :count => 100, :result_type => "recent", :since_id => since_id).attrs do |status|

	    # 	puts 'search ok'

	    #   # Tweet ID, ユーザ名、Tweet本文、投稿日を1件づつ表示
	    #   "#{status.id} :#{status.from_user}: #{status.text} : #{status.created_at}"

	    #   p status.id
	    #   p "@" + status.from_user
	    #   p status.text
	    #   p status.created_at

	    #   print("\n")

	    #   # 取得したTweet idをsince_idに格納
	    #   # ※古いものから新しい順(Tweet IDの昇順)に表示されるため、
	    #   #  最終的に、取得した結果の内の最新のTweet IDが格納され、
	    #   #  次はこのID以降のTweetが取得される
	    #   since_id = status.id
	    # end



	  # 検索ワードで Tweet を取得できなかった場合の例外処理
	  rescue Twitter::Error::ClientError
	  	puts 'rejected. retry.'
	    # 60秒待機し、リトライ
	    sleep(60)
	    retry
		end

		# 60秒待機
			puts '(sleep ...)'
			sleep 4
		
	end
end

# |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


# SLICE_SIZE = 100
 
# def get_all_friends(screen_name , client)
# 	cli = client
# 	cursor = -1

# 	# フォロワーidを全件取得（カーソルで段階的に取得）
# 	followerIds = []
# 	while cursor != 0 do
# 		followers = cli.follower_ids(screen_name, {cursor: cursor})
# 		cursor = followers.attrs[:next_cursor]
	
# 		idlist = followers.attrs[:ids]
# 		followerIds += idlist
# 		sleep(4)
# 	end

# 	file_name = "follower_row_ids.txt"

# 	File.open(file_name, 'a') {|file|

# 		followerIds.each do |id|
# 			file.write id.to_s + "\n"		
# 		end
# 	}

# 	puts '+++++++++++++++++++++++++++++++ get ALL followerIds... +++++++++++++++++++++++++++++++ '
	
# 	file_name = "follower_ids.txt"    #保存するファイル名
	 
# 	all_friends = []
# 	followerIds.each_slice(SLICE_SIZE).each do |slice|
# 		cli.users(slice).each do |friend|
# 			all_friends << friend

#   		File.open(file_name, 'a') {|file|
#     		file.write friend.screen_name + "\n"
#   		}
# 		end
		

# 		puts 'now load ' + all_friends.length.to_s + 'ids'
# 		puts '-----------------------------------'
# 		sleep 15
# 	end
# 	all_friends
# end


# get_all_friends('fp0pl' , client)
# get_all_friends('mnmnioiorrii' , client)
# get_all_friends('kz56cd' , client)
# get_all_friends('pictlink_furyu' , client)

p ' - - - func (get_extracted_tweet_all) end - - - '

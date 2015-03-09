require 'twitter'
# require 'pp'

p ' - - - func start - - - '

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


SLICE_SIZE = 100
 
def get_all_friends(screen_name , client)
	cli = client
	cursor = -1

	# フォロワーidを全件取得（カーソルで段階的に取得）
	followerIds = []
	while cursor != 0 do
		# followers = cli.follower_ids(screen_name, {"cursor"=>cursor})
		followers = cli.follower_ids(screen_name, {cursor: cursor})
		# cursor = followers.next_cursor
		# cursor = followers.attrs['next_cursor_str']
		cursor = followers.attrs[:next_cursor]
		# puts cursor

		idlist = followers.attrs[:ids]
		followerIds += idlist
		# idlist.each do |id|
		# 	follower_ids << id
		# end

		# puts follower_ids
		# puts idlist

		# followerIds += followers.ids
		sleep(4)
	end

	file_name = "follower_row_ids.txt"

	File.open(file_name, 'a') {|file|

		followerIds.each do |id|
			file.write id.to_s + "\n"		
		end
	 # file.write friend.screen_name
	 # file.write "\n"
	}

	puts '+++++++++++++++++++++++++++++++ get ALL followerIds... +++++++++++++++++++++++++++++++ '
	# puts followerIds

	file_name = "follower_ids.txt"    #保存するファイル名
	 
	all_friends = []
	# cli.friend_ids(screen_name).each_slice(SLICE_SIZE).each do |slice|
	# cli.follower_ids(screen_name).each_slice(SLICE_SIZE).each do |slice|
	followerIds.each_slice(SLICE_SIZE).each do |slice|
		cli.users(slice).each do |friend|
			all_friends << friend

  		File.open(file_name, 'a') {|file|
    		file.write friend.screen_name + "\n"
  		}
			# puts friend.screen_name
		end
		

		puts 'now load ' + all_friends.length.to_s + 'ids'
		puts '-----------------------------------'
		sleep 15
	end
	all_friends
end


# get_all_friends('fp0pl' , client)
# get_all_friends('mnmnioiorrii' , client)
# get_all_friends('kz56cd' , client)
get_all_friends('pictlink_furyu' , client)

p ' - - - func end - - - '

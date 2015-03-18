# require "active_support"
# require "active_support/all"
require 'active_support/time_with_zone'
require 'twitter'
require 'csv'
require './m_log'
require './twitter_setting'

class ExtractedTweets	

	@l                          # mod Logger     インスタンス
	@ts                         # twitterSetting インスタンス
	@start_event_time     		  # 収集開始時の時刻
	@start_event_date     		  # 収集開始日
	@since_collect_scope_time   # 収集範囲 (スタート)
	@till_collect_scope_time    # 収集範囲 (エンド)
	@counter              		= 0
	@stop_search_flg          = false
	@collect_type         		= ""

	HARF_DAY_TIME_FORMAT      = 43200
	COLLECT_TYPE_NOON         = "noon"
	COLLECT_TYPE_MIDNIGHT 	  = "midnight"
	TIME_DIFF_FORMAT      	  = "%Y-%m-%d %H:%M:%S"
	DATE_FORMAT           		= "%Y-%m-%d"
	DATE_FILENAME_FORMAT      = "%Y%m%d"
	BACKUP_FILENAME_FORMAT    = "bk_"

	CSV_MODE_EXCEL						= 1
	CSV_MODE_OTHER						= 0
	CSV_MODE 									= CSV_MODE_OTHER


	def initialize()
    @ts = TwitterSetting.new()		
  end

	#
	# twitterクライアントインスタンス取得（ * returnを省略した記法）
	#
	def getClient()
		client = Twitter::REST::Client.new do |config|
		  config.consumer_key        = @ts.getConsumerKey()
		  config.consumer_secret     = @ts.getConsumerSecret()
		  config.access_token        = @ts.getAccessToken()
		  config.access_token_secret = @ts.getAccessSecret()
		end
	end

	#
	#  キーワードに一致するtweetの取得
	#
	def getTweetAll(search_word, tweet_num, sleep_time, tag, csv_path)



		@start_event_time = Time.now
		@start_event_date = Date.today
		today 				    = @start_event_date.to_s.delete("-")
		# ロガーインスタンス生成
		@l = MLog.new(today, csv_path) 
		@l.brs(5); @l.mputs("||||||||||||||||||| func (get_extracted_tweet_all) start |||||||||||||||||||"); @l.br()
		@l.mputs(" - - - - - - - - - - - - - - - - - - - - - - - - START_EVENT_TIME : " + @start_event_time.to_s)


		# イニシャライズ
		since_id 				= 0
		max_id   			  = 0
		@counter        = 0
		csv_name 				= ""
		backup_csv_name = ""
		isNewFile       = true 
		addTweetlist	  = Array.new()
	
		@collect_type = getCollectType()
		setCollectScopeTime() # つぶやき収集範囲の設定

		path     = checkDir(csv_path)
	
		# 既存のCSVファイルに追記すべきかチェック
		will_add_file = checkShouldAddCSVfile(path, tag)
		if will_add_file.length == 0 
			csv_name = createNewCSVfile(path, tag) # 新規作成
		else
			@l.br(); @l.mputs(will_add_file + "に書き込みます..."); @l.br()
			csv_name  = will_add_file
			isNewFile = false 
		end

		# バックアップCSVファイルの作成
		backup_csv_name = makeBackupCSVFile(path, csv_name, isNewFile)

		@l.br()
		@l.mputs("tag              : " + tag)
		@l.mputs("name             : " + csv_name)
		@l.mputs("- - - - - - - - - - - - - - - - - - - - - - - - ")

		# 通信させない際（テスト時など）はコメントアウト ------------------------------
		# sleep 9999
		# ------------------------------------------------------------------------


		cli = getClient()

		# CSVファイル作成 / オープン
		# CSV.open(csv_name, "a") do |csv|
			while (!@stop_search_flg) do
				begin
					@l.mputs("検索開始")
			    # cli.search(search_word, :count => 1, :result_type => "recent", :max_id => max_id).take(tweet_num).each do |tweet|
			    cli.search(search_word, :result_type => "recent", :max_id => max_id).take(tweet_num).each do |tweet|

			    	hasImage = checkHasImages(tweet.attrs) # 画像の有無をチェック (int)

					  @l.mputs(tweet.id.to_s)
					  @l.mputs(tweet.attrs[:user][:screen_name])
					  @l.mputs(tweet.attrs[:user][:name])
					  @l.mputs(tweet.text)
					  @l.mputs("image : " + hasImage.to_s)
					  @l.mputs(tweet.created_at)
					  @l.mputs("https://twitter.com/" + tweet.attrs[:user][:screen_name])
					  @l.mputs("==============================================")

					  # tweet.created_atはTimeクラスなので、このまま比較する 
					  if checkForTimeExceeding(tweet.created_at)
					  	# 現状はスタブ
					  else 
							addTweetlist.unshift(tweet) # 配列の先頭へ追加
					  end
					  max_id = tweet.id

					end

			  # 検索ワードで Tweet を取得できなかった場合の例外処理
			  rescue Twitter::Error::ClientError
			  	puts 'rejected. retry.'
			    # 60秒待機し、リトライ
			    sleep(sleep_time)
			    retry
				end

				if @stop_search_flg == false
					@l.mputs('(sleep ...)')
					sleep(sleep_time) # 待機 ( = トラフィック軽減のため)
				end
			end

			@l.br()
			@l.mputs("||||||||||||||||||| func (get_extracted_tweet_all) end |||||||||||||||||||")
		# end	

		# @counter = 0 # カウンタを戻す
		@stop_search_flg = false

		# CSVファイルへの追加 / 修正の準備	
		prepareForModifingCSV(csv_name, backup_csv_name, addTweetlist)		
	end

	#
	# CSVファイルへの追加 / 修正の準備
	#	
	def prepareForModifingCSV(name, bk_name, list)
		@l.br()
		@l.mputs("++++++++++++++ CSVファイル調整 : 開始 ++++++++++++++")
		@l.mputs("追加予定のリスト数 : " + list.length.to_s)
		addCSVfromList(name, list)						# 既存CSVファイルへの行追加
		changeLineFeedCode(CSV_MODE, name)		# 改行コード変更
		deleteBackupFile(bk_name, name)			  # バックアップファイルの消去
		@l.mputs("++++++++++++++ CSVファイル調整 : 完了 ++++++++++++++")
	end


	#
	# 配列よりCSVファイルへの追加
	#
	def addCSVfromList(name, list)
		
		@l.mputs("CSV書込開始 : " + name) 
		@l.mputs("行数        : " + list.length.to_s)

		CSV.open(name, "a") do |csv|
			list.each do |t|
				csv << [
							  	modHeadColumnForExcel(CSV_MODE, t.id.to_s), # （エクセル用にフォーマット整える場合は）true選択 
							  	t.attrs[:user][:screen_name],
							  	t.attrs[:user][:name],
							  	t.attrs[:user][:followers_count], 
							  	t.text, 
							  	checkHasImages(t.attrs), # 画像の有無チェック 
							  	t.created_at,
						  		"https://twitter.com/" + t.attrs[:user][:screen_name]
							]
			end
		end

		@l.mputs("CSV書込完了")
	end

	#
	# 日付の比較
	#
	def checkForTimeExceeding(target_time)
		# 判定
		if target_time > @till_collect_scope_time
			@l.mputs("[ check ++++ 除外 (収集範囲より未来のツイート) ]")
			return true
			# return false # [テスト用] 未来のツイートも追加する
		elsif target_time > @since_collect_scope_time && target_time < @till_collect_scope_time
			@l.mputs("[ check ++++ 該当 ]")
			return false
		else
			@l.mputs("[ check ++++ 除外 (収集範囲より過去のツイート - 処理を停止します) ]")
			# @counter = 1
			@stop_search_flg = true
			return true
		end
	end


	#
	# 収集タイプ（昼 / 夜の収集か）の取得
	#
	def getCollectType()
		# イベント開始日（00時）のTimeインスタンスを生成
		midnight_time_str = @start_event_date.to_s + " 00:00:00" 
		midnight_time     = Time.strptime(midnight_time_str, TIME_DIFF_FORMAT) # Timeへ変換

		# 差分取得 / 判定
		diff = (@start_event_time - midnight_time).to_i
		# @l.mputs(diff)
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
		@l.mputs("ツイート収集範囲 : " + @since_collect_scope_time.to_s + " ~ " + @till_collect_scope_time.to_s)
	end

	
	#
	# 保存先のPathチェック
	#
	def checkDir(path)
		FileUtils.mkdir_p(path) unless FileTest.exist?(path) 		# ディレクトリが存在していなければ作成
		return path
	end


	#
	# つぶやき内に画像が存在するかチェック
	#
	def checkHasImages(h)
		
		if h[:entities].has_key?(:media)
			# 更に、画像のURL(2つ)が存在しているかチェック
			if h[:entities][:media][0][:media_url_https].to_s.length != 0 || h[:entities][:media][0][:media_url].to_s.length != 0
			# if h[:entities][:media][0][:media_url_https].to_s.length != 0 && h[:entities][:media][0][:media_url].to_s.length != 0
				# @l.mputs("media_url_https : " + h[:entities][:media][0][:media_url_https].to_s)
				return 1
			end
		end
		return 0 
	end


	#
	# 既存ファイルに追記すべきかチェックする
	# return  追記すべきファイルパス (ファイル名含む)
	#
	def checkShouldAddCSVfile(path , tag)
		@l.mputs("checkShouldAddCSVfile start")
		@l.br()

		will_add_file = ""

		# grep対象のファイルパスを用意 (途中までのもの)
		ta = path + "tweet_" + tag + "_" 
		# ta = "./data/tweet_"

		# （保存ディレクトリ内にある）該当タグのファイル名を全て取得
		Dir::glob(path + "*").each { |fname|
     if FileTest.directory?(fname) 
     	# ディレクトリの場合
      #  -> 現状は無視
      else
      	# パスの一部が含まれている場合
        if fname.to_s.include?(ta) 
					
        	stripfname = fname.sub(ta, "").sub(".csv", "") # 不要文字列の除去
        	name_dates = stripfname.split("_")       # 「日付箇所」を分割
					
					# ツイート収集の日付範囲をチェック
					if name_dates.length != 0 && name_dates[0].to_i < name_dates[1].to_i
						# @l.mputs(name_dates)

						# イベント開始日時を適切な形( 例: 20150301 )に変換
						start_event_date_num = @start_event_date.strftime(DATE_FILENAME_FORMAT).to_i 
						
						# 収集タイプが夜中の場合
						if @collect_type == COLLECT_TYPE_MIDNIGHT
							# （収集対象が昨日のものになるため）日付を一日分ずらす
							start_event_date_num = start_event_date_num - 1
						end

						#
						# 現在日時と比較する
						#

						# 「ファイル名の日時の範囲内」である場合 
						if name_dates[0].to_i <= start_event_date_num && start_event_date_num <= name_dates[1].to_i 
							# @l.mputs("追加すべきファイル : " + fname)
							will_add_file = fname
							break # 一件該当すればOK ( = 最新のファイルしか該当しない想定)
						else
							@l.mputs("範囲外 : " + fname)
						end
					else
						@l.mputs("無効なファイルです : " + fname)
					end
        end
      end
  	}
  	return will_add_file	
	end


	#
	# 新しいCSVファイルを作成
	# return  新規作成したファイルパス (ファイル名含む)
	#
	def createNewCSVfile(path, tag)
		@l.mputs(" + + + + + + + + + + + + + + + + + + ")
		@l.mputs("新しいファイルを作成します...")
		@l.br()
		fname = ""

		# --------------------------------------------
		# ファイル名見本
		#	tweet_turtles_20150909_20150322.csv
		#
		# 「turtles」がタグ、
		#  「_20150909_20150322」が収集範囲となる (* 収集範囲は14日間)
		# --------------------------------------------

		# 01 : ---------------------------------------
		# 収集を始める日付 （必ず「月曜日」とする）の用意

		day_of_the_week = @start_event_date.wday
		@l.mputs("今日の曜日 : " + day_of_the_week.to_s)
		
		# （属している週の）月曜までの差分を算出
		day_diff = @start_event_date.wday - 1 # 1は月曜  (参考 : wdays = ["日", "月", "火", "水", "木", "金", "土"])
		@l.mputs("day_diff : " + day_diff.to_s)
		# 月曜の日付を算出
		start_date 	   = @start_event_date - day_diff.day
		start_date_str = start_date.strftime(DATE_FILENAME_FORMAT)
		@l.mputs("収集範囲(スタート) : " + start_date_str)

		# 02 : ---------------------------------------
		# 収集を終える日付 （必ず「日曜日」とする）の用意
		end_date = start_date + (14 - 1).day
		end_date_str = end_date.strftime(DATE_FILENAME_FORMAT)
		@l.mputs("収集範囲(エンド)   : " + end_date_str)
		@l.br()

		# 確認 ( = 日曜日になっているか)
		if end_date.wday == 0

			# 03 : ---------------------------------------
			# ファイル名の作成

			fname = path + "tweet_" + tag + "_" + start_date_str + "_" + end_date_str + ".csv"
			@l.mputs("作成 : " + fname)
			@l.mputs(" + + + + + + + + + + + + + + + + + +")
			@l.br()
		else
			@l.mputs("ファイル作成エラー")
		end

		return fname
	end


	### for CSV_MODE_EXCEL


	#
	# 先頭カラムが（Excel上で）正しく表示されるよう調整
	#
	def modHeadColumnForExcel(flg, str)
		
		# Excelモードの場合
		if flg == CSV_MODE_EXCEL 
			str = "=\"" + str + "\""
			# @l.mputs("先頭カラム調整完了 : " + name)
		end
		return str
	end


	#
	# 改行コードの変更
	#
	def changeLineFeedCode(flg, name)
		
		# Excelモードの場合
		if flg == CSV_MODE_EXCEL 

			modCsvText = ""

			# CRLFに変更する ( = 通常はCR)
			File.open(name , "rb" ) { |io|
				csvText = io.read

				# 改行コード変換 (全改行コードが対象)
				modCsvText = csvText.gsub!(/(\r\n|\n|\r)/ , "\r\n")
			}

			if modCsvText.length != 0
				# ファイル書込			
				File.open(name, "wb") { |io|
					io.write(modCsvText)
				}

				@l.mputs("改行コード変換完了 : " + name)
			end
		end
	end


	### for backup CSV file


	#
	# バックアップCSVファイルの作成
	#
	def makeBackupCSVFile(path, name, isNew)
		# バックアップ用のファイル名用意
		modname = name.sub(path , "")
		modname = path + BACKUP_FILENAME_FORMAT + modname

		# 元ファイルが空でない場合
		if isNew == false 
			# コピー元のデータを取得
			source = ""
			File.open(name , "rb" ) { |io|
				source = io.read
			}
		end 

		# コピー先に書込
		File.open(modname, "wb") { |io|
			io.write(source)
		}
		@l.mputs(isNew == false ? "バックアップファイル作成 : " + modname : "バックアップファイル作成 （空） : " + modname) 
		return modname
	end


	#
	# バックアップCSVファイルの作成
	#
	def deleteBackupFile(bk_name, name)
		@l.mputs("。。。。削除したつもり。。。。")
	end

end
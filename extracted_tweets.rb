# encoding: utf-8

# require "active_support"
# require "active_support/all"
require 'active_support/time_with_zone'
require 'twitter'
require 'csv'
require_relative './m_log'
require_relative './twitter_setting'

class ExtractedTweets	

	@l                          # mod Logger     インスタンス
	@ts                         # twitterSetting インスタンス
	@start_event_time     		  # 収集開始時の時刻
	@start_event_date     		  # 収集開始日
	@since_collect_scope_time   # 収集範囲 (スタート)
	@till_collect_scope_time    # 収集範囲 (エンド)
	@should_stop_searching    
	@is_logged_exception      
	@collect_type         		= ""
	@search_word							= ""

	HARF_DAY_TIME_FORMAT      = 43200
	COLLECT_TYPE_NOON         = "noon"
	COLLECT_TYPE_MIDNIGHT 	  = "midnight"
	TIME_DIFF_FORMAT      	  = "%Y-%m-%d %H:%M:%S"
	DATE_FORMAT           		= "%Y-%m-%d"
	DATE_FILENAME_FORMAT      = "%Y%m%d"
	BACKUP_FILENAME_FORMAT    = "bk_"

	CSV_MODE_EXCEL						= 1
	CSV_MODE_OTHER						= 0
	CSV_NEWLINE_CODE_EXCEL	  = "CRLF"
	CSV_NEWLINE_CODE_OTHER	  = "LF"

	LOG_MSG_NO_TWEET	        = "_____CHECK_ME_____ >>> ツイートがありません。"
	LOG_MSG_NO_SCOPE_TWEET	  = "_____CHECK_ME_____ >>> 収集範囲内のツイートがありません。"
	LOG_MSG_SOME_ERROR   	    = "_____CHECK_ME_____ >>> 何らかのエラーが発生しました。"
	LOG_MSG_STOP_FUNC 				= "_____CHECK_ME_____ >>> 処理を停止します。"
	LOG_MSG_SEARCH_WORD				= "_____CHECK_ME_____ >>> 検索ワード : "

	# |||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	CSV_MODE 									= CSV_MODE_EXCEL 		# CSV書出モード
	MAX_TRY_ERROR_CNT 				= 10  					 		# エラー何回までトライするか
	# |||||||||||||||||||||||||||||||||||||||||||||||||||||||||

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
		
		@search_word		  = search_word
		@start_event_time = Time.now
		@start_event_date = Date.today
		today 				    = @start_event_date.to_s.delete("-")
		# ロガーインスタンス生成
		@l = MLog.new(today, csv_path) 
		@l.brs(5); @l.mputs("||||||||||||||||||| func (get_extracted_tweet_all) start |||||||||||||||||||"); @l.br()
		@l.mputs(" - - - - - - - - - - - - - - - - - - - - - - - - START_EVENT_TIME : " + @start_event_time.to_s)

		# イニシャライズ
		since_id 				       = 0
		max_id   			         = 0
		cnt                	   = 0
		error_cnt				     	 = 0
		csv_name 					   	 = ""
		backup_csv_name 	   	 = ""
		is_new_file      	   	 = true 
		add_tweet_list	  	 	 = Array.new()
		@is_logged_exception   = false
		@should_stop_searching = false

	
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
			is_new_file = false 
		end

		# バックアップCSVファイルの作成
		backup_csv_name = makeBackupCSVFile(path, csv_name, is_new_file)

		@l.br()
		@l.mputs("tag              : " + tag)
		@l.mputs("name             : " + csv_name)
		@l.mputs("- - - - - - - - - - - - - - - - - - - - - - - - ")


		# テスト用！！！！！！
		# willDeleteBackupFile(backup_csv_name, csv_name, is_new_file)

		# 通信させない際（テスト時など）はコメントアウト ------------------------------
		# sleep 9999
		# ------------------------------------------------------------------------


		# twitterクライアントインスタンス取得
		cli = getClient()

		# CSVファイル作成 / オープン
		while (!@should_stop_searching) do
			begin
				@l.mputs("検索開始")
				cnt = cnt + 1

				# ClientErrorが続いた場合
				if error_cnt >= MAX_TRY_ERROR_CNT
					# 検索処理をやめる
					@should_stop_searching = true
					showExceptionLog(LOG_MSG_SOME_ERROR)  # エラー発生についてログ表示
					break
				else

					#
					# 検索開始
					#

			    cli.search(search_word, :result_type => "recent", :max_id => max_id).take(tweet_num).each do |tweet|
					# cli.search(search_word, :count => 1, :result_type => "recent", :max_id => max_id).take(tweet_num).each do |tweet|

			    	has_image = checkHasImages(tweet.attrs) # 画像の有無をチェック (int)

					  @l.mputs(tweet.id.to_s)
					  @l.mputs(tweet.attrs[:user][:screen_name])
					  @l.mputs(tweet.attrs[:user][:name])
					  @l.mputs(tweet.text)
					  @l.mputs("image : " + has_image.to_s)
					  @l.mputs(tweet.created_at)
					  @l.mputs("https://twitter.com/" + tweet.attrs[:user][:screen_name])
					  @l.mputs("==============================================")

					  # tweet.created_atはTimeクラスなので、このまま比較する 
					  if checkForTimeExceeding(tweet.created_at)
					  	# 現状はスタブ
					  else 
							add_tweet_list.unshift(tweet) # 配列の先頭へ追加
					  end
					  max_id = tweet.id
					end
				end

		  # 検索ワードで Tweet を取得できなかった場合の例外処理
		  rescue Twitter::Error::ClientError
		  	puts 'rejected. retry.'
		  	error_cnt = error_cnt + 1
		    # 60秒待機し、リトライ
		    sleep(sleep_time)
		    retry
			end

			if @should_stop_searching == false
				@l.mputs('(sleep ...)')
				sleep(sleep_time) # 待機 ( = トラフィック軽減のため)
			end

			# 検索結果が0件( = ツイート自体無い)かチェックする
			if cnt >= 3 && error_cnt == 0
				@should_stop_searching = true
				showExceptionLog(LOG_MSG_NO_TWEET) # ログ表示
				break
			end
		end

		# CSVファイルへの追加 / 修正の準備	
		prepareForModifingCSV(csv_name, backup_csv_name, add_tweet_list, is_new_file)
		
		@should_stop_searching   = false
		@is_logged_exception     = false

		@l.br()
		@l.mputs("||||||||||||||||||| func (get_extracted_tweet_all) end |||||||||||||||||||")
	end

	#
	# CSVファイルへの追加 / 修正の準備
	#	
	def prepareForModifingCSV(name, bk_name, list, is_new)

		list_cnt_str = list.length.to_s

		if list_cnt_str == "0"
			showExceptionLog(LOG_MSG_NO_SCOPE_TWEET) 			# 追加ツイート 0件 (ログ出力)
			willDeleteBackupFile(bk_name, name, is_new) 	# バックアップファイルの消去
		else
			@l.br()
			@l.mputs("++++++++++++++ CSVファイル調整 : 開始 ++++++++++++++")
			@l.mputs("追加予定のリスト数 : " + list_cnt_str)
			addCSVfromList(name, list)						   				 					 # 既存CSVファイルへの行追加
			changeLineFeedCode(CSV_MODE, name, CSV_NEWLINE_CODE_OTHER) # 改行コード変更
			willDeleteBackupFile(bk_name, name, is_new) 			 					 # バックアップファイルの消去
			changeLineFeedCode(CSV_MODE, name, CSV_NEWLINE_CODE_EXCEL) # 改行コード変更
			@l.mputs("++++++++++++++ CSVファイル調整 : 完了 ++++++++++++++")
		end
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
			@should_stop_searching = true
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
					
        	strip_fname = fname.sub(ta, "").sub(".csv", "") # 不要文字列の除去
        	name_dates  = strip_fname.split("_")       # 「日付箇所」を分割
					
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
	def changeLineFeedCode(flg, name, type)
		
		# Excelモードの場合
		if flg == CSV_MODE_EXCEL

			replace_str = ""
			if type == "CRLF"
				replace_str = "\r\n"
			else
				replace_str = "\n"
			end 

			mod_csv_text = ""

			# CRLFに変更する ( = 通常はCR)
			File.open(name , "rb" ) { |io|
				csv_text = io.read

				# 改行コード変換 (全改行コードが対象)
				mod_csv_text = csv_text.gsub!(/(\r\n|\n|\r)/ , replace_str)
			}

			if mod_csv_text.to_s.length != 0
				# ファイル書込			
				File.open(name, "wb") { |io|
					io.write(mod_csv_text)
				}

				@l.mputs("改行コード変換完了 (" + type + ") : " + name)
			end
		end
	end


	### for backup CSV file


	#
	# バックアップCSVファイルの作成
	#
	def makeBackupCSVFile(path, name, is_new)
		# バックアップ用のファイル名用意
		mod_name = name.sub(path , "")
		mod_name = path + BACKUP_FILENAME_FORMAT + mod_name

		# 元ファイルが空でない場合
		if is_new == false 
			# コピー元のデータを取得
			source = ""
			File.open(name , "rb" ) { |io|
				source = io.read
			}
		end 

		# コピー先に書込
		File.open(mod_name, "wb") { |io|
			io.write(source)
		}
		@l.mputs(is_new == false ? "バックアップファイル作成 : " + mod_name : "バックアップファイル作成 （空） : " + mod_name) 
		return mod_name
	end


	#
	# バックアップCSVファイルを削除してよいかチェック
	#
	def willDeleteBackupFile(bk_name, name, is_new)
		@l.mputs("バックアップファイルを削除してよいかチェック。。")
		is_new == true ? deleteEmptyBackupFile(bk_name, name) : deleteBackupFile(bk_name, name) 
	end


	#
	# バックアップCSVファイル（空）の削除
	#
	def deleteEmptyBackupFile(bk_name, name)
		# 確認は、なし
		File.delete(bk_name)
		@l.mputs("バックアップファイル（空）を削除 : " + bk_name)
	end


	#
	# バックアップCSVファイルの削除
	#
	def deleteBackupFile(bk_name, name)

		# 確認事項 ---------------------------------------------------------------
		# 01: 「バックアップファイル」の最終行は「新しいCSVファイル」の方にも存在するか
		# 02: 先頭のidは同一か 
		# 03: lengthは「新しいCSVファイル」の方が長いか

		flg_cnt     = 0
		num         = 0
		first_id    = ""
		last_id     = ""
		bk_num      = 0
		bk_first_id = ""

		# さくら用
		# 一旦改行コードをCRに戻す

		# 「新しいCSVファイル」を開く
		CSV.open(name , "r:utf-8") { |io|
			io.read.each.with_index(0) do |tweet, index|
				if index == 0
					first_id = tweet[0].sub(/(\=|\")/, "")  # <= hash化しても良かったが 取り急ぎindexで取得する					
				end
				last_id = tweet[0].sub(/(\=|\")/, "") 		 # 上書
				num = index
			end
		}

		# 「バックアップファイル」を開く
		flg = false
		CSV.open(bk_name , "r:utf-8") { |io|
			io.read.each.with_index(0) do |tweet, index|
				if index == 0
					bk_first_id = tweet[0].sub(/(\=|\")/, "")	
				end

				# 確認
				# 01: 「バックアップファイル」の最終行は「新しいCSVファイル」の方にも存在するか		
				if flg == false && last_id == tweet[0].sub(/(\=|\")/, "")
					flg = true
					flg_cnt = flg_cnt + 1
					@l.mputs(" ---> check 01: ok")
				end
				bk_num = index
			end
		}		

		# 確認
		# 02: 先頭のidは同一か 
		if bk_first_id == first_id
			flg_cnt = flg_cnt + 1
			@l.mputs(" ---> check 02: ok")
		end

		# 確認
		# 03: lengthは「新しいCSVファイル」の方が長いか、同一か
		if bk_num <= num 
			flg_cnt = flg_cnt + 1
			@l.mputs(" ---> check 03: ok")
		end

		# 全て確認をパスした場合
		if flg_cnt == 3
			puts "flg_cnt : " + flg_cnt.to_s
			File.delete(bk_name)
			@l.mputs("バックアップファイルを削除 : " + bk_name)
		end
	end


	### for Log

	#
	# 例外が発生した旨をログ出力
	#
	def showExceptionLog(str)

		# 例外出力を一度も行っていない場合
		if @is_logged_exception == false
			# 出力
			@l.brs(5)
			@l.mputs(str)
			showExceptionLogByFixedPattern()
			@l.brs(5)
		end

		@is_logged_exception = true 
	end

	#
	# ログ出力（定型文）
	#
	def showExceptionLogByFixedPattern()
		@l.mputs(LOG_MSG_SEARCH_WORD + @search_word)
		@l.mputs(LOG_MSG_STOP_FUNC)
	end

end
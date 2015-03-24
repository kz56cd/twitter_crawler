require_relative './clock_manager'
# require '/clock_manager'

class LocalConfig

  def initConf
    
    # =========================================================================== #
    #
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # 【検索キーワードを指定して実行】
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    #
    #   - 1番目のパラメータには「検索キーワード」、
    #     2番目のパラメータは「タグ名（ファイル名に使用）」（* タグ名はユニークにしてください）、
    #     3番目のパラメータは「収集開始時刻」、
    #     4番目のパラメータは「(csv)ファイル保存場所」を設定してください。
    #     
    #       - 例): ClockManager02.new("大学入試", 
    #                                 "student", 
    #                                 ["12:00", "00:00"],
    #                                 "./data/").setClock()
    #
    #       => 「大学入試」をキーワードに抽出し、
    #          「student」という文字列がファイル名に含まれたcsvファイルを作成 / 格納する。
    #          収集は12:00と00:00に開始する。
    #
    #
    #   - 複数の検索キーワードを指定する場合は半角スペースを入れること。
    #
    #         - 例): "大阪 たこ焼き 有名"  など
    #

    # ClockManager.new("包丁 研ぎ方", 
    #              "knife", 
    #              ["10:45", "20:50"], 
    #              "./data/").setClock()

    # ClockManager.new("郵便番号 検索", 
    #              "mail", 
    #              ["10:50", "20:50"], 
    #              "./data/").setClock()

    # ClockManager.new("タートルズ", 
    #              "turtles", 
    #              ["11:10", "20:50"], 
    #              "./data/").setClock()

    # ClockManager.new("インターステラー　tars", 
    #              "inter", 
    #              ["11:10", "20:50"], 
    #              "./data/").setClock()

    # ClockManager.new("ねこあつめ　レア", 
    #              "cat", 
    #              ["14:45", "20:50"], 
    #              "./data/").setClock()

    # ClockManager.new("ニセコ　外人", 
    #              "niseko", 
    #              ["14:40", "20:50"], 
    #              "./data/").setClock()






    # ClockManager.new("谷中　商店街", 
    #              "yanaka", 
    #              ["14:35", "20:50"], 
    #              "./data/").setClock()

    # ClockManager.new("谷中　猫", 
    #                  "cat", 
    #                  ["18:50", "20:50"], 
    #                 "./data/").setClock()

    # ClockManager.new("インターステラー　フィギュア", 
    #                 "inter", 
    #                 ["11:00", "00:05"], 
    #                 "./data/").setClock()



    ClockManager.new("#にこるん ニコル", 
                     "nicole", 
                     # ["12:05", "00:05"], 
                     ["10:50", "00:05"],                      
                     "./data/").setClock()

    ClockManager.new("#ちぃぽぽ", 
                     "chiepopo", 
                     # ["13:05", "01:05"],
                     ["11:30", "00:05"], 
                     "./data/").setClock()

    ClockManager.new("タートルズ フィギュア", 
                     "turtles", 
                     # ["14:05", "02:05"],
                     ["12:30", "00:05"], 
                     "./data/").setClock()

    ClockManager.new("プリクラ", 
                     "puri", 
                     # ["15:05", "03:05"],
                     ["13:30", "00:05"], 
                     "./data/").setClock()




    # ClockManager.new("ドラえもん　名言", 
    #              "dora", 
    #              ["15:05", "03:05"], 
    #              "./data/").setClock()


    # =========================================================================== #

  end
end
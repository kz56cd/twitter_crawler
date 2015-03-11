require './clock_manager'

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

    # ClockManager.new("渋谷 カフェ 隠れ家" , "cafe").setClock()
    # ClockManager.new("ホタルイカ" , "seafood").setClock()

    # ClockManager.new("流行 ファッション 東京", 
    #                  "fashion", 
    #                  ["15:00", "20:00"]).setClock()

    # ClockManager.new("動物園 パンダ", 
    #                  "zoo", 
    #                  ["15:05", "20:05"]).setClock()
    
    # ClockManager.new("#rubykaigi", 
    #                  "ruby", 
    #                  ["15:10", "20:10"]).setClock()





    # ClockManager.new("電話 NTT 光", 
    #              "tel", 
    #              ["18:40", "20:40"], 
    #              "./data/").setClock()




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
    #              "./test/hoge/fuga/").setClock()

    ClockManager.new("インターステラー　tars", 
                 "inter", 
                 ["11:10", "20:50"], 
                 "./test/hoge/fuga/").setClock()



    # =========================================================================== #

  end
end
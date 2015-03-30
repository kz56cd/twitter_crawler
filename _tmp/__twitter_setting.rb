class TwitterSetting

  # +++++++++++++++++++++++++++++ twitter APP KEYS +++++++++++++++++++++++++++++ 
  
  YOUR_CONSUMER_KEY       = "xxxxxxxxxxxxxxxxxxxxxxxxx"
  YOUR_CONSUMER_SECRET    = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  YOUR_ACCESS_TOKEN       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  YOUR_ACCESS_SECRET      = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

  def getConsumerKey()
    return YOUR_CONSUMER_KEY
  end

  def getConsumerSecret()
    return YOUR_CONSUMER_SECRET
  end

  def getAccessToken()
    return YOUR_ACCESS_TOKEN
  end

  def getAccessSecret()
    return YOUR_ACCESS_SECRET
  end
end
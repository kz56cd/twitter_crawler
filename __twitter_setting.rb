
class TwitterSetting

  # +++++++++++++++++++++++++++++ twitter APP KEYS +++++++++++++++++++++++++++++ 

  YOUR_CONSUMER_KEY       = "*************************"
  YOUR_CONSUMER_SECRET    = "**************************************************"
  YOUR_ACCESS_TOKEN       = "**************************************************"
  YOUR_ACCESS_SECRET      = "*********************************************"

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
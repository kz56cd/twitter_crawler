require 'csv'

data = [
 ["ルーミア","かわいい","ちょおかわいい"],
 ["チルノ","かわいい","むっちょかわいい"]
]

CSV.open("bo.csv","wb") do |csv|
 data.each do |bo|
  csv << bo
 end
end
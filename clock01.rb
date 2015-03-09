require 'clockwork'
include Clockwork

every(10.seconds, 'kokoro') do
  puts "kokoro"
end

every(2.seconds, 'pyon') do
  puts "pyon"
end
thread = Thread.new do
  Thread.stop
  puts 'Child thread woke up'
end

nil until thread.status == 'sleep' # wait child to sleep
puts 'Child sleeping..'

thread.wakeup
thread.join


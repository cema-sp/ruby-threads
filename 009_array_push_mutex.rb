shared_array = Array.new
mutex = Mutex.new

10.times.map do
  Thread.new do
    1_000.times do
      mutex.lock
      shared_array << nil
      mutex.unlock
    end
  end
end.each(&:join)

puts "Array size: #{shared_array.size}"


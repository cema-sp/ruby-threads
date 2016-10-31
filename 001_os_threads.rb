100.times do
  Thread.new { sleep }
end

puts Process.pid
sleep

# run in console: `top -l1 -pid 92953 -stats pid,th`


require 'benchmark'
require 'open-uri'

URL = 'https://ya.ru/'
ITERATIONS = 60

def fetch_url(threads_count)
  threads = []
  fetches_per_thread = ITERATIONS / threads_count

  threads_count.times do
    threads << Thread.new do
      fetches_per_thread.times { open(URL) }
    end
  end

  threads.each(&:join)
end

Benchmark.bm(20) do |bm|
  [1, 2, 3, 5, 6, 10, 15, 30, 60].each do |threads_count|
    bm.report("with #{threads_count} thread") do
      fetch_url(threads_count)
    end
  end
end


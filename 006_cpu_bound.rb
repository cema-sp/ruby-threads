require 'benchmark'
require 'bigdecimal'
require 'bigdecimal/math'

DIGITS = 10_000
ITERATIONS = 24

def calculate_pi(threads_count)
  threads = []
  iterations_per_thread = ITERATIONS / threads_count

  threads_count.times do
    threads << Thread.new do
      iterations_per_thread.times { BigMath.PI(DIGITS) }
    end
  end

  threads.each(&:join)
end

Benchmark.bm(20) do |bm|
  [1, 2, 3, 4, 6, 8, 12, 24].each do |threads_count|
    bm.report("with #{threads_count} thread") { calculate_pi(threads_count) }
  end
end


require 'benchmark'
require 'prime'

primes = 1_000_000
iterations = 10

num_threads = 5
iterations_per_thread = iterations / num_threads

# warmup
Prime.each(primes) {}

Benchmark.bm(15) do |x|
  GC.start
  x.report('single-threaded') do
    iterations.times do
      Prime.each(primes) {}
    end
  end

  GC.start
  x.report('multi-threaded') do
    num_threads.times.map do
      Thread.new do
        iterations_per_thread.times do
          Prime.each(primes) {}
        end
      end
    end.each(&:join)
  end
end


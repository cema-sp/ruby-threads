# Working With Ruby Threads

This is an abstract of [Working With Ruby Threads] book.

## Threads and Processes

Processes copy memory and context while threads share memory.  
Threads have smaller overhead than processes.

Your Ruby programm is always running in a *main thread*:

```ruby
Thread.main == Thread.current
```

When the *main thread* exits, all other threads are immediately terminated and the process exits.

## Threads of Execution

Threads share an address space: context, variable and AST (code tree).

**Thread of execution** - sequential path of script instructions. One program may have several threads of execution because of conditional expressions and logical branches. Different inputs give you various threads of execution.

**!** In multi-thread environment, a number of threads of execution can be traversing their own paths, all at the same time.

## OS threads

All of major Ruby implementations map one Ruby thread to one native OS thread (see [001_os_threads.rb](001_os_threads.rb)).

> Note that Ruby uses 1 more thread for housekeeping.

All native OS threads (including ones created by Ruby) are managed by OS *thread scheduler* which could not be controlled.

In order to provide resources for all threads, *thread scheduler* performs **context switching**: it can 'pause' any thread at any time (after any **atomic** instruction execution).

*Atomic* instruction can't be divided and have to be executed entirely.

## Unsafe conditional assignment

Conditional assignment (`||=`) may be *thread-unsafe*. It is not **atomic** and roughly consists of:

```ruby
if @results.nil?
  temp = Queue.new
  @results = temp
end
```

It is good practice to avoid *lazy instantiation* in multi-thread environment (see [002_eq_or_race.rb](002_eq_or_race.rb)).

To avoid race conditions:

1. Avoid concurrent modifications
2. Protect concurrent modifications

## Thread lifecycle

### `Thread.new`

Creates a new thread with initial value and a block to yield. Returns an instance.  
**!** Thread terminates on block end or on exception inside it.

### `Thread.join`

Wait for thread to terminate.  
**!** An unhandled exception in child thread will be re-raised.

### `Thread.value`

Joins thread and returns it's value.

### `Thread.status`

Possible status values:

* `'run'` - running
* `'sleep'` - blocked on mutex / IO
* `false` - finished / killed
* `nil` - failed with an exception
* `'aborting'` - running and dying

### `Thread.stop` & `Thread.wakeup`

See [003_stop_wakeup.rb](003_stop_wakeup.rb).

### `Thread.pass`

Pass one scheduler invocation.

### `Thread#raise` & `Thread#kill`

Raises exception in child thread / kills child thread.  
**!** Should not be used.

## Concurrency & Parallelism

OS threads are always concurrent (sheduled by *threads scheduler*) but **you can't guarantee** them to run in parallel.

## GIL (Global Interpreter Lock)

**MRI** allows concurrency but prevents parallelism.

GIL - global mutex shared by all process threads.  
Every Ruby process and process fork has its own GIL.  
MRI decides on how long GIL is owned by a thread.

### Blocking IO

MRI releases GIL when thread hits *blocking IO* (HTTP reques, console IO, etc.). Therefor *blocking IO* could run in parallel.

### Reasons of GIL

1. Protect Ruby internal C code from race conditions (it is not always thread safe)
2. Protect calls to C extensions API
3. Protect developers from race conditions

**!** GIL doesn't guarantee your code will be thread-safe.  
**!** Concurrent code may be slower than one-threaded (see [004_conc_benchmark.rb](004_conc_benchmark.rb)).

### Other Ruby implementations

**JRuby** and **Rubinius** don't have GIL.  
They protect their internal code with many fine-grained locks.
JRuby doesn't support C extensions while Rubinius do.
Both implementations have less race condition protection than MRI.

## Number of threads

On **Mac OS** hard limit is ~ 2046 threads per process while on **Linux** you can spawn > 10.000.

Higher number of threads lead to higher *context switching* overhead.

You code could be:

1. IO-bound (a lot of blocking IO)
2. CPU-bound (a lot of computations)
3. Complex type (as usual)

The only way to find the right number is to measure.

### IO-bound code

It makes sense to make such code parallel.
Various Ruby implementations have similar behaviour and performance here.

There always will be a *sweet spot* between utilization and context switching
and it is important to find it (see [005_io_bound.rb](005_io_bound.rb)).

### CPU-bound code

Computations-rich code on MRI runs better on 1 thread while on other implementations on `N = CPU cores` thread (see [006_cpu_bound.rb](006_cpu_bound.rb)).

## Thread safety

Thread safe code:

* Doesn't corrupt you data (it will be safe)
* Leaves your data consistent
* Leaves semantics of your program correct

Avoid _'check-then-set'_ race conditions (see [007_check_then_set.rb](007_check_then_set.rb)).
It happens because of *context switching* after check operation (check & set is not **atomic**).

In Ruby, very few things are *guaranteed* to be thread-safe (see [008_array_push.rb](008_array_push.rb) with JRuby or Rubinius).

Operations performed on the same region of memory won't be thread-safe.

## Mutexes

**Mutex** - mutual exclusion, guarantees that no two threads enter the *critical section* of code at the same time (see [009_array_push_mutex.rb](009_array_push_mutex.rb) with JRuby or Rubinius).  
Until the owning thread unlocks the mutex, no other thread can lock it.  
All threads should share one mutex.

The guarantee comes from the OS.

*Critical section* should be selected carefuly (see [010_check_then_set_mutex.rb](010_check_then_set_mutex.rb)).

### Mutexes and memory visibility

It is good practive to use mutex to read value: `s = mutex.synchronize { order.status }`.  
The reason is due to *low-level details*: the kernel can cache in L2 cache before it's visible in memory. When one thread writes to memory, that operation may exist in cache before it's writen to main memory.

The solution here: **memory barrier** (which implemented in mutexes).

### Mutexes and parallelism

Mutexes prevents parallel execution of critical sections.  
You should make critical sections as small as possible.

### Deadlocks

**Deadlock** may occure when one thread waiting for a mutex locked by another thread waiting itself for the first one.

One of solutions here: `Mutex#try_lock` method which doesn't wait for mutex but returns `Boolean` value if succeeded or not.  
Thread may release its mutex if it can't lock another one, but here can occure **livelock** - infinite code cycling.

[Working With Ruby Threads]: http://www.jstorimer.com/products/working-with-ruby-threads "Working With Ruby Threads"


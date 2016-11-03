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

[Working With Ruby Threads]: http://www.jstorimer.com/products/working-with-ruby-threads "Working With Ruby Threads"


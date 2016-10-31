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

[Working With Ruby Threads]: http://www.jstorimer.com/products/working-with-ruby-threads "Working With Ruby Threads"


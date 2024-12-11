# Challenge Fourteen

[Challenge Fourteen](https://wiki.c2.com/?ExtremeProgrammingChallengeFourteen)
was one of the challenges to determine whether the methods of Extreme
Programming (XP) and Test Driven Design (TDD) could also be applied to
concurrency problems.

In Challenge Fourteen, Tom Cargill posited some code that had a known bug and
challenged people to expose the bug by writing unit tests. It took 2 weeks and a
test setup with 11 threads, running the test 250 times to finally expose the
bug.

Concurrency problems are notoriously hard to test for. But let's see if we can
use Alloy to model this problem and find the problem in less than 2 weeks!

## The code

Here is the code that Tom Cargill provided, modeling a concurrent queue of
finite size, implemented as a ring buffer.

If a thread ties to read from an empty queue it waits until an element is added
to the queue, and if a thread tries to write to a full queue it waits until
there is room in the queue again.

Here is the code:

```java
class BoundedBuffer {
    private Object[] buffer = new Object[4];
    private int putAt, takeAt, occupied;

    synchronized void put(Object x) throws InterruptedException {
        while (occupied == buffer.length) {
            wait();
        }
        notify();

        ++occupied;
        putAt %= buffer.length;
        buffer[putAt++] = x;
    }

    synchronized Object take() throws InterruptedException {
        while (occupied == 0) {
            wait();
        }
        notify();

        --occupied;
        takeAt %= buffer.length;
        return buffer[takeAt++];
    }
}
```

If you are an experienced Java programmer, you may be able to spot the bug
straight away. But let's go through the exercise of modeling this problem in
Alloy and see if we can find the bug without prior knowledge.

### What does this code mean?

If you are not familiar with Java and its concurrency primitives, here is a
small recap of the most important concepts:

- Every Java object implicitly has an associated mutex and condition flag
  (a "monitor" in Java parlance).
- `synchronized` makes sure that the method runs atomically: this implicitly
  acquires and releases the mutex, so that no 2 `synchronized` methods of the same
  object will execute at the same time.
- `wait()` puts the current thread to sleep and releases the mutex that
  `synchronized` implicitly holds, so that another thread can acquire it.  It is
  common to put the `wait()` inside a loop.
- `notify()` wakes up one of the waiting threads, so that it can try acquiring
  the mutex again.

## Translating to Alloy

We're going to translate this program into Alloy. First: the queue buffer.
We don't care about the values in the buffer, or exactly where they go (yet).
If we wanted to confirm that we read items from the queue in the same order
as we put them, we would model those parts as well, but for now we will ignore them
and just focus on the capacity of the buffer and how many elements there are in it.

Here is the start of the buffer:

```alloy
one sig Buffer {
  -- Give the buffer a capacity, and an occupancy level that can change over time
  // ...
}

fact {
  -- The buffer has a nonzero capacity, and starts out empty
  // ...
}
```

```admonish tip title="Exercise"
Write the state relations of the `Buffer` sig and their facts.

Remember that one of the Buffer values can change over time,
so should be declared `var`.
```

Next, the threads that will act on our buffer:

```alloy
abstract sig Thread {
}
sig Writer extends Thread {
}
sig Reader extends Thread {
}

-- True if the given thread is sleeping
-- We will use this to test our code.
pred isSleeping[t: Thread] {
  // ...
}

-- Assert that all threads are awake. This will be our
-- initialization condition later.
pred allThreadsAwake {
  no t: Thread | t.isSleeping
}
```

We need to keep track of which threads are awake and which are asleep.

```admonish tip title="Exercise"
Add a relation to keep track of which threads are awake and which
are asleep. The values of this relation can vary over time
so it should be `var`.

Tip: you could make a property mapping a `Thread` to a
`Bool`, or you could make a sig for global variables that holds a set of
`Thread`s.
```

We are now going to implement the `wait()` and `notify()` primitives:

```alloy
-- Put a single thread to sleep
pred wait[t: Thread] {
  // ...
}

-- If any threads are sleeping, wake one
pred notify {
  // ...
}

-- Testing the wait predicate
run WaitIsSatisfiable { all t: Thread | t.wait }

check TestWait {
  -- After we call wait on a thread, it should be asleep the next tick
  all t: Thread | t.wait => after t.isSleeping
}

-- Testing the notify predicate
run NotifyIsSatisfiable { notify }

check TestNotify {
  -- After calling notify...
  notify => {
    -- All threads that are still sleeping were at least sleeping before notify
    -- was called.
    all t: Thread | (after t.isSleeping) => t.isSleeping

    -- If there are any threads, then at least one of them is awake.
    some Thread => after some t: Thread | not t.isSleeping
  }
}
```

We could have made the contents of `allThreadsAwake`, which initializes all
threads to be awake, a global `fact`. If we did that, we would have had to put
in additional effort to have our tests for `wait` and `notify` start go through
a number of transitions in order to get interesting configurations of asleep and
awake threads.

Instead, we define `allThreadsAwake` as a separate initialization predicate
that we only call if we run the model "for real". By explicitly keeping
thread states out of the tests for `wait` and `notify` their behavior
gets explored in all possible thread configurations without us having
to do anything else.

```admonish tip title="Exercise"
Implement the predicates above. They will involve a
time step, so you will prime a variable (`myvar'`) to update the value of some
relation. Use the provided commands to check your implementation. Did you
see any unexpected behavior? (Remember that if you don't constrain the
next state of a variable, the analyzer is allowed to pick any value!)

To check your implementations, first execute the `run` command to make sure
your command does something, then run the `check` command it doesn't do
something wrong.
```

## What do we want to check?

We are now going to model the `put` and `take` methods. Here is the skeleton:

```alloy
-- Add to the buffer's occupancy if it is not full yet, otherwise sleep.
pred put[w: Writer] {
  (Buffer.occupied = Buffer.capacity) implies {
    // ...
  } else {
    // ...
  }
}

-- Reduce one from the buffer's occupancy if it is nonempty, otherwise sleep
pred take[r: Reader] {
  (Buffer.occupied = 0) implies {
    // ...
  } else {
    // ...
  }
}

-- Call put or take as appropriate given a Thread
pred stepThread[t: Thread] {
  t in Writer => put[t]
  t in Reader => take[t]
}

-- Take an arbitrary awake thread, and make it take a step
pred stepAnyThread {
  (some t: Thread | not t.isSleeping) implies {
    some t: not t.isSleeping => stepThread[t]
  } else {
    -- If no threads are awake no progress can be made anymore.
    -- We need an explicit frame condition to say that in the next state all
    -- threads are still sleeping and also our buffer hasn't changed.
    after all t: Thread | t.isSleeping

    -- If you picked a different variable name here you need to change this
    Buffer.occupied' = Buffer.occupied
  }
}
```

Fortunately, the behavior of the Java functions is constrained by
the fact that the methods are `synchronized` and therefore execute in one
step. The `while` loop is only there to wait for the moment that the
function is allowed to execute, and when it does it executes atomically.
That means our predicates can be straightforward: we don't have to deal
with modeling the fact that the operations of a `Reader` or `Writer` could be
interrupted halfway through.

We can ignore the `while` loop; as long as we keep calling our predicates `put`
and `take` infinitely in a loop, we can say that the method either executes if
it can, or doesn't if it cannot. That behavior will be equivalent to a Java
program running those methods in a loop.

(In a future chapter, we will look at some processes that don't execute in a
single indivisible step, which need some more bookkeeping.)

```admonish tip title="Exercise"
Implement the `put` and `take` predicates.

Watch out for the integer addition! You need to write `plus[x, y]` (or
`x.plus[y]`), because `x + y` means set union, not addition!
```

## Finding the bug

We have now implemented everything! It's time to see if we can find the bug.

First, let's see if we can generate some interesting traces to see if
everything works. We'll put the entire setup of our spec into a `pred` so
that we can first `run` it, and then re-use it in a `check`.

```alloy
pred TraceSomeThreads {
  -- Have both types of threads
  some Reader
  some Writer

  -- All threads start out awake
  allThreadsAwake

  -- At every time step, exactly one thread makes progress
  always stepAnyThread
}
run TraceSomeThreads
```

If that worked, we are now ready to go check for the bug:

```alloy
check FindTheBug {
  TraceSomeThreads => {
    -- Write some invariants that we want this system to satisfy.
    always // ...
  }
}
```

```admonish tip title="Exercise"
Write one or more invariants in the `check` block to make sure our
system satisfies those invariants at every point in time, then run Alloy to see
if it satisfies them. If you're unsure about what to check for, consider this:
what do we definitely *not* want to happen in a system with multiple threads?
```

In our case, the counterexample took 8 time steps to surface a violation of the
invariant. It involves 2 readers and 1 writer.

```admonish tip title="Exercise"
What happened? Step throug the counterexample, observe the state
changes at every step, and describe what happened. You can play a little with
the visualizer settings to make it easier to read.
```

## Fixing the bug

Now that we have found the bug, the next question is how to fix it. Maybe you
have a good idea, or you know the pattern already.

It turns out that Java objects also have another method to wake threads:

```
public void notifyAll()
    Wakes up all threads that are waiting on this object's monitor.
```

```alloy
-- Wake all threads that are sleeping
pred notifyAll {
  // ...
}
```

```admonish tip title="Exercise"
Implement `notifyAll`, then update the code to use the new predicate, and
confirm that it fixes the bug (or at least, that the bug doesn't surface in 10
time steps and with however many objects you checked!).

Did you need to change all occurrences of `notify`, or can you get away with
just changing one? What would you do in practice?
```

# Our solution

```alloy
-- Threads

abstract sig Thread { }
sig Writer extends Thread { }
sig Reader extends Thread { }

one sig G {
  var awake: set Thread,
}

fact {
  -- All threads start out awake
  G.awake = Thread
}

-- Put a single thread to sleep
pred wait[t: Thread] {
  G.awake' = G.awake - t
}

-- Wake up an arbitrary thread
pred notify {
  some suspended implies {
    some t: suspended | G.awake' = G.awake + t
  } else {
    unchanged[G.awake]
  }
}

pred notifyAll {
  G.awake' = Thread
}

-- All sleeping threads
fun suspended: set Thread {
  Thread - G.awake
}

-- Buffer stuff

one sig Buffer {
  capacity: Int,
  var occupied: Int,
}

fact {
  -- Capacity is not empty
  Buffer.capacity > 0
  -- Buffer starts out empty
  Buffer.occupied = 0
}

-- Macro for frame conditions
let unchanged[r] { ((r) = (r)') } // mind the parentheses

-- Actual thread code

/*
    synchronized
    void put(Object x) throws InterruptedException {
      while( occupied == buffer.length )
        wait();
      notify();
      ++occupied;
      putAt %= buffer.length;
      buffer[putAt++] = x;
    }
*/

-- This writer doesn't need a program counter, since the whole routine completes in one step or
-- is retried in one step. Readers and writers also always run forever like this.
pred stepWriter[w: Writer] {
  (Buffer.occupied = Buffer.capacity) implies {
    wait[w]
    unchanged[Buffer.occupied]
  } else {
    notify
    Buffer.occupied' = plus[Buffer.occupied, 1]
  }
}

/*
    synchronized
    Object take() throws InterruptedException {
      while( occupied == 0 )
        wait();
      notify();
      --occupied;
      takeAt %= buffer.length;
      return buffer[takeAt++];
    }
*/

-- This process doesn't need a program counter, since the whole routine completes in one step or
-- is retried in one step. Readers and writers also always run forever like this.
pred stepReader[r: Reader] {
  (Buffer.occupied = 0) implies {
    wait[r]
    unchanged[Buffer.occupied]
  } else {
    notify
    Buffer.occupied' = minus[Buffer.occupied, 1]
  }
}

pred stepThread[t: Thread] {
  t in Writer => stepWriter[t]
  t in Reader => stepReader[t]
}

pred stepAnyThread {
  some G.awake implies { some t: G.awake | stepThread[t] } else {
    -- We need to frame here since the stepXxx predicates can't do it
    unchanged[G.awake]
    unchanged[Buffer.occupied]
  }
}

-- Just generate some interesting traces
run {
  always stepAnyThread
  some Reader
  some Writer
}

-- Check for no deadlock
check {
  {
    always stepAnyThread
    some Reader
    some Writer
  } => {
    always some G.awake
  }
} for 5
```
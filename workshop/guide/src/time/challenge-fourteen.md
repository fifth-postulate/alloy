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
Alloy and see if we can find the bug that way.

### What does this code mean?

If you are not familiar with Java and its concurrency primitives, here is a
small recap of the most important concepts:

- Every Java object implicitly has an associated mutex and condition flag.
- `synchronized` makes sure that the method runs atomically: this implicitly
  acquires and releases the mutex, so that no 2 `synchronized` methods of the same
  object will execute at the same time.
- `wait()` puts the current thread to sleep and releases the mutex that
  `synchronized` implicitly holds, so that another thread can acquire it.  It is
  common to put the `wait()` inside a loop.
- `notify()` wakes up one of the waiting threads, so that it can try acquiring
  the mutex again.

## Translating to Alloy

**EXERCISE**: write the part of the model that says XYZ.

## What do we want to check?

**EXERCISE**: express the condition.

## Fixing the bug

**EXERCISE**: what happened? How would we fix it?


## Our solution
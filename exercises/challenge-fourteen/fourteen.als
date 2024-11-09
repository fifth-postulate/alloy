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

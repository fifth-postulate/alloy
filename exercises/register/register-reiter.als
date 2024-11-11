sig Incrementor {
  var tmp: lone Int,
  -- In this version of the model, "pc" (program counter) indicates
  -- the statement we *did* just execute. Doing that makes the frame conditions
  -- below easier to read.
  var pc: Pc,
}


enum Pc { Begin, Read, Inc, Write }

one sig Register {
  var value: Int
}

fact {
  -- Register starts out at 0
  Register.value = 0

  -- Initially no temp values and every Incrementor starts at Begin
  all i: Incrementor {
    i.pc = Begin
    no i.tmp
  }
}

fact {
  -- Reiter frames (express the reasons vars can change in terms of a step of pc)
  always {
    unchanged[Register.value] or one i: Incrementor | i.didStep[Write]
    all i: Incrementor | unchanged[i.tmp] or i.didStep[Read] or i.didStep[Inc]
    (one i: Incrementor | i.pc' != i.pc) or no alive
  }
}

pred didStep[i: Incrementor, s: Pc] {
  i.pc != s and i.pc' = s
}

pred stepIncrementor[i: Incrementor] {
  (i.pc = Begin) => {
    i.tmp' = Register.value
    i.pc' = Read
  }
  (i.pc = Read) => {
    i.tmp' = plus[i.tmp, 1]
    i.pc' = Inc
  }
  (i.pc = Inc) => {
    Register.value' = i.tmp
    i.pc' = Write
  }
}

fun alive: set Incrementor {
  Incrementor - pc.Write
}

fact {
  always {
    some alive implies { 
      one i: alive | stepIncrementor[i] 
    } else {
      pc' = pc
    }
  }
}

-- Macro for frame conditions
let unchanged[r] { ((r) = (r)') } // mind the parentheses

run {
    #Incrementor > 1
    eventually Incrementor.pc = Read
    eventually Incrementor.pc = Write
}

check {
  {
    #Incrementor > 1
  } => {  
    eventually no alive => Register.value = #Incrementor
  }
} 

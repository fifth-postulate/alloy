enum Pc { Read, Inc, Write }

one sig Register {
  var value: Int
}

fact {
  -- Register starts out at 0
  Register.value = 0
}



/*
function incrementor() {
  value += 1;
}

// If the increment is not atomic behaves like

1: var tmp = value;
2: tmp = tmp + 1;
3: value = tmp;

*/

sig Incrementor {
  var tmp: lone Int,
  var pc: lone Pc,
}

fact {
  -- We don't have a tmp var when we start out
  no Incrementor.tmp
  -- All program counters start out at 1
  all i: Incrementor | i.pc = Read
}

pred stepIncrementor[i: Incrementor] {
  (i.pc = Read) => {
    Register.value' = Register.value
    i.tmp' = Register.value
    i.pc' = Inc
  }
  (i.pc = Inc) => {
    Register.value' = Register.value
    i.tmp' = plus[i.tmp, 1]
    i.pc' = Write
  }
  (i.pc = Write) => {
    Register.value' = i.tmp
    i.tmp' = i.tmp
    no i.pc'
  }
  no i.pc => {
    Register.value' = Register.value
    i.tmp' = i.tmp
    i.pc' = i.pc
  }
}

fun alive: set Incrementor {
  univ.~pc
}

fact {
  always (some alive implies {
    some i: alive {
      stepIncrementor[i] 
      -- Everything else didn't change
      all j: Incrementor | i != j => unchanged[j.tmp] and unchanged[j.pc]
    }
  } else {
    unchanged[Register.value]
    unchanged[tmp]
    unchanged[pc]
  })
}

-- Macro for frame conditions
let unchanged[r] { ((r) = (r)') } // mind the parentheses


run {} for 5..5 steps

run {
  #Incrementor > 1
  eventually no Incrementor.pc
}

check {
  {
    #Incrementor > 1
  } => {  
    eventually no Incrementor.pc => Register.value = #Incrementor
  }
}

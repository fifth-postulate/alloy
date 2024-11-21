# First Steps

We will take Alloy for a spin. We don't expect you to understand everything that
is going one. We just want you to make sure that your
[installation](../appendix/installation.md) of Alloy is
working, get a feel for what Alloy is capable of and expose you to some Alloy
code.

Start Alloy and paste the following code into the editor pane. The code is
taken from the [example models](/workshop/guide/src/appendix/resources.md).
It is stripped from all of its comments because we would like to focus on the
Alloy Analyzer.

```alloy
open util/ordering[State] as ord

abstract sig Object { eats: set Object }
one sig Farmer, Fox, Chicken, Grain extends Object {}

fact eating { eats = Fox->Chicken + Chicken->Grain }

sig State {
   near: set Object,
   far: set Object
}

fact initialState {
   let s0 = ord/first |
     s0.near = Object && no s0.far
}

pred crossRiver [from, from", to, to": set Object] {
   // either the Farmer takes no items
   (from" = from - Farmer - from".eats and
    to" = to + Farmer) or
    // or the Farmer takes one item
    (one x : from - Farmer | {
       from" = from - Farmer - x - from".eats
       to" = to + Farmer + x })
}

fact stateTransition {
  all s: State, s": ord/next[s] {
    Farmer in s.near =>
      crossRiver[s.near, s".near, s.far, s".far] else
      crossRiver[s.far, s".far, s.near, s".near]
  }
}

pred solvePuzzle {
     ord/last.far = Object
}

run solvePuzzle for 8 State expect 1

assert NoQuantumObjects {
   no s : State | some x : Object | x in s.near and x in s.far
}

check NoQuantumObjects for 8 State expect 0
```

The above code models a
[river crossing problem](https://en.wikipedia.org/wiki/River_crossing_puzzle).

In the problem there are a _farmer_, a _fox_, a _chicken_ and a bag of _grain_.
The all want to cross a river and only the farmer can row the tiny boat. The
boat is so small that besides the farmer it can only hold one other participant,
i.e. the fox, the chicken or the grain.

The nature of the animals is that the fox would like to eat the chicken, and
would certainly do so if the farmer isn't present. Likewise, the chicken would
help itself to the grain if the farmer wouldn't stop it.

How can the entire party cross the river, without any member of the party being
eaten?

**EXERCISE**: Solve this particular instance of a river crossing problem.

With some time, one could solve the above problem by hand. Some of you would
even enjoy the proces of working out a solution.

Let's see how the Alloy Analyzer could help us.

In the ribbon of icons you can find a cloud with a lightning bolt labelled
"Execute". When you pressed the trace pane mentions something along the lines
of 

```plain
Executing "Run solvePuzzle for 8 State expect 1"
   Solver=sat4j Bitwidth=4 MaxSeq=4 SkolemDepth=1 Symmetry=OFF Mode=batch
   1137 vars. 80 primary vars. 3011 clauses. 58ms.
   instance found. Predicate is consistent, as expected. 15ms.
```

Notice that the instance is a link. Following it opens a window displaying a
dots and boxes diagram akin to the following:

![A solution to the river crossing problem?!](https://fifth-postulate.nl/image/river-crossing-solution.dot.png)

There is certainly something going on, but how this is a solution isn't clear.
In the window that is showing the diagram, in the ribbon you can find a
projection button.
Currently the projection is set to "None".

Change the projection to project over "State". Now it show a single State.

![The first state of a solution to the river crossing problem](https://fifth-postulate.nl/image/river-crossing-solution.state0.dot.png)

The controls allow you to transition to the next State, which helps in
visualizing how the farmer must work hard to let everybody safely cross the 
river.

![A next state after the first of a solution to the river crossing problem](https://fifth-postulate.nl/image/river-crossing-solution.state1.dot.png)

The can deduct that in this solution the farmer first brings the chicken to the
far side.

Stepping through all states, you can convince yourself that this is a proper
solution.

Notice that we never coded this solution, it was found by the Alloy Analyzer.
If you want to know more how this is achieved, you are in the right workshop!

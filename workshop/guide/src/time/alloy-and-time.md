# Alloy and Time

Since version 6, Alloy can also express state evolving over time.

Explain:

- `var`
- `x` and `x'`
- Regular `fact`s are now initialization, `always` facts represent invariants
- `always`/`eventually`

## Checking time

Run: put an `and` of what you would like to see. Check that the specification is
satisfiable.

The default scope is 10 time steps. You can change it by writing something like
`run { ... } for 10..20 steps`.

Check: put an implication to check for termination.

## The visualizer and Time

When you run a model, Alloy will find a *trace*, which is a sequence of
states that evolve over time. At the top of the visualizer, you will
see the sequence of states in the trace and you can use the arrow
buttons to step through it.

Notice that every trace ends in a loop, which indicates that it goes back to a
previous state. This is called a *lasso trace*. That means that a trace has a
*first* state, but it doesn't have a *last* state. This property makes it so that temporal
formulas are always valid; if we didn't have infinite traces, what would the
expression `x'` even refer to in the last state?

You normally don't have to worry about lassos, as long as you make sure that
your model doesn't get "stuck": if there's nothing interesting progress to make
in your model anymore, you at least have to model that the next state is equal
to the previous state, forever.

You will see that all traces

- The visualizer buttons and progression

## Frame conditions

(Trivial model here with 2 `var`s, leave out frame conditions)

**EXERCISE**: Run the above program. What happened? Why did that happen?

A light touch of frame conditions.

Frame conditions can be written in a couple of different styles. We will see
a couple of different styles later.

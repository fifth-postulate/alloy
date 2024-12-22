# Maintaining invariants in an address book application

(Introductory paragraph)

This address book maps names to some kind of address. We're not too concerned
with the specific type of address, but let's say it's an email address. So
for example, our address book will contain the entry that "Alice" has
the email address "a.krige@collective.net".

Our address book supports groups with the same data structure, so a single name
can map to multiple addresses.

Our address book also supports *aliases*, so that both "Alice" as well as
"Auntie" map the same email address. The way we'll represent our aliases is by
saying that a `Name` can map to either an `Addr` or another `Name`. So we
could have the chain `Auntie -> Alice -> a.krige@collective.net`.

```alloy
sig Name, Addr { }
sig Book {
  -- Map one name to one or more names or addresses
  addr: Name -> (Name + Addr)
}
```

A lookup means transitively following the chain of `Name`s and collect
all the addresses we can reach:

```alloy
fun lookup[b: Book, n: Name]: set Addr {
  -- Starting from n, follow 'b.addr' one or more times, and retain only the
  -- values that are Addrs
  n.^(b.addr) & Addr
}
```

We now have a powerful datastructure that can represent a lot of states,
including states we consider to be illegal. We have defined an *invariant* to
define the rules that make this data structure valid:

```alloy
pred inv[b: Book] {
  all n: Name {
    n not in n.^(b.addr)
    some (b.addr).n => some lookup[b, n]
  }
}
```

```admonish tip title="Exercise"
The invariant is described formally using the predicate `inv`. Explain in words
what the invariant says.
```

```admonish tip title="Exercise"
Generate some examples of Books that satisfy the invariant, and some examples of
Books that don't satisfy the invariant. Use the `run` command to do this.  Think
about your scope: how many of each object type do you want to see?

You probably want to use a *projection* in the visualizer to clean up
the diagram a little. You probably also want to turn on
**types and sets → Hide unconnected nodes**.
```

## Operations on the address book

We will now define operations `add` and `del` that mutate the address book. Here
are the straightforward operations we can apply to our address book:

```alloy
-- b1 is b0 with a row mapping 'n to t' added to it
pred add[b0, b1: Book, n: Name, t: Name + Addr] {
  -- Preconditions
  // ...

  -- Actual add
  b1.addr = b0.addr + (n -> t)
}

-- b1 is b0 without the row mapping 'n to t'
pred del[b0, b1: Book, n: Name, t: Name + Addr] {
  -- Preconditions
  // ...

  -- Actual deletion
  b1.addr = b0.addr - (n -> t)
}
```

```admonish tip title="Exercise"
Use `run` to generate some examples of operations. Think about
your scope again: how many elements of each type do you want?

Configure the visualizer in a way that makes most sense for you.

(Tip: for a single add or delete operation you definitely don't
need more than `exactly 2 Book`).

Are you seeing what you're expecting in all cases?
```

Depending on how you wrote your `run` command, one of the things you may have
noticed while generating examples is that you see two `Book`s that seem to have
nothing to do with each other, even if you generate for `exactly 2 Book`!
Definitely, the difference between them is more than just a single `add` or
`del`. What's going on?

In the visualizer, if you click the **Txt** button to look at the values of
`$b0` and `$b1`, you may see something like this:

```
skolem $b0={Book$1}
skolem $b1={Book$1}
```

What happened is that the `add` or `del` operation tries to add an entry to the
address book that's already there. In that case, the input and output book are
the same, and so it's valid to assign the same `Book$1` to the 2 variables in the
`run` command. That leaves `Book$0` to be unconstrained, so it can have any
contents!

To prevent this, you need to state that there are no unrestricted `Book`
instances in the command. You can do that in a couple of number of ways:

* `b0 != b1 for exactly 2 Book`: if there are 2 Books and b0 and b1 are not
  the same, then all books are accounted for
* `b0 + b1 = Book`: more directly, b0 and b1 together make up the sum of all
  `Book` instances in the model.

Note that `b0` does not always point to `Book$0`; sometimes Alloy arbitrarily
picks `b1` to point to `Book$10`. You will have to look at the `$n` and `$t`
variables to see which of the Books represents the "pre" state and which
the "post" state, and what the operation was that happened.

(There are some techniques we can apply here to force Alloy's hand, but we won't
get into those just yet.)

## Preserving the invariant

We saw some examples of operations that changed our address book. Now the big
question is, are these operations *invariant-preserving*? Invariant-preserving
means that starting from a data structure in which the invariant holds and the
operation is executed, does it still hold afterwards?

To make an operation invariant-preserving we can do 2 things: change what it
does, or restrict the conditions under which it can be executed. In this case,
since our actual operations seem very trivial there's probably not a lot we can
change there. But what we can do is find out how we need to restrict the
inputs of `add` and `del` to make sure they are invariant-preserving.

```alloy
check AddPreservesInvariants {
  // ...
} for 3 but exactly 2 Book
```

```admonish tip title="Exercise"
Update the `AddPreservesInvariants` statement above to check if `add` is
invariant-preserving in its current definition. Tip: your expression should
be inside an `all`, and it should contain an `=>`.

Does the analyzer find any counter-examples?  Add the necessary preconditions to
the `add` predicate to make it invariant-preserving.
```

Alloy is very flexible in allowing you to write any complex condition you want.
You can translate the invariant pretty straightforwardly into preconditions for
`add`.


```admonish tip title="Exercise"
For a bit more realism, only write preconditions that you could implement
reasonably efficiently in a real programming language in practice.
```

-----


Now let's do the same for `del` as well!

```alloy
check DelPreservesInvariants {
  // ...
} for 3 but exactly 2 Book
```

```admonish tip title="Exercise"
Do the same for `DelPreservesInvariants`.
```

# Our solution
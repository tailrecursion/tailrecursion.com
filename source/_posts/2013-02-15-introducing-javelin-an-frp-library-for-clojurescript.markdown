---
layout: post
title: "Introducing Javelin: an FRP library for ClojureScript"
date: 2013-02-15 09:00
comments: true
categories: [javelin, clojure, clojurescript, FRP]
authors: [alan, micha]
---

<img style="padding:15px;" align="right" src="https://dl.dropbox.com/u/12379861/javelin.png">

We are pleased to announce today the release of
[Javelin](https://github.com/tailrecursion/javelin), a new
[Functional Reactive Programming](http://en.wikipedia.org/wiki/Functional_reactive_programming)
(FRP) library for
[ClojureScript](https://github.com/clojure/clojurescript).

* [Javelin README](https://github.com/tailrecursion/javelin/blob/master/README.md) - short examples and operational overview
* [tailrecursion/javelin-demos](https://github.com/tailrecursion/javelin-demos) - growing set of more involved examples
* [see the demos running online](http://tailrecursion.com/~alan/javelin-demos/)

Javelin takes a hybrid approach to FRP that draws inspiration from the
spreadsheet model, various existing FRP libraries and frameworks,
Clojure, and some of our own observations about the nature of
reactivity in web applications.

While Javelin is a work in progress, our experience using it so far
has been extremely positive.  We're confident in the Javelin model and
welcome your feedback, bug reports, and pull requests as we work to
prepare Javelin for our own production use.

If you're curious about what makes Javelin unique, read on.  Through a
series of examples, we think we can show you.

## Programming was Easy

Consider a program that must determine and print the length of a
hard-coded string.  Such a program is easy to write in Clojure:

```clojure Example 1
(let [text "abracadabra"
      length (count text)]
  (printf "Length: %s" length))
```

What aspects of the requirement and Clojure's semantics contributed to
the ease with which we were able to write the program, and the ease
with which we can now understand it?

First, our input was hard-coded, which meant we only had to write the
program for a particular input case - that of the string
`"abracadabra"`, which is known to be a string and known to be countable.

Second, between the fact that the input was hard-coded and that
Clojure's values are immutable, it can be said that the above program
was only ever in one "state".  In fact, all programs are only ever in
one state, but a programming model's semantics contribute to how easy
or hard it is to determine exactly what that state is, and from which
places or values in the program it is ultimately derived.

Clojure's preference for immutability makes it quite clear that the
state of the program at every point in execution follows from the
input string.

Finally, syntactically, the program was easy to write and understand
because each line of the program corresponds to a step in the
requirement, and the steps are implemented top-down in dependency
order.  It was obvious to us that we needed input in order to count,
and a count in order to print.  We specified that order to Clojure and
Clojure's evaluation semantics ensured our instructions were followed
in the right order.

A parameterized version of Example 1 is easy to infer, and retains
many favorable qualities.  What we've lost are all assurances about
our input that we may regain, to an extent, with precondition.

```clojure Example 2
(defn count-string [text]
  {:pre [(string? text)]}
  (let [length (count text)]
    (printf "Length: %s" length)))
```

We hope these examples demonstrate that programming ease has to do
with the nature of requirements and the applicability of a language's
affordances to satisfying them.

## Programming Got Hard

Not all requirements succomb so easily to Clojure's native semantics.  Many of these difficult requirements  




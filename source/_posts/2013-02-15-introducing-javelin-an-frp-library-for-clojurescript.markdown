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

## Back When Programming was Easy...

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
`"abracadabra"`.

Second, between the fact that the input was hard-coded and that
Clojure's values are immutable, it can be said that the above program
was only ever in one "state".  In fact, all programs are only ever in
one state at a particular point in time, but a programming model's
semantics contribute to how easy or hard it is to determine exactly
what that state is, and from which places in the program it is
ultimately derived.

In the above program, Clojure's penchant for immutability helps us
understand the state of the program, because it's evident that 

Finally, 

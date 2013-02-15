---
layout: post
title: "Introducing Javelin: an FRP library for ClojureScript"
date: 2013-02-15 09:00
comments: true
categories: [javelin, clojure, clojurescript, FRP]
authors: [alan, micha]
---

<img style="padding:15px;" align="right" src="https://dl.dropbox.com/u/12379861/javelin.png">

We are proud to announce today the release of
[Javelin](https://github.com/tailrecursion/javelin), a new
[ClojureScript](https://github.com/clojure/clojurescript) library for
[Functional Reactive
Programming](http://en.wikipedia.org/wiki/Functional_reactive_programming)
(FRP).

* [Javelin README](https://github.com/tailrecursion/javelin/blob/master/README.md) - short examples and operational overview
* [tailrecursion/javelin-demos](https://github.com/tailrecursion/javelin-demos) - growing set of more involved examples
* [see the demos running online](http://tailrecursion.com/~alan/javelin-demos/)

We are confident in the model and semantics Javelin provides, but have
yet to use it in production ourselves.  As such, we thank you in
advance for any bug reports, feedback, or fixes.

In the rest of this post, we hope to illuminate the problems that
motivated the creation of Javelin, compare Javelin to the Classic FRP
and spreadsheet models, and describe the kinds of application designs
that Javelin was built to support.

## Reactive Modeling in Browsers is Hard

The semantics of the JavaScript language pose unique challenges to
those who wish to develop large, _reactive_ applications.  We define a
reactive application as one that must continually and dynamically
accept and respond consistently to events (and patterns of events)
from multiple sources.

While the browser event model and JavaScript's asynchronous semantics
are conducive to reactive programming in the small, the combination of
at least browser implementation nuances and JavaScript's lack of a
language-level synchronization primitive has impeded the development
of a de facto library for modeling **just** the reactive aspects of
large browser-based applications.

For further exposition of the problems inherent in reactive
programming using only the machinery that JavaScript and browsers
provide, we recommend the paper [Flapjax: A Programming Language for
Ajax
Applications](http://www.cs.brown.edu/~sk/Publications/Papers/Published/mgbcgbk-flapjax/).

What have emerged to combat these problems of blossoming complexity in
reactive browser applications are frameworks.  Because most of the
ways reactive systems must react include DOM manipulation and other
kinds of IO, many frameworks that take on the reactive modeling
problem also provide their own templating and routing systems or
semantics.

We believe there is tremendous leverage in a framework when it's
applied to a problem its creators envisioned, and that in many cases,
many existing libraries provide great value.  However, we also believe
that there is higher leverage in simpler tools - tools simple enough
that they can be composed and applied to problems their creators did
not foresee.

It is this belief, and several encounters with framework-bending
problems, that led us originally to the FRP model as a possible basis
for a solution to the Large Reactive Application problem.

## FRP vs. Clojure vs. Spreadsheets vs. Javelin

FRP was originally conceived as a model for describing the flow of
data in animation software, and qualifies as a paradigm in the family
of [dataflow
programming](http://en.wikipedia.org/wiki/Dataflow_programming)
languages and models.  Since its introduction, the FRP model has been
implemented atop a variety of platforms to solve problems across a
variety of domains.  For a survey of FRP, we recommend [A Survey of
Functional Reactive
Programming](http://www.cs.rit.edu/~mtf/student-resources/20103_amsden_istudy.pdf).
For a deeper look at FRP, and how it was applied in a particular
domain - game programming - we recommend [The Yampa
Arcade](http://haskell.cs.yale.edu/wp-content/uploads/2011/01/yampa-arcade.pdf).

### Behaviors and EventStreams

The FRP model as usually described or implemented is based on two
object primitives: **Behaviors** (also known as signals) and
**EventStreams**.  Behaviors are usually defined as "time varying
values", and share many similarities with Clojure's builtin notion of
[reference type](http://clojure.org/atoms) - they always contain a
value, and that value can be observed at any time.

### Behaviors and Continuous Propagation

Behaviors differ from Clojure's reference types in that their value
may be derived from one or more constituent objects, each of which may
be either another Behavior or EventStream.  Over time, the values
these constituents represent may change, and so to may change the
value of the reliant Behavior.  If the reliant behavior is itself a
constituent, it passes its new value forward, and so on.

This dependency-order "movement" of values through graphs of FRP
primitives is the model's primary semantic, and is known as
**propagation**.  It is the guarantee of dependency-order propagation
that aligns the evaluation of FRP programs with the normal applicative
evaluation rules all programmers know well.  In any programming
language, functional or not, it is things happening in the order we
specify that allows us to constructively reason about program
behavior.  It is arguably dependency-order propagation that makes FRP
an easier way to think about reactive systems.

Dependency-order propagation is also part of what distinguishes FRP
programs from similar programs one might construct with callbacks.  In
a callback-based system, no guarantees can be made about the order
that new values propagate.  As a result, it is possible in such
systems for values to arrive at Behaviors in the wrong order, and for
a possibly incorrect new value to propagate forward.  This
circumstance is known as a **glitch**, and an important property of
any FRP implementation is that it is **glitch-free**.

### EventStreams and Discrete Propagation

So far we have discussed FRP only in terms of Behaviors, values, and
propagation.  However, FRP was originally concieved as a way to model
systems in which events can trigger propagation, whether or not they
are accompanied by a "new" value.  It is the EventStream object that
makes this possible.

EventStreams are like Behaviors in that they are identities
representing change.  Unlike Behaviors, EventStreams do not represent
a changing value - they represent the notion of "occurrence."

Consider a spreadsheet.  A spreadsheet is effectively a grid of
Behaviors.  If you click in a cell that contains the number 5, delete
it, and type the number 5 again, you will not observe anything happen.
That's because in a spreadsheet, it is the appearance of a different
value in a cell that triggers evaluation.

EventStreams are like spreadsheet cells that trigger evaluation merely
by being edited, regardless of whether or not resulting value is just
the old one again.  In a spreadsheet of EventStreams, editing a cell
with 5 to contain 5 would trigger evaluation and could result in
observable effects.

Propagation that is value-based, like a spreadsheet, is known in FRP
terms as **continuous**.  Propagation that is event-based, as in our
EventStream-based spreadsheet, is known as **discrete**.  Both types
of propagation are useful when it comes to modeling reactive systems,
but expressing that difference with two object types as in traditional
FRP may not be ideal.

### Lifting, where Behaviors and EventStreams Meet

A Behavior shares similarities with the idea of a function in that it
represents a value derived some number of inputs.  Where a function
has arguments and a return value, a Behavior has constituents and a
value.

Common to many FRP implementations is an operation for creating new
Behaviors from existing functions known as **lift**.  The **lift**
operation "raises" a regular function to Behavior level, making it a
reactive function of constituents instead of an applicative function
of arguments.

The lift operation is what makes it possible to "attach" EventStreams
to Behaviors, as an EventStream may be a constituent of a Behavior.
When an event occurs on a constituent EventStream, the function
underlying the reliant behavior is triggered, and the reliant Behavior
propagates its value forward if its value is new.

In this way any number of EventStreams and Behaviors may be combined
into new Behaviors.  New EventStreams may be derived from Behaviors by
making an EventStream of the changes in the value of a Behavior.

### The Behavior/EventStream Divide

While we admit that the ability to situationally select either
continuous or discrete propagation is a crucial capability of a
practical FRP system, we believe that exposing that choice through
two kinds of object introduces unnecessary complexity, at least in our
domain of reactive browser applications.

FRP systems that bifurcate their API in this way must maintain three
disparate categories of API function - one for working with
EventStreams, one for working with Behaviors, and one for combining
operations.  We found that many common workflows involved several
functions from each category, incurring significant cognitive load
that seemed to rival that of the kind of code FRP promises to
obsolete.

Additionally, we found that the bifurcation prevented us from making
library code of workflows that felt intuitively like they should apply
to both kinds of object.  Because the difference between the kinds of
object is a nearly language-level evaluation semantic, tools like
polymorphism are unfortunately not applicable.

### Javelin: Page State is a Behavior

One way to address the Divide, which is the way we chose with Javelin,
is to reduce the space of objects in your FRP system to just one.  We
chose Behaviors (which we call **cells**).  How did we get away with
this?  In two ways.

First: At any point in time, a given web application has exactly one
state.  In most cases, it is a very small part of this state from
which the rest is derived, especially when one accounts for the state
of the DOM.  We have come to call this "real" state "the backbone".
One job of the web application with respect to the backbone is to:

* React to changes in value of the backbone and enact further state
  change (usually in the DOM) as necessary.

For instance, it might be the responsibilty of some web-based chat
application to re-draw the contact list when one of a user's friends
signs on.  Or perhaps an item must be removed from a user's shopping
cart, as it is sold out.

The changes that the application is concerned with as it monitors the
backbone are changes in value, not the occurrence of events.  The
buddy list doesn't need to be re-drawn if all of the same buddies are
online.  The shopping cart can stay the same if all items remain
marked "in stock".

Because it is changes of the value of the backbone that should result
in action being taken, one can model the backbone as a behavior and
can consider the relationship between the backbone and the rest of the
page as that of **continuous propagation**.

Once the relationship between a page and the data it's responsible for
displaying is viewed as a relationship between Behaviors, one can rope
in all of FRP's powerful ideas for modeling order in an asynchronous
environment.  Pieces of related "change logic" can be modeled as
appropriate as separate behaviors, and their linkages clearly defined
via FRP dependency relationships.

It's worth noting that a page is *never* without a state, the same way
a Behavior or a Clojure reference type are *never* without a value.

The contact list before connecting to the server has a value: it is an
empty collection.  The shopping cart before any additions has a value:
it is also an empty collection.  Form inputs before they've been
filled all have values: empty strings.  Behaviors that depend on these
pieces of state always have a value to work with, albeit an empty one.

Second: Instead of using two kinds of object to represent the two
propagation modes, Javelin Behaviors (cells) can be toggled to
propagate either discretely or continuosly.

Another job of a web application with respect to the backbone is to:

* Collect events from the user and server and mutate the backbone or
  other state as appropriate.

"Collecting events" absolutely requires **discrete propagation**, but
Javelin encourages the immediate transformation of discretely
collected events into aggregate, continuosly propagated Behaviors upon
which other continuous behaviors may then depend.

It is through the conversion of discrete events into continuous values
strategically and as soon as possible that one may avoid the
uncertainty creep that FRP code littered with discrete elements
imposes.

## FRP the Javelin Way

Javelin is a hybrid system that incorporates ideas from spreadsheets,
FRP, and Clojure.  It is our hope that you will find Javelin easy to
pick up, use, and combine with other libraries to great effect.

## Future Plans

We were able to port a simplified version of Javelin to run on Clojure
on the JVM that supports concurrent propagation.  In the future we
hope to bring it to feature parity with the ClojureScript Javelin, and
to do the work necessary to interpret (and run backwards, in a
concurrent and event driven manner) [Prismatic
Graph](https://github.com/Prismatic/plumbing) format workflows.

---
title: Application Overview
---

<!--
 Copyright 2013 Relevance, Inc.

 The use and distribution terms for this software are covered by the
 Eclipse Public License 1.0 (http://opensource.org/licenses/eclipse-1.0)
 which can be found in the file epl-v10.html at the root of this distribution.

 By using this software in any fashion, you are agreeing to be bound by
 the terms of this license.

 You must not remove this notice, or any other, from this software.
-->

* Why use queues and isolate the black box?
* Why dataflow?
* Why are there five dataflow functions?
* Why do dataflow functions take one generic argument?

# Application Overview

This document is a high-level description of the key ideas behind
Pedestal-app. Detailed documentation of each feature will be provided as
Pedestal becomes more mature. This document, in addition to the
pedestal-app tutorial should be enough to get stated.


### Why Pedestal

Pedestal-app has two main influences: Clojure and distributed systems.

Once you have become infected by the ideas behind Clojure, ideas such
as immutability, pure functions and data-centric programming, you will
start to think differently about how to design software. Pedestal
gives developers a way to create dynamic user interfaces out of pure
functions and immutable data.

Distributed systems force us to think about how to create small pieces
of software which work as part of a larger system. It also shows us
that very complex things can be built from small decoupled
parts. Ideas from this domain can be applied to individual programs to
make them more flexible, testable, modular and extendable.

Pedestal-app is an application architecture which tries to stay true
to the key ideas of Clojure while also using ideas from distributed
systems to build complex applications which are not hard to understand
and maintain.

Another key goal of Pedestal is to provide a programming model which
allows software to be built up by adding new functions rather than
changing existing ones. The worst code we have ever seen was not
written in one sitting by one person, but was modified over a long
period of time by many different people. Smaller, focused, decoupled
functions don't often need to change.

Throughout this document, we will attempt to point out how these goals
are accomplished with Pedestal.


### Sites vs Apps

Sites have pages. Apps have screens. Pedestal-app is focused on
creating single-page applications. The web was designed for
documents. Over the past 20 years we have come up with some ingenious
ways to build applications on a platform designed for documents. Doing
this leads to a lot of incidental complexity that many of us have
gotten so used to we don't even see it as complexity. We are perfectly
happy writing HTML and making HTTP an essential part of how our
applications work.

Focusing on apps allows us to step away from the implementation
details of the web and create higher level abstractions.


### An application

At a high level, the core of a Pedestal application can be thought of
as a black box with an input and output queue.

![Abstract Application](/documentation/images/app/abstract-app.png)

Input messages are placed on the input queue and output messages can be
consumed from the output queue. All input from users or from back-end
services are conveyed to the application on the input queue. All
output, including messages to send to back-end services or data to
render on the screen are conveyed on the output queue.

All service and rendering code will be provided with some way to send
messages to or put messages on the input queue.


### Why use queues?

Queues separate application concerns from the complexity of I/O in the
browser. From the applications perspective, all input comes in as a
stream of messages and all output is placed on a queue and quickly
forgotten.

The black box above contains all of the code which determines what
this application actually does. This code controls what happens and
when it should happen. Queues are used to isolate this code from
everything else. The code inside the black box doesn't know anything
about the DOM or even that it is running in a browser. This means that
this code can be run when the DOM is not available, for example, in a
Web Worker. It can also be run on the server and tested from Clojure.

Testing this component is easy. We can send it fabricated data and
examine the output data. There are not dependencies on any web
technology.

Using queues for input and output also allows us to be flexible in
what we do with the messages on the queues. We can see when queues are
backing up and respond accordingly. We can filter data on the queue,
drop data and compact data on the queue.


### Data Model

In a Pedestal application, application state is stored in a tree. This
tree is the application's **data model**. Imagine that we are creating
a hotel reservation system. A portion of the data model may look
something like this

![Data Model](/documentation/images/app/hotel-model.png)

All data for a hotel is stored under the root node. We can represent
the path to this node as `[:hotel]`. All data for rooms is stored
under `[:hotel :rooms]` and all data for room 3 is stored under
`[:hotel :rooms 3]`.

This data model lives inside an application. The only way for the
data model to change is for a message to be sent to the
application on the input queue.

![Data Model](/documentation/images/app/abstract-app-data-model.png)

What is a message?


### Messages

Messages are data, specifically Clojure maps. Each message has a `topic`
and a `type`. The `topic` is a vector which represents a path into the
data model where the message will be applied. The `type` is a keyword
which is usually mapped to a specific function which will apply the
message to the data model.

The `topic` and `type` keys are namespaced keywords which live in the
`io.pedestal.app.messages` namespace. It is common to require this
namespace as `msg` and use the `topic` and `type` vars as a shorthand
(until we fix namespaced keywords in ClojureScript).

```clojure
(require '[io.pedestal.app.messages :as msg])
{msg/topic [:hotel :rooms 3 :guests] msg/type :append :name "Alice"}
```

In the context of a hotel reservation system, this message could mean
that we are adding "Alice" as a guest who will be staying in room 3. A
more abstract way of thinking about this is that we would like to
append the name "Alice" to a collection located at the path `[:hotel
:rooms 3 :guests]`. `:append` could possibly map to a function which
calls `conj` to add "Alice" to a list or it could add "Alice" as another
node in the tree.

![App Message](/documentation/images/app/app-message.png)


### Processing input with transform functions

Messages enter an application on the input queue and then something
happens which causes the data model to change. What happens is that
messages are taken off the queue, one at a time, and routed to a
function which will apply this message to the data model. These
functions are called `transform` functions because they are used to
transform the data model. The message `type` and `topic` are used to
route messages to transform functions.

![App With Transform](/documentation/images/app/app-with-transform.png)

A transform function takes two arguments, the old value at the topic
path and the message. It returns the new value at that path.

```clojure
(defn append-name [old-value message]
  (conj old-value (:name message))
```

This transform function could be used to process the message shown
above. It could also be used to process any message which adds a name
to a collection.

Messages are routed to transform functions. When we describe a
Pedestal application, we provide a *routing table* which controls how
this is done. The table that routes a message to this function might
look like this:

```clojure
[[:append [:hotel :rooms :* :guests] append-name]]
```

The routing table is a vector of vectors. The first matching vector
will be used. Each vector contains a type, topic and function to match
against.

```clojure
[type topic function]
```

The type my be a wildcard `:*` and the path may contain wildcards as
the example above does. The function in the first vector with a
matching type and topic will be used. For the message above this
function will be passed the old value at `[:hotel :rooms 3
:guests]`. The update performed on the data model is essentially this

```clojure
(update-in data-model [:hotel :rooms 3 :guests] append-name message)
```

### Reporting changes to the data model with emit functions

When the data model changes, something outside of the application's
behavior will want to know about it. For example, the renderer will
need to update the UI to show that Alice is now in room 3.

Emit functions are used to generate output messages which will be used
by the renderer to update the user interface. An example of one of
these messages is shown below.

```clojure
[:value [:hotel :rooms 3 :guests] ["Claire"] ["Claire" "Alice"]]
```

This message means that the value at the path `[:hotel :rooms 3
:guests]` has been changed from `["Claire"]` to `["Claire" "Alice"]`.

These messages are produced by `emit` functions. Emit functions are
called when a part of the data model which they care about
changes. Emit functions are passed a value and return a sequence of
messages like the one shown above.

![App With Emit](/documentation/images/app/app-with-emit.png)

In the diagram above, the emit function is interested in any change
which happens to the `[:hotel :rooms]` node of the tree. When we
describe our application, we can indicate this interest in a vector
like the one shown below.

```clojure
[[#{[:hotel :rooms]} rooms-emitter]]
```

This means that there is a function named `rooms-emitter`, which should
be called whenever the node at `[:hotel :rooms]` changes. The emitter
is passed the part of the tree that it cares about and returns a
vector of changes like the one shown above.

The messages returned from an emit function are placed on the
**rendering** queue where they can be consumed by a renderer.


### Derived data

So far we have seen one way to change the data model, the transform
function. This allows us to change the data model based on input from
the outside world. Most applications will have some values which
depend on other values. For example, in the hotel reservation system
we may want to ensure that a member of the hotel staff is assigned to
each occupied room to ensure the comfort of the guests (this is a nice
hotel). Each time a room is updated, we will need to ensure that a
staff member who is on duty is assigned to that room. We will also
need to do this when the status of a staff member changes.

![Derive 1](/documentation/images/app/hotel-model-derive1.png)

In the data model above, the blue area of the model might be updated
when receiving messages from the check-in system and the orange part
might be updated when receiving messages from the system where staff
sign in for work. Both of these parts of the model are updated by
transform functions.

Imagine that we have a function named `assign-staff` which takes as
input the on-duty staff and the rooms and ensures that rooms are
evenly distributed among the staff and that each room is assigned a
staff member. The function will return the new assignments value which
is a map where the keys are staff members and the values are a
collection of room numbers.

![Derive 2](/documentation/images/app/hotel-model-derive2.png)

In Pedestal, such a function would be called a `derive` function. It
derives one value in the data model from other values. There is one
output value and there can be multiple input values.

![App with Derive](/documentation/images/app/app-with-derive.png)

When we describe a Pedestal application, we provide a set of derive
functions. Each derive function is described by a set of inputs, an
output path and a function.

```clojure
#{[#{[:hotel :rooms] [:hotel :staff :on-duty]}
   [:hotel :staff :assignments]
   assign-staff]}
```


### Dataflow

We have now been introduced to three types of functions: transform,
emit and derive. Each is a pure function. transform and derive
functions produce values which change the state of part of the data
model. derive and emit functions are called when parts of the data
model, which are inputs to these functions, are changed. All of the
dependencies between functions and the data model are described in a
data structure. The application which we have been imagining is
described in the following Clojure map.

```clojure
{:transform [[:append [:hotel :rooms :* :guests] append-name]
             [:clock-in [:hotel :staff :on-duty] clock-in]]
 :derive #{[#{[:hotel :rooms] [:hotel :staff :on-duty]}
            [:hotel :staff :assignments]
            assign-staff]}
 :emit [[#{[:hotel :rooms]} rooms-emitter]]}
```

The diagram above makes it look like processing a dataflow can be a
chaotic event with lots of functions attempting to update the same
data. It is, in fact, quite orderly.

![App Pipeline](/documentation/images/app/app-pipeline.png)

First, a transform function is run. Next, each derive function is run
exactly once. The order in which the derive functions run is
determined by their dependencies. For example, in the diagram above,
`derive 2` must run after `derive 1` because `derive 2` depends on the
output of `derive 1`. Circular dependencies will be ignored and
specifying them should be avoided. After all derive functions run,
each emit function which has changed inputs will be run.

Pedestal dataflow has two other kinds of dataflow functions: `effect`
and `continue`. Effect functions are like emit functions. Instead of
producing special messages that have to do with rendering, they
produce arbitrary messages which go on the `effect` queue. In general
these messages are meant to have some effect on the outside world.

Continue functions are used to support recursion. Messages produced by
a continue function are fed back into the dataflow. Messages can
either be fed in within the same transaction or placed on the input
queue allowing the current transaction to complete.

## Rendering

## Services

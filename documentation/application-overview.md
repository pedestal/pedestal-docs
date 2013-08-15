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

# Application Overview

This document is a high-level description of the key ideas behind
pedestal-app. Detailed documentation of each feature will be provided as
Pedestal becomes more mature. This document, in addition to the
pedestal-app tutorial should be enough to get stated.


### Why Pedestal?

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
a hotel information system. A portion of the data model may look
something like this

![Data Model Tree](/documentation/images/app/hotel-model.png)

All data for a hotel is stored under the root node. We can represent
the path to this node as `[]`. All data for rooms is stored under
`[:rooms]` and all data for room 3 is stored under `[:rooms 3]`.

This data model lives inside an application. The only way for the
data model to change is for a message to be sent to the
application on the input queue.

![App with Data Model](/documentation/images/app/abstract-app-data-model.png)

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
{msg/type :add-name msg/topic [:rooms 1 :guests] :name "Alice"}
```

In the context of a hotel information system, this message could mean
that we are adding "Alice" as a guest who will be staying in room 1.

![App with Message](/documentation/images/app/app-message.png)


### Processing input with transform functions

Messages enter an application on the input queue and then something
happens which causes the data model to change. What happens is that
messages are taken off the queue, one at a time, and routed to a
function which will apply this message to the data model. These
functions are called `transform` functions because they are used to
transform the data model. The message `type` and `topic` are used to
route messages to transform functions.

![App with Transform](/documentation/images/app/app-with-transform.png)

A transform function takes two arguments, the old value at the topic
path and the message. It returns the new value at that path.

```clojure
(defn add-name [old-value message]
  ((fnil conj []) old-value (:name message)))
```

This transform function could be used to process the message shown
above. It could also be used to process any message which adds a name
to a vector.

Messages are routed to transform functions. When we describe a
Pedestal application, we provide a *routing table* which controls how
this is done. The table that routes a message to this function might
look like this:

```clojure
[[:add-name [:rooms :* :guests] add-name]]
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
function will be passed the old value at `[:rooms 1 :guests]`. The
update performed on the data model is essentially this

```clojure
(update-in data-model [:rooms 1 :guests] add-name message)
```

### Why route transform functions?

What value does the routing table provide? Messages contain all the
information that we need to find a function and update the data
model.

The main benefit of the routing table is that it lets you restrict
what operations may be performed on what parts of the data
model. Without this table, any operation could be performed anywhere
and this may not make sense. It also allows you to clearly define
which functions may be used to update the data model.


### Aside

This may not be a good enough reason to continue using the transform
routing table. A more powerful approach to updating the data model
would involve removing this table and then changing the message format
to map to Clojure's reference update semantics.

```clojure
'(update-in [:rooms 1 :guests] add-name "Alice")
;; kind of like
(send app update-in [:rooms 1 :guests] add-name "Alice")
```

This would allow for arbitrary functions to be used to update the data
model.


### Reporting changes to the data model with emit functions

When the data model changes, something outside of the application's
behavior will want to know about it. One of those things is the
renderer. We have not really discussed what a renderer is, but for now
we can think of it as something which is pulling messages off of the
output queue (which we will now call the **rendering** queue) and drawing
things on a screen based on these messages.

By default, an emitter is configured to render changes. When the
following message is placed on the input queue

```clojure
{msg/type :add-name msg/topic [:rooms 1 :guests] :name "Alice"}
```

The following messages are placed on the rendering queue

```clojure
[:node-create [] :map]
[:node-create [:rooms] :map]
[:value [:rooms] nil {1 {:guests ["Alice"]}}]
```

These three messages describe the changes which have been made to the
data model. The root node `[]` was created. Under this the node
`[:rooms]` was created and the value for rooms was changed from `nil`
to `{1 {:guests ["Alice"]}}`.

As rendering code consumes these messages, it will modify the user
interface in some way. When it receives the message 

```clojure
[:node-create [:rooms] :map]
```

it may create a box in which to display room information. When it
receives the message

```clojure
[:value [:rooms] nil {1 {:guests ["Alice"]}}]
```

it can display which guests are in which room.

There is an assumption being made here about what constitutes an
atomic value from the renderers perspective. When the value at `[:rooms]`
changes, the entire map will be sent in the update. For example,
sending this message on the input queue

```clojure
{msg/type :add-name msg/topic [:rooms 2 :guests] :name "Bob"}
```

will result in this message on the rendering queue

```clojure
[:value [:rooms] {1 {:guests ["Alice"]}} 
                 {1 {:guests ["Alice"]}, 2 {:guests ["Bob"]}}]
```

This is fine if the rendering code is happy with getting updates at
this resolution. Once there are a lot of rooms, the renderer may want
to only update the rooms which have actually changed. With these
updates, the rendering code would have to figure out what has
changed. In general, we don't want rendering code to have to think to
much. It's job is to just look pretty.

We can configure an emitter to emit changes at the resolution that we
would like. In the description of our application we could add the
following

```clojure
[[#{[:rooms :*]} (app/default-emitter)]]
```

In most cases where we need to define an emitter we only need to
change the resolution at which change is reported. To do this we can
use the default emitter in `io.pedestal.app` and provide a path which
describes which branch of the tree to emit changes for an how far down
to go to find atomic values.

With this change, the first message

```clojure
{msg/type :add-name msg/topic [:rooms 1 :guests] :name "Alice"}
```

will cause this to be emitted

```clojure
[:node-create [] :map]
[:node-create [:rooms] :map]
[:node-create [:rooms 1] :map]
[:value [:rooms 1] nil {:guests ["Alice"]}] 
```

and the second message

```clojure
{msg/type :add-name msg/topic [:rooms 2 :guests] :name "Bob"}
```

will cause this to be emitted

```clojure
[:node-create [:rooms 2] :map]
[:value [:rooms 2] nil {:guests ["Bob"]}]
```

As mentioned above, you will almost always use the default emitter but
you can write your own custom emitter function if you need to. 

![App with Emit](/documentation/images/app/app-with-emit.png)

In the diagram above, the emit function is interested in any change
which modifies the children of the `[:rooms]` node.

Emitters not only control the resolution of change that is reported
but also which changes are reported. By default, this configuration is
used

```clojure
[[#{[:*]} (app/default-emitter)]]
```

which will emit changes to the children of the root node of the
tree. By changing this to

```clojure
[[#{[:rooms :*]} (app/default-emitter)]]
```

we will only emit changes to the children of the `[:rooms]` node. This
allows us to have parts of the data model which are a valuable part of
the application's state but are not rendered.


### Derived data

So far we have seen one way to change the data model, the transform
function. This allows us to change the data model based on input from
the outside world. Most applications will have some values which
depend on other values. For example, in the hotel information system
we may want to ensure that a member of the hotel staff is assigned to
each occupied room to ensure the comfort of the guests (this is a nice
hotel). Each time a room is updated, we will need to ensure that a
staff member who is on duty is assigned to that room. We will also
need to do this when the status of a staff member changes.

![Data Model Derive 1](/documentation/images/app/hotel-model-derive1.png)

In the data model above, the blue area of the model might be updated
when receiving messages from the check-in system. Messages like this:


```clojure
{msg/type :add-name msg/topic [:rooms 1 :guests] :name "Alice"}
```

The orange part might be updated when receiving messages from the
system where staff sign in for work. Messages like this:

```clojure
{msg/type :sign-in msg/topic [:staff :on-duty] :name "Ann"}
```

Both of these parts of the model are updated by transform
functions. The `sign-in` transform function is shown below.

```clojure
(defn sign-in [old-value message]
  (assoc old-value (:name message) {:checkin (js/Date.)}))
```

The transform routing table would now look like this:

```clojure
[[:add-name [:rooms :* :guests] add-name]
 [:sign-in [:staff :on-duty] sign-in]]
```

We can now create a function which takes rooms and on-duty staff and
returns a new map of staff assignments.

```clojure    
(defn assign-rooms [_ {:keys [rooms staff]}]
  (let [s (sort (keys staff))
        r (sort (keys rooms))]
    (reduce (fn [a [k v]]
              (update-in a [k] (fnil conj #{}) v))
            {}
            (map #(vector %1 %2) (cycle s) r))))
```

In Pedestal, such a function would be called a `derive` function. It
derives one value in the data model from other values. There is one
output value and there can be multiple input values. 

![Data Model Derive 2](/documentation/images/app/hotel-model-derive2.png)
 
Derive functions update a location in the data model. A derive
function takes two arguments: the old value at the location which is
being updated and its inputs. In the example above the old value is
ignored and the inputs are passed as a map which contains `rooms` and
`staff` keys. The return value is a map where the keys are staff
members and the values are a set of room numbers that this staff
member is to look after.

![App with Derive](/documentation/images/app/app-with-derive.png)

When we describe a Pedestal application, we provide a set of derive
functions. Each derive function is described by a set of inputs, an
output path and a function.

```clojure
#{[#{[:rooms] [:staff :on-duty]} 
   [:staff :assignments]
   assign-rooms]}
```

This will pass a map for the inputs but it is not the map we want. The
passed map will contain a complete report of what has changed. To get
a map with only the inputs we can use this instead.

```clojure
#{[#{[:rooms] [:staff :on-duty]}
   [:staff :assignments]
   assign-rooms
   :map]}
```

This will give us a map of inputs but the keys will be `[:rooms]` and
`[:staff :on-duty]`. That is not ideal. We can use a map to specify
inputs which allows us to define the keys that will be used.

```clojure
#{[{[:rooms] :rooms [:staff :on-duty] :staff}
   [:staff :assignments]
   assign-rooms
   :map]}
```


### Dataflow

We have now been introduced to three types of functions: transform,
emit and derive. Each is a pure function. `transform` and `derive`
functions produce values which change the state of part of the data
model. `derive` and `emit` functions are called when parts of the data
model, which are inputs to these functions, are changed. All of the
dependencies between functions and the data model are described in a
data structure. The application which we have been imagining is
described in the following Clojure map.

```clojure
  {:version 2
   
   :transform [[:add-name [:rooms :* :guests] add-name]
               [:sign-in [:staff :on-duty] sign-in]]
   
   :derive #{[{[:rooms] :rooms [:staff :on-duty] :staff}
              [:staff :assignments]
              assign-rooms
              :map]}
   
   :emit [[#{[:rooms :*]
             [:staff :assignments :*]} (app/default-emitter)]]}
```

The `:version` key is used to indicate the version of the dataflow
description which is being used. Even though there is one dataflow
engine, the format for describing connections between things may
change. The old format `:version 1` can still be used and it will
transformed to work with the new engine.

We have already seen the `:transform` routing table and the `:derive`
configuration shown above.

For the `:emit` configuration...

The diagram above makes it look like processing a dataflow can be a
chaotic event with lots of functions attempting to update the same
data. It is, in fact, quite orderly.

![Dataflow and Time](/documentation/images/app/app-pipeline.png)

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

...

## Services

...

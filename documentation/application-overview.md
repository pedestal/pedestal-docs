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
pedestal-app becomes more mature. This document, in addition to the
pedestal-app [tutorial](https://github.com/pedestal/app-tutorial/wiki) 
should be enough to get started.


### Why Pedestal for applications?

Pedestal-app provides a clean architecture for creating large,
interactive, single-page applications in the browser.

Creating large single-page applications is hard for several reasons

* lots of interdependent state
* views must be kept in sync with state
* the DOM is bad place to keep application state
* events and callbacks can easily lead to a hairball
* testing is essential and yet difficult

For large applications, these things are difficult to deal with even
when a user interface only has to respond to inputs from a single
user. The problem is compounded when we add interactivity. An
application can now receive inputs from multiple sources. Change
becomes constant and efficiently keeping everything in sync is
difficult. Even more important, we must do this in a way that we
understand both now and in the future.

Existing client-side frameworks may help with one small part of this
problem and in some cases can be used along side Pedestal. Most
approaches to managing state involve object oriented techniques which
lead to unnecessarily confusing abstractions and webs of
interconnected mutable objects.

Pedestal's approach is to control this complexity by going after the
root of the problem: change. Because data is immutable, we can
actually know about change. Pedestal allows us to track fine-grained
changes to our application's information model while allowing
transactions over the whole model. Pedestal uses simpler tools to
solve problems which prevents the introduction of incidental
complexity. Tools such as data, functions and queues.

Pedestal also thinks about an application as a system of
interconnected components rather than a single monolithic
application. Separating parts and concerns is critical in keeping
complexity under control. In Pedestal you will see things like queues
and messages used as if we were creating a distributed system. This
kind of design allows us to build applications which are flexible,
testable and extendable.


### Sites vs Apps

Pedestal-app is focused on creating single-page applications. The web
was designed for documents. Over the past 20 years we have come up
with some ingenious ways to build applications on a platform designed
for documents. Doing this leads to a lot of incidental complexity that
many of us have gotten so used to we don't even see it as
complexity. We are perfectly happy writing HTML and making HTTP an
essential part of how our applications work.

Focusing on apps allows us to step away from the implementation
details of the web and create higher level abstractions.


### An application

At a high level, the core of a Pedestal application can be thought of
as a black box with an input and output queue. The input queue conveys
messages which transform state (transform messages) to the application
and the output queue conveys messages which transform the view or can
effect the outside world.

![An Application](/documentation/images/app/high-level-app.png)

All input from a view or from back-end services is sent to the
application as a transform message on the input queue. Messages which
transform the UI are consumed by a renderer which will modify the view
and add event handlers which convert events to transform messages.

In the diagram above, the view could be the DOM.


### Why use queues?

Queues separate application concerns. In Pedestal, they eliminate the
direct connection between callback functions which are triggered by
events and all of the logic which deals with state transitions. In
general, queues separate application concerns from the complexity of
I/O in the browser. From the application's perspective, all input
comes in as a stream of messages and all output is placed on a queue
and quickly forgotten.

The black box above contains all of the logic which determines what
this application actually does. The logic inside the black box doesn't
know anything about the DOM or even that it is running in a
browser. This means that it can be run when the DOM is not available,
for example, in a Web Worker. It can also be run on the server and
tested from Clojure.

Testing this logic is now easy. We can send it fabricated data and
examine the output data. There are no dependencies on any web
technology.

Using queues for input and output also allows us to be flexible in
what we do with the messages on the queues. We can see when queues are
backing up and respond accordingly. Messages on a queue can be
filtered, dropped or merged.


### Information Model

In a Pedestal application, application state is stored in a tree. This
tree is the application's **information model**. Imagine that we are
creating a hotel information system. A portion of the information
model may look something like this

![Data Model Tree](/documentation/images/app/hotel-model.png)

All data for a hotel is stored under the root node. We can represent
the path to this node as `[]`. All data for rooms is stored under
`[:rooms]` and all data for room 3 is stored under `[:rooms 3]`.

Changes to this information model are managed by the application. The
value of the model is immutable, so change takes the form of state
transitions which are implemented as pure functions.

![App with Information Model](/documentation/images/app/app-with-info-model.png)
 
The functions which perform these state transitions are run each time
a new transform message is delivered on the input queue.


### Transform Messages

Messages are data, specifically Clojure maps.

A transform message is any message which describes a change that the
receiver should make. Transform messages will usually have a target,
an operation to perform and some arguments.

All messages placed on the input queue are transform messages which
have a specific format. 

Each input message has a `topic` and a `type`. The `topic` is a vector
which represents a path into the information model where the message
will be applied. This is the target. The `type` is a keyword which is
usually mapped to a specific function which will apply the message to
the information model. This is the operation. An input message can
have any other data. These are the arguments.

The `topic` and `type` keys are namespaced keywords which live in the
`io.pedestal.app.messages` namespace. It is common to require this
namespace as `msg` and use the `topic` and `type` vars as a shorthand.

```clojure
(require '[io.pedestal.app.messages :as msg])
{msg/topic [:rooms 1 :guests] msg/type :add-name :name "Alice"}
```

In the context of a hotel information system, this message could mean
that we are adding "Alice" as a guest who will be staying in room 1.


### Processing input with transform functions

Transform messages enter an application on the input queue and then
something happens which causes the information model to change. What
happens is that messages are taken off the queue, one at a time, and
routed to a function which will apply this message to the information
model. These functions are called `transform` functions because they
are used to transform the model. The message `type` and `topic` are
used to route messages to transform functions.

![App with Transform](/documentation/images/app/app-with-transform.png)

A transform function takes two arguments, the old value at the target
path and the message. It returns the new value for the target
path. The transform function `add-name` is shown below.

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
will be used. Each vector contains an operation, target and function
to match against.

```clojure
[op target function]
```

The op my be a wildcard `:*` and the target may contain wildcards as
the example above does. The function in the first vector with a
matching op and target will be used. For the message above this
function will be passed the old value at `[:rooms 1 :guests]`. The
update performed on the information model is essentially this

```clojure
(update-in data-model [:rooms 1 :guests] add-name message)
```

To read a bit more about transform functions, see the [tutorial page
that introduces transforms](https://github.com/pedestal/app-tutorial/wiki/Making-a-Counter#transform-functions).


### Why route transform functions?

What value does the routing table provide? Messages contain all the
information that we need to find a function and update the information
model.

The main benefit of the routing table is that it lets you restrict
what operations may be performed on what parts of the information
model. Without this table, any operation could be performed anywhere
and this may not make sense. It also allows you to clearly define
which functions may be used to update the information model.

Pedestal is young and this feature may be removed. We are considering
changing the transform message format to

```clj
[target op & args]
```

to better match how this is applied to the data model.

```clj
(apply update-in data-model [target op arg1 arg2])
```

This change would also allow us to eliminate the use of the transform
routing table.


### Delta Detection

Transform functions make changes to the information model. The very
next thing we need to know is what has changed. pedestal-app provides
a mechanism for reporting fine-grained change to the information
model. This allows us to have the benefits of transactions on the
whole information model without forcing functions that care about
change to diff the entire data model each time it is updated.

In pedestal-app, we declare dependencies between parts of the data
model and functions which should be called only when those parts
change. Detecting deltas makes this efficient.

![App with State Deltas](/documentation/images/app/app-with-state-deltas.png)
 
In the remaining diagrams, blue arrows will represent state deltas
which are used to report change.


### Generating rendering instructions with emit functions

When the information model changes, something outside of the
application's behavior will also need to change. One of those things
is the view. We have not really discussed what a renderer is, but
for now we can think of it as something which is pulling messages off
of the output queue (which we will now call the **rendering** queue)
and modifying the view based on these messages.

These messages are also transform messages, with an operation, target
and arguments, but have a different format from the transform messages
described above which are used for input.

By default, an emitter is configured which will generate rendering
instructions when anything in the information model changes. When the
following message is placed on the input queue

```clojure
{msg/topic [:rooms 1 :guests] msg/type :add-name :name "Alice"}
```

the following messages are placed on the rendering queue

```clojure
[:node-create [] :map]
[:node-create [:rooms] :map]
[:value [:rooms] nil {1 {:guests ["Alice"]}}]
```

These three messages encode changes which should be made to the
view. The root node `[]` should be created. Under this, the node
`[:rooms]` should be created and the value for rooms should be changed
from `nil` to `{1 {:guests ["Alice"]}}`.

As a renderer consumes these messages, it will modify the view to
reflect them visibly. When it receives the message

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
atomic value from the renderer's perspective. When the value at `[:rooms]`
changes, the entire map will be sent in the update. For example,
sending this message on the input queue

```clojure
{msg/topic [:rooms 2 :guests] msg/type :add-name :name "Bob"}
```

will result in this message on the rendering queue

```clojure
[:value [:rooms] {1 {:guests ["Alice"]}} 
                 {1 {:guests ["Alice"]}, 2 {:guests ["Bob"]}}]
```

This is fine if the rendering logic is happy with getting updates at
this resolution. Once there are a lot of rooms, the renderer may want
to only update the rooms which have actually changed. With these
updates, the rendering logic would have to figure out what has
changed.

We can configure an emitter to emit instructions at the resolution that we
would like. In the description of our application we could add the
following

```clojure
[#{[:rooms :*]} (app/default-emitter)]
```

In most cases where we need to define an emitter we only need to
change the resolution at which change is reported. To do this we can
use the default emitter in `io.pedestal.app` and provide a path which
describes which branch of the tree to emit instructions for an how far
down to go to find atomic values.

With this change, the first message

```clojure
{msg/topic [:rooms 1 :guests] msg/type :add-name :name "Alice"}
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
{msg/topic [:rooms 2 :guests] msg/type :add-name :name "Bob"}
```

will cause this to be emitted

```clojure
[:node-create [:rooms 2] :map]
[:value [:rooms 2] nil {:guests ["Bob"]}]
```

As mentioned above, you will almost always use the default emitter but
you can write your own custom emitter function if you need to. 

![App with Emit](/documentation/images/app/app-with-emit.png)

In the diagram above, the emit function will be called when the state
deltas report that any of its inputs have changed.

The default emitter configuration not only controls the resolutions at
which instructions are generated but it also controls which parts of
the information model will be watched for changes.

By default, this configuration is used

```clojure
[[#{[:*]} (app/default-emitter)]]
```

which will emit change instructions when any node of the tree has
changed. By changing this to

```clojure
[[#{[:rooms :*]} (app/default-emitter)]]
```

instructions will only be emitted for the children of the `[:rooms]`
node. This allows us to have parts of the information model which do
not directly effect the view.

To read more about emitters, see the section of the app-tutorial
entitled [observing-change](https://github.com/pedestal/app-tutorial/wiki/Increment-the-Counter#observing-change).


### Derived data

So far we have seen one way to change the information model, the transform
function. This allows us to change the information model based on input from
the outside world. Most applications will have some values which
depend on other values. For example, in the hotel information system
we may want to ensure that a member of the hotel staff is assigned to
each occupied room to ensure the comfort of the guests (this is a nice
hotel). Each time a room is updated, we will need to ensure that a
staff member who is on duty is assigned to that room. We will also
need to do this when the status of a staff member changes.

![Information Model Derive 1](/documentation/images/app/hotel-model-derive1.png)

In the information model above, the blue area of the model might be updated
when receiving messages from the check-in system. Messages like this:

```clojure
{msg/topic [:rooms 1 :guests] msg/type :add-name :name "Alice"}
```

The orange part might be updated when receiving messages from the
system where staff sign in and out for work. Messages like this:

```clojure
{msg/topic [:staff :on-duty] msg/type :sign-in :name "Ann"}
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
derives one value in the information model from other values. There is one
output value and there can be multiple input values. 

![Information Model Derive 2](/documentation/images/app/hotel-model-derive2.png)
 
Derive functions update a location in the information model. A derive
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
[#{[:rooms] [:staff :on-duty]} 
 [:staff :assignments]
 assign-rooms]
```

This will pass a map for the inputs but it is not the map we want. The
passed map will contain a complete report of what has changed. To get
a map with only the inputs we can use this instead.

```clojure
[#{[:rooms] [:staff :on-duty]}
 [:staff :assignments]
 assign-rooms
 :map]
```

This will give us a map of inputs but the keys will be `[:rooms]` and
`[:staff :on-duty]`. That is not ideal. We can use a map to specify
inputs which allows us to define the keys that will be used.

```clojure
[{[:rooms] :rooms [:staff :on-duty] :staff}
 [:staff :assignments]
 assign-rooms
 :map]
```

To lean more about derive functions, see the section of the tutorial
on [derived values](https://github.com/pedestal/app-tutorial/wiki/Derived-Values).


### Continue functions

A continue function is like derive except that it does not directly
update the model. Continue functions take a single argument, the map
of inputs (the same thing as the second argument to a derive function)
and return a collection of transform messages which are processed
within the same transaction.

![App with Continue](/documentation/images/app/app-with-continue.png)

Continue functions allow for arbitrary recursion.

For an example of a use case for continue functions see the 
[app-tutorial](https://github.com/pedestal/app-tutorial/wiki/Start-a-Game#using-a-continue-function-to-set-focus-based-on-state).


### Effect functions

Effect functions are just like emit functions except that they return
a collection of messages which are meant to be sent out of an
application. These messages are usually sent to a back-end service.

Messages produced by effect functions go on a separate queue called the
*effect* queue.

For examples of using effect functions, see the section of the
app-tutorial on [simulating effects](https://github.com/pedestal/app-tutorial/wiki/Simulating-Effects).


### Possible changes to this model

It is likely that a future version of Pedestal will move emitters and
effect functions out of the core. We may also remove derive and use
continue for recursion and dataflow. The output of the core would be
the change report which is currently used internally to trigger flow.


### Dataflow

We have now been introduced to the five types of functions: transform,
emit, derive, continue and effect. Each is a pure
function. `transform` and `derive` functions produce values which
change the state of part of the information model. `derive` and `emit`
functions are called when parts of the information model, which are
inputs to these functions, are changed. All of the dependencies
between functions and the information model are described in a data
structure. The application which we have been imagining is described
in the following Clojure map.

```clojure
(require '[io.pedestal.app :as app])
(def hotel-app
  {:version 2
   
   :transform [[:add-name [:rooms :* :guests] add-name]
               [:sign-in [:staff :on-duty] sign-in]]
   
   :derive #{[{[:rooms] :rooms [:staff :on-duty] :staff}
              [:staff :assignments]
              assign-rooms
              :map]}
   
   :emit [[#{[:rooms :*]
             [:staff :assignments :*]} (app/default-emitter)]]})
```

The `:version` key is used to indicate the version of the dataflow
description which is being used. Even though there is one dataflow
engine, the format for describing connections between things may
change.

The content of the `:derive` and `:emit` sections have been described
above. For more information about configuring an application, see the
[app-tutorial](https://github.com/pedestal/app-tutorial/blob/master/tutorial-client/app/src/tutorial_client/behavior.clj).

The `io.pedestal.app` namespace contains a `build` function which
takes the above map as an argument and returns an application.

```clojure
(def app (app/build hotel-app))
```

We can then initialize an app with the `begin` function and then start
to send it messages.

```clojure
(require '[io.pedestal.app.protocols :as p])
(app/begin app)
(p/put-message (:input app) 
 {msg/topic [:rooms 1 :guests] msg/type :add-name :name "Alice"})
```


## Rendering

In each diagram above there is a box labeled *Renderer*. As mentioned
above, this part of an application is responsible for consuming
rendering instructions and making changes to the view. In Pedestal,
anything which does this is a renderer.

Pedestal provides a helper function for consuming the rendering queue
name `consume-app-model` which is located in the
`io.pedestal.app.render` namespace. This function takes an app object
and a rendering function and will call the rendering function when
there are new instructions to render.

A rendering function takes a collection of deltas and the input-queue
as arguments.

```clojure
(defn example-renderer [instructions input-queue]
  ;; modify the DOM and wire events
 )
```

With an app in hand, set this function as the renderer with

```clojure
(io.pedestal.app.render/consume-app-model app example-renderer)
```

There are many ways to handle rendering in a Pedestal
application. Pedestal does provide some library support. For more
information see the
[Rendering](https://github.com/pedestal/app-tutorial/wiki/Rendering)
section of the tutorial.


## Services

Any useful application will need to communicate with back-end
services. As mentioned above, `effect` functions can produce messages
which are sent to back-end services. Any messages which are received
from back-end services can be turned into transform functions and
placed on the input queue.

Anything which consumes messages from the effect queue and places new
messages on the input queue is considered to be a service.

Pedestal provides a function to help with consuming the effects
queue. This function is named `consume-output` and is located in the
`io.pedestal.app` namespace. It takes an app and services function as
arguments.

A services function is a function which receives a message and the
input queue.

```clojure
(defn example-services [message input-queue
  ;; send message to a back-end service
  ;; arrange for callback to transform response and place it on the
  ;; input queue
 )
```

This function can be configured to consume the effects queue with

```clojure
(app/consume-effects app example-services)
```

For more information, see the
[Services](https://github.com/pedestal/app-tutorial/wiki/Connecting-to-the-Service)
section of the tutorial.

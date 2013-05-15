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

This document describes all of the key ideas behind Pedestal
applications.


## The big picture

The main idea behind Pedestal applications is that there are three
distinct models and three processes which create them. The three
models are the **data model**, the **application model** and **document object
model**. The three processes are **transforms** which generate data models,
**dataflow** which maps from data models to the application model and
**rendering** which maps from the application model to the DOM.

![Three models](/documentation/images/client/overview/three_models.png)

The three models are described below. The processes which create them
will be described later this document.


### Data model

The data model is concerned with the organization of facts and is very
general. A data model could be used as the basis for many applications
and the data can take any shape. Data models should be normalized and
should support simple data transformations and queries. In many ways
the data model is like a database.


### Application model

The application model contains all of the information that a specific
application needs. An application model is structured as a tree and should
not be normalized. If the exact same information should appear in the
two different parts of an application then that information should be
repeated in the model.

An application model can be thought of as the user interface of the
application with all rendering and formatting information
removed. What remains is the information, structure and descriptions
of transformations which can be applied to the data model.


### Document object model

We all know the DOM. In Pedestal the DOM is used only for what it was
meant to be used for: rendering. The DOM is not used to store
application state. A correctly designed Pedestal application should
never have to look in the DOM to figure out what needs to be
changed. There should be a clear mapping from changes in the
application model to changes in the DOM.

Events fired in the DOM **never** directly change the DOM. All events
are translated into messages which describe transformations to the
data model. Change flows out from the data model to the application
model to the DOM.

This does not mean that Pedestal is tied to the DOM. The DOM is one
rendering model that is commonly used for web applications. The
process of rendering could just as easily render with Flash,
JavaScript visualization libraries like D3 or other JavaScript
component libraries.


## How the pieces fit

An application is isolated from the outside world through the use of
queues. All input to an application goes on the **input queue** and
all output is either read from the **output queue** or from the **app
model queue**. The input and output queues convey messages and the app
model queue conveys application model deltas.

Pedestal applications are divided into two main parts: **application**
and **view**. The application receives messages (transformations)
which cause change to the data models. The application model is a
projection of the data models. This projection takes the form of a
stream of deltas which represent change in the application model. This
stream of deltas is consumed by the view which draws some
representation of the application model on a screen for a human to
interact with. Part of the application model describes the way that
human interactions can cause transformations of the data model.

![Big picture](/documentation/images/client/overview/big_picture.png)

The diagram above shows how all of the parts fit together. Each part
will be described briefly in this document. Other documents will
describe each part in more detail.


## Messages

The messages which are sent to and from an application on the input
and output queues are encoded as Clojure maps. Each message has a
`topic` and a `type`. A `topic` identifies a group of related messages
and a `type` identifies the exact purpose of the message. A message
may contain any other data.

The `topic` and `type` keys are namespaced to
`io.pedestal.app.messages`. It is common to require this namespace as `msg`
and use the `topic` and `type` vars as a shorthand.

```clojure
{msg/topic :model-name msg/type :set-name :name "Alice"}
```

Messages like the one shown above are sent to the application, on the
input queue, to transform internal data models. Messages like this may
also come out of the application, on the output queue, and be sent to
external services.


## Application model

The application model has a well defined structure which is a logical
tree. We can think of this tree as a report which is based on the
underlying data models and derived data and is updated when that data
changes.

![Application model tree](/documentation/images/client/overview/tree.png)

All information required to build a UI should exist as a value
associated with a node in this tree.


### Tree structure

The structure of this tree is simple. Each node in the tree can have
any number of children. Each node can have a value, attributes and
transformations. Tree structure can be expressed literally as shown below.

```clojure
{:a {:value 10
     :attrs {:disabled false}
     :transforms {:change-volume [{msg/topic :volume :value :11}]}
     :children {:b {...}
                :c {...}}
```

Transformations are vectors of messages which can be sent to the
application to transform a data model.


### Deltas

This tree is not transmitted to the view as a tree but instead as a
sequence of deltas which describe changes to the tree. These deltas
describe changes to the tree's structure as well as changes to the
values, attributes and transformations attached to each node.

Tuples are used to describe these changes. For example:

```clojure
[:value [:a :b] {:name "Alice"}]
```

The first item in each tuple is the operation that will be performed
on the tree. There are six operations.

```clojure
:node-create       ;; create a new node
:node-destroy      ;; destroy a node
:value             ;; update the value of a node
:transform-enable  ;; attach a transform to a node
:transform-disable ;; remove a transform from a node
:attr              ;; update a node attribute
```

The second item in each tuple is the path to a node in the tree. To
add a node, one would send:

```clojure
[:node-create [:a :b] :map]
```

This will add a new node named `:b` to the tree. This node is a child
of `:a`.

Anything after the path is an argument which is specific to the type
of operation. In the example above, we tell the tree to store the
children of this new node in a map.

Types of arguments are shown below.

```clojure
:node-create       ;; one of :map or :vector
:node-destroy      ;; none
:value             ;; the new value, or the old and new value
:transform-enable  ;; transform name and a vector of messages
:transform-disable ;; transform name, or transform name and vector of messages
:attr              ;; attribute name and value
```

Imagine a simple application which can be represented as a tree with
two children. This structure can be described with the following data.

```clojure
[[:node-create [:a]    :map]
 [:node-create [:a :b] :map]
 [:node-create [:a :c] :map]]
```

Changes to the tree can also be written in a more compact form which
will be expanded. The example below will expand into the deltas shown
above.

```clojure
[{:a {:b {} :c {}}}]
```

Now suppose that we would like to set the value of the node at `[:a :b]`
to 42.

```clojure
[[:value [:a :b] 42]]
```

It is easy to understand the creation of structure and how to add values
to nodes. Transforms are a little bit harder.

```clojure
[:transform-enable [:a :b] 
 :change-name [{msg/topic :names (msg/param :name) {}}]]
```

A `transform-enable` delta is simply reporting that when viewing this
node in the tree (node `[:a :b]`), it makes sense to send the provided
vector of messages to the app model. It does not mean:

* you have to send these messages
* you cannot send other messages
* that a dataflow transform is being enabled or allowed
* that anything has actually happened

As with any of the other deltas, a `transform-enable` delta could be
ignored by the renderer. `transform-enable` messages are useful when
using automatic renderers, like the included data renderer, or when
using a push renderer where you would like the renderer to be told
when to wire up events in the UI.

The transform described above will be attached to the node at path
`[:a :b]`. The transform name is `:change-name` and the messages that
should be sent to apply this transform are `[{msg/topic :names (msg/param :name) {}}]`.

Transform messages are represented as a vector of maps. The transform
above might be hooked up to a simple form with a single text
field. When the form is submitted, the following messages will be sent
to the application:

```clojure
[{msg/topic :names msg/type :change-name :name "Alice"}]
```

Notice that the transform name `:change-name` has been added to the
message as the message type. In the `:transform-enable` instruction,
the `:name` key is marked as a parameter which should be supplied
before this message is sent.


### Focus

As an application grows, so will its application model tree. The
entire tree represents all of the information that an application
could care about. However, applications do not care about all of this
information at the same time. Pedestal provides a way to focus ones
perception on a single or multiple parts of this tree. Only updates to
these parts of the tree will be perceived by the renderer.

This solves a common problem faced by ClojureScript developers. The
problem of how many atoms to have in order to see the correct
granularity of change. In Pedestal, the answer is that you need only
one atom and the application model. The ability to focus perception on
any part of the tree allows for fine-grained perception of change.

For an example of focus, consider the tree shown above which has five
nodes. What if we only wanted to see the changes to node `:c` and its
children? To do this, we could send the `subscribe` message shown
below.

```clojure
{msg/topic msg/app-model msg/type :subscribe :paths [[:a :c]]}
```

Notice that the topic for this message is `::app-model`. This message
will cause the stream of application tree deltas to change so that it
only emits changes where the path begins with `[:a :c]`.

There are several message types which allow us to control focus:

* subscribe
* unsubscribe
* add-named-paths
* remove-named-paths
* set-focus

The last three message types above allow us to give names to parts of
an application tree and then switch between them with `set-focus`
messages.

```clojure
{msg/topic msg/app-model 
 msg/type :add-named-paths 
 :paths [[:a :c]] 
 :name :right-branch}

{msg/topic msg/app-model 
 msg/type :add-named-paths 
 :paths [[:a :b]] 
 :name :left-branch}

{msg/topic msg/app-model msg/type :set-focus :name :left-branch}
```


## Dataflow

In the sections above, we have seen how an application communicates
with the outside world by receiving and sending messages. When a
message is received by an application, it will become the input
to a dataflow which results in application model deltas being produced.

The application developer defines a dataflow by writing pure functions
for each step in the dataflow and then describing these functions and
their inputs in a map. The description map is passed to a `build`
function to create an instance of the dataflow engine.

This separation of pure functions from the description of their inputs
and the construction of a dataflow engine allows us to distinguish
between the functions themselves and the execution strategy. This
provides many benefits:

* multiple execution strategies for the same set of functions
* amazing debugging tools
* easy to test
* easy to reuse
* forces better design

The dataflow engine contains a state atom which holds all of the state
for the application. State transitions are managed by the engine and
not explicitly performed in application code. Developers write pure
functions which determine how states progress from one value to the
next.

In the next section, we look at the functions which are used to create
dataflows, control the progression of state and emit application tree
deltas.


## Dataflow building blocks

Dataflows are composed from pure functions. There are five kinds of
functions, each with different semantics, which can be used to create
any application dataflow.

There is one function which receives input (transform), one function
which is used to build arbitrary dataflows (combine) and three
functions which generate some kind of output (effect, continue,
emit).


### Transform
The first dataflow function responsible for handling messages is the `transform`.  Transforms have three components.  The first component is the transform's name.  It identifies which messages it handles.  For example, a transform with the name `:temperature` will handle messages with a topic of `:temperature`.  The second component is the transform's output path to its data model.  This is the location that stores the transform value.  For example, an output path of `[:a :b]` can be visualized as follows: `{:a {:b 'data-value}}`.  The transform would have the value 'data-value.  The third component is the transform function.  The transform function must take two parameters.  The first parameter is the old data value.  From above, it would be 'data-value.  The second parameter is the actual message itself.  When the transform is ran, it will update the old data model with the new value generated from the transform function.

There are three forms for declaring a transform.  The first is a vector form:

```clojure
[:transform-key [output-path] 'transform-fn]
```

The second form is a map form:

```clojure
{:key transform-key :out [output-path] :fn 'transform-fn}
```

The third form is another map form:

```clojure
{msg/topic transform-key msg/type [output-path] :fn 'transform-fn}
```

Here is an example.  A message is defined as follows:

```clojure
{msg/topic :temperature msg/type :new-temperature :t 32}
```

The transform function that will handle this in the dataflow is:

```clojure
{:transform [{:key :temperature :out [:temp] :fn (fn [old-temp msg] (:t msg))}]}
```

OR

```clojure
{:transform [[:temperature [:temp] (fn [old-temp msg] (:t msg))]]}
```

OR

```clojure
{:transform [{msg/type :temperature msg/topic [:temp] :fn (fn [old-temp msg] (:t msg))}]}
```

When the transform processes the message, the new value stored at :temp will be 32.

A more complex transform function can handle more than one type of message

```clojure
{:transform [{:key :temperature :out [:temp]
              :fn (fn [old-temp msg]
                       (condp (msg/type msg)
                         msg/init (:t msg)
                         :add-temperature (+ old-temp (:t msg))))}]}
```

```clojure
{msg/topic :temperature msg/type msg/init :t 32}
{msg/topic :temperature msg/type :add-temperature :t 4}
```

When the init message was receive, the data stored at `:temp` would be `32`.  When the add temperature message happens, it will add the old value to the new value, which in this case, would make `:temp` equal to `36`.
 
### Derive

A derive function is designed to take one or more data models in as inputs, and to produce a new value based on its inputs.  The source of the data models are either transforms, or other derive functions.  Whenever the inputs change, the derive function is run.  There are two general forms for a derive function:

The vector based one:

```clojure
[[[:input1] [:input2]] [:output-path] 'derive-fn]
```

or a map based on:

```
{:in [[:input1] [:input2]] :out [:output-path] :fn 'derive-fn}
```

The first parameter in the vector form, and the :in, in the map based form, is the list of inputs.  These are paths to the data models.  For example, say you had two transform functions which output their values to `[:temperature]` and `[:humidity]`.  The inputs to the derive function would be `[[:temperature] [:humidity]]`.

The second parameter in the vector, and the :out, in the map based form is the output path of the data model location where the output value should be placed.  This could be `[:humidex]`.

The third parameter in the vector, and the :fn, in the map based form is the derive function. The derive function is the function that will convert the inputs into the new value at the output path.  The derive function takes two parameters.  The first is the old derive output value.  The second parameter is a map containing the following keys: :removed, :added, :updated, :input-paths, :old-model, :new-model, and :message.  This is a tracking map, and will be discussed in further detail later.  For now, there are two functions that you would call on this tracking map.  The first function is when there is only one input to the derive function.  For example, if you were converting from celsius to fahrenheit.  The derive function for this would be:

```clojure
(fn [_ inputs] (* (/ 9 5) (+ (io.pedestal.app.dataflow/single-val inputs) 32)))
```

`(io.pedestal.app.dataflow/single-val inputs)` represents the celsius input value.  In this case, the old data value is elided because it is not needed.  Only the inputs parameter was used.


The second function that is used with the second parameter tracking map to the derive function is when there are multiple inputs.  In this case, it is best to use `io.pedestal.app.dataflow/input-map` which will return a map with the input path and its value.  For example, let us say you have a distance derive function, and its inputs are `[:velocity]` and `[:time]`.  The function to calculate distance would be:

```clojure
(fn [_ inputs]
  (let [{v [:velocity] t [:time]} (io.pedestal.app.dataflow/input-map inputs)]
    (* v t))
```

In this example, the result of `(io.pedestal.app.dataflow/input-map inputs)` is `{[:velocity] 'velocity-value [:time] 'time}` and this is destructured into the separate velocity and time values.  These values are then multipled together to give the distance.

A more complete example that takes the dataflow into account:

```clojure
{:transform [[:velocity [:car1 :velocity] (fn [ov msg]
                                            (condp (msg/type msg)
                                                msg/init (:v msg)
                                                :accelerate (+ (:v msg) ov)))]
             [:time [:elapsed-time] (fn [_ msg]
                                            (condp (msg/type msg)
                                                msg/init (:t msg)))]]
 :derive [[[:car1 :velocity] [:elapsed-time]] [:car1 :distance]
          (fn [old-distance inputs]
            (let [{v [:car1 :velocity] t [:elapsed-time]} (io.pedestal.app.dataflow/input-map inputs)]
              (if old-distance
                (+ old-distance (* v t))
                (* v t))))]}
```

The first transform function is outputing its values to `[:car1 :velocity]`  which represents the velocity of car1.  It has a function which will set the initial velocity, and also allow the velocity to be accelerated.  The second transform function is looking for messages with a topic of `:time` and it outputs the value to `[:elpased-time]`.  The derive function outputs the new distance value at `[:car1 :distance]`, which represents the current distance travelled by car1.  When either the velocity, or the elapsed time change, the distance will change.  The function will add the old distance to the new distance calculated from the velocity and time, if the old distance exists, otherwise, it just uses the velocity and time to set the distance.

### Continue

A `continue` function can be used for recursion, or message
composition. Like the derive functions, they have inputs and produce output.
The difference is that continue functions produce messages, and do not directly
alter data models.

To understand how continue functions work, you need to understand how the
dataflow processes messages. The dataflow is designed to process a single message at a time
from the input queue.  Once a message is popped from the queue, it is processed by the
dataflow.  This message then enters a kind of transaction.  The outside world will not
be aware of what has happened while the message is processed by the dataflow.  The dataflow
will simply produce one consistent data model with a new one.

The basic flow for the message through the dataflow is as follows:  First,
the transform functions process the message.  Next, the derive functions are ran.  Lastly,
the continue functions are ran.  

To be more specific.  The transforms functions that match the message's given topic are ran.
The transforms then alter their data models.  Then, the derive functions are given an opportunity
to run.  Since derive functions have inputs, a derive function will only run if its inputs have
been changed.  This would only occur if one of the derive function's inputs was one of the transform's
outputs.  If the derive function's input has been changed, it will produce output, which
will alter the data models.  What is important to note is that a derive function can have
another derive function's output as its input. The derive functions will continue to run
until all their inputs have stopped changing.

Once the transform and derive functions have all ran, it is time for the continue functions to
run.  A continue function, like a derive function, has inputs.  If those inputs were changed,
the continue function may produce output.  Unlike a derive function, which outputs to the
data model, a continue function produces a message, or a group of messages.  These messages
are just like those placed on the input queue.  The difference is that these messages will be placed
in a special queue within the dataflow transaction.  Once all the continue functions have run,
their messages are placed on the special transaction queue.

What happens next is that these continue messages are then processed, one by one, and sent through
the dataflow.  These messages are processed exactly the same as regular input messages from
the input queue.  They will be first processed by transforms, then by derives, and finally by the
continue functions.  It is possible for the continue messages to produce more messages.  These
messages are placed at the end of the special transaction queue.  Once the continue message has
been processed, the next continue messsage from the special transaction queue is processed.  This
process will continue until there are no more messages left in the continue message queue.

To take it from the top.  When the input queue is not empty, the next available message will be
popped from the queue.  This message is then processed by the dataflow within a single transaction.
Let us call this message, m0.  m0 will first be processed by the transforms.  This will cause
the data models to be updated.  When this happens, the derive functions are then ran.  The
derive functions can also alter the data models.  Next, the continue functions are ran, assuming their
inputs from the data models were changed.  If the continue functions are ran, they may produce
new messages.  These are special messages that are not placed on the input queue, but rather are
placed in a special in-transaction continue message queue.  Let us say that m0 caused the creation
of 2 continue messages, c1 and c2.  These messages are placed on the continue message queue.

Once all the continue messages have been run, m0 is no longer processed.  What happens next is
that the continue message queue is checked.  If it's not empty, the next continue message is
popped, in this case, c1.  This message is then ran through the dataflow, just like m0 was.
Let us say that when ran, c1 caused a new continue message to be produced, called c3.  This
message is placed on the continue message queue.  The queue now contains c2 and c3.  When
c1 has completed, the next message from the continue message queue is popped, which is c2.

c2 is ran through the dataflow, and it does not produce any new continue messages.  This means
that the next continue message is popped from the continue message queue, which is c3.  c3 is ran
through the dataflow, and it doesn't produce any new continue messages.  This means that the
general dataflow process has completed.  The original m0 message caused 3 messages to be produced
and consumed.  The data models will now be in a new state.  To the outside world, it would
not know that the dataflow produced those extract messages.  It only knows that a single
message was consumed, m0.


A continue dataflow function is created two ways.  Either in vector form:

```clojure
[[[:input-path1]] 'continue-fn]
```

or in map form

```clojure
{:in [[:input-path1] :fn `continue-fn]}
```

The continue function is designed to take a single argument, a tracking
map.  It is designed to output a message, or messages.  These messages are
then processed in sequence within the same transaction.

```clojure
(defn calc-continue [inputs]
  (let [im (io.pedestal.app.dataflow/input-map inputs)
        good-enough? (im [:good-enough?])
        new-guess (im [:new-guess])]
   (when-not (or good-enough?
                 (= new-guess :NaN))))
    [{msg/topic :guess 
      msg/type :new-guess
      :guess new-guess}])
```

This example continue function is taken from the square-root sample
project which uses Heron's method to approximate square roots. It will
produce a new `:guess` message when the new guess value is a valid
number and is not a good enough approximation.

The important thing to notice is that it examines the input value to
determine if new messages need to be generated. Because messages
returned from this function are processed within the same transaction,
it must eventually return nil or the transaction will never complete.

A continue function is configured in the dataflow description by
mapping a combine name to the continue function.

```clojure
{:continue {:new-guess-combine calc-continue}}
```

### Emit (Treeify)

The next function to process data within a dataflow is the `emit` or
`treeify` function. This function takes the output from one or more
combine functions and/or transform functions (data models) as input
and returns a sequence of application tree deltas.

There are two ways to create an emit function in the dataflow.  The first
is in vector form:

```clojure
[[[:input-path1] [:input-path2]] 'emit-fn]
```

The other is in map form:

```clojure
{:in [[:input-path1] [:input-path2]] :fn 'emit-fn}
```

The emit function takes a single argument, a tracking map.

The default emitter function looks like:

```clojure
(fn [inputs]
      (vec (concat (let [added (dataflow/added-inputs inputs)]
                     (mapcat (fn [[k v]]
                               (let [k (prefixed k prefix)]
                                 [[:node-create k :map]
                                  [:value k v]]))
                             added))
                   (let [updates (dataflow/updated-inputs inputs)]
                     (mapv (fn [[k v]] [:value (prefixed k prefix) v]) updates))
                   (let [removed (dataflow/removed-inputs inputs)]
                     (mapcat (fn [[k v]]
                               (let [k (prefixed k prefix)]
                                 (if v
                                   [[:value k v]]
                                   [[:value k v] [:node-destroy k]])))
                             removed)))))
```

Basically what's happening is that `(dataflow/added-inputs inputs)` is extracting the data models
that were added by either transform, or derive functions.  This causes two application
deltas to be created, :node-create and :value.  The :node-create is designed to create
new nodes, and the :value will set the node's value.  `(dataflow/added-inputs inputs)` is
finding out which data models have changed in the inputs to the emitter.  It will output
new :value application deltas.  `(dataflow/removed-inputs inputs)` is finding out which
data models are no longer in the data models.  The emiter will update the value of the node,
and then signal that the node holding it should be destroyed if the path was removed.

The emit functions will only run after all the transform, derive and continue functions have
been processed, and any continue messages have also been processed by these functions.  Only then,
do the emit functions create their application deltas.

### Effect

The last dataflow function to run is `effect`.  Effect functions are used to generate messages
that will be sent to the outside world,  such as the server.  These messages are placed
on the output queue.  The effect functions take inputs just like derive and continue functions.

There are two ways of creating an effect dataflow.  The first is in vector form:

```clojure
[[[:input-path1] [:input-path2]] 'effect-fn]
```

That other is in map form:

```clojure
{:in [[:input-path1] [:input-path2]] :fn 'effect-fn}


## Dataflow description

On their own, these functions aren't that useful. To make something
useful, we need to create a dataflow. A dataflow can be described with a
Clojure map. The example below contains all of the possible
keys that can be used to describe a dataflow.

```clojure
{:transform {:transform-a {:init "" :fn transform-a-fn}}
 :effect    {:transform-a effect-a-fn}
 :combine   {:combine-a {:fn combine-a-fn :input #{:transform-a}}}
 :continue  {:combine-a continue-a-fn}
 :emit      {:emit-a {:fn emit-a-fn :input #{:combine-a}}}}
```

The above application can be visualized as a simple graph.

![Full data flow](/documentation/images/client/model/full_flow.png)


## Creating an execution strategy

In the two sections above, we have seen how to define dataflow
functions and how to describe a dataflow. We have not yet created
anything which can run. The missing piece is the execution
strategy. We have a set of pure functions which take inputs and
produce new values. We have also defined how inputs and outputs flow
through the various functions. What we have not defined is how the
execution of the dataflow will proceed.

We call the piece which runs the dataflow the **dataflow engine**.

There are many questions which have to be answered by the dataflow
engine implementation:

* do we run dataflow steps sequentially or in parallel?
* what features are supported by the dataflow engine?
* how are input and output messages processed?
* how much visibility is allowed into the running flow?
* do we emit debugging data?

Pedestal currently provides a single dataflow engine implementation.

The `io.pedestal.app` namespace contains a `build` function which
takes a dataflow description and returns a new application. The
application contains all of the things that have been discussed in
this document. The final piece that it adds is the dataflow engine.

To create a new application, pass the dataflow description to
the `build` function.

```clojure
(require '[io.pedestal.app :as app])

(def dataflow 
  {:transform {:transform-a {:init "" :fn transform-a-fn}}
   :effect    {:transform-a effect-a-fn}
   :combine   {:combine-a {:fn combine-a-fn :input #{:transform-a}}}
   :continue  {:combine-a continue-a-fn}
   :emit      {:emit-a {:fn emit-a-fn :input #{:combine-a}}}})

(def app (app/build dataflow))
```

The returned `app` is a map which contains the following keys:

```clojure
:state           ;; an atom containing all app state
:description     ;; the dataflow description
:flow            ;; an optimized dataflow map
:default-emitter ;; the default emit function
:input           ;; input queue
:output          ;; output queue
:app-model       ;; app model queue
```

The state map contains the following keys:

```clojure
:subscriptions  ;; current path subscriptions
:emitter-deltas ;; deltas generated by the last transaction
:views          ;; combine states from last transaction
:models         ;; data models from last transaction
:input          ;; input which triggered the last transaction
:output         ;; output messages generated by the last transaction
```

As you experiment form the REPL or while writing tests, the
`app` map is a valuable resource.

### Working with queues

The application described above exposes three queues which are used to
send and receive messages and deltas.

`io.pedestal.app.protocols` defines two protocols which these queues
implement: `PutMessage` and `TakeMessage`.

```clojure
(defprotocol PutMessage
  (put-message [this message]))

(defprotocol TakeMessage
  (take-message [this f]))
```

`put-message` will add the message and return
immediately. `take-message` will call the passed function when the
next message is available. The given function will be called only
once.

To process all messages on the queue, you can define a recursive
function like the one shown below:

```clojure
(defn consume-queue 
  "Process all messages on the passed queue with the function f."
  [queue f]
  (p/take-message queue
                  (fn [message]
                    (f message)
                    (consume-queue queue f))))
```

Pedestal provides two functions to help consume queues:
`io.pedestal.app/consume-output` for consuming the output queue and
`io.pedestal.app.render/consume-app-model` for consuming application model
deltas. Refer to the source for these functions for more information.


## Main functions

Most Pedestal applications have one or more `main` functions which
create a new application and configure it. These main functions
are typically referred to in `config/config.clj`.

Using the dataflow described above and requiring some additional
namespaces, a main function might look like the one shown below:

```clojure
(require '[io.pedestal.app.render :as render])

(defn console-renderer [out]
  (fn [deltas input-queue]
    (binding [*out* out]
      (doseq [d deltas]
        (println d)))))

(defn ^:export main []
  (let [app (app/build dataflow)
        render-fn (console-renderer *out*)
        app-model (render/consume-app-model app render-fn)]
    (app/begin app)
    {:app app :app-model app-model}))
```

In this example we create a rendering function which will print all
deltas it receives to the console (it is assumed that we are running
on JVM Clojure). We then use `consume-app-model` to configure this
function to be called when processing the `app-model-queue`. The
function which is passed to `consume-app-model` will be called passing
both the deltas and the input-queue. This allows the renderer to
arrange for inputs to be sent back to the application.

The application is started by calling the `begin` function. This will
send `::init` messages to each model, passing in the their initial
values.

Finally, this function returns a map containing the app and
app-model. Returning this information is optional. It can be useful to
have when debugging and is also necessary for integration with the
developer tools. For example, returning this information allows
the tools to enable recording.

Notice that `consume-app-model` returns an app-model. This is an atom
which contains a `io.pedestal.app.tree.Tree` record with keys:

```clojure
:deltas ;; a map of all deltas produced
:tree   ;; the current value of the tree
:t      ;; the current tree time
```

This information is also useful for testing and debugging.

It is worth mentioning that Pedestal includes a
`io.pedestal.app.query` namespace which supports queries against this
tree, as well as queries against arbitrary data.

```clojure
(require '[io.pedestal.app.query :only [q]])

(q '[:find ?e ?a ?v :where [?e ?a ?v]] @app-tree)
```

This syntax will be familiar to anyone who has used Datomic.


## Rendering

In Pedestal, rendering is the process of consuming application model
deltas and drawing changes in the user interface. How closely these
deltas correspond to objects in the user interface is a design
decision that you have to make.

The application model can map directly to the UI and "drive" or "push"
changes to the UI or it can simply report changes to information that
is interesting to a renderer.

As shown above, it is easy set up the function which handles
rendering. Once this function is in place, rendering can do anything
at all.

Pedestal includes a rendering function implementation which helps in
writing applications where application model deltas drive changes to the
DOM. This is called the "push" renderer and is implemented in
`io.pedestal.app.render.push`.

Included with the Pedestal samples is a sample app named
`helloworld-app` which shows how to create a very simple app and use
the push renderer. The application is defined in a single file 
`helloworld_app/app/src/helloworld_app/app.cljs`.

In addition to the usual required namespaces, this namespace also
requires `io.pedestal.app.render.push`.

```clojure
(ns helloworld-app.app
  (:require [io.pedestal.app :as app]
            ...
            [io.pedestal.app.render.push :as push]))
```

In the main function, we call `push/renderer` to create the render
function. `push/renderer` takes the root DOM element id, under which
all changes will be made to the DOM, and a render configuration.

```clojure
(defn ^:export main []
  (let [app (app/build count-app)
        render-fn (push/renderer "content" [[:value [:**] render-value]])]
    (render/consume-app-model app render-fn)
    (receive-input (:input app))
    (app/begin app)))
```

A render configuration is a vector of vectors where each vector maps
from a delta to a function which will handle changes to the DOM when
that delta is received.

In this example the render configuration is:

```clojure
[[:value [:**] render-value]]
```

This will map `:value` deltas for any path to the `render-value`
function. The `render-value` function is shown below.

```clojure
(defn render-value [renderer [op path old-value new-value] input-queue]
  (dom/destroy-children! (dom/by-id "content"))
  (dom/append! (dom/by-id "content")
               (str "<h1>" new-value " Hello Worlds</h1>")))
```

A rendering handler function takes three arguments: the renderer
object, the delta and the input-queue.

The input-queue can be used to send a message back to the application.

The delta contains the op, path and the arguments which describe the change
being reported.

The renderer object is used to help map changes in the application
model to the DOM. The following functions are supported:

```clojure
(new-id! [renderer path] [renderer path v]
  "create a new id")
(get-id [renderer path]
  "get the id associated with the given path") 
(get-parent-id [renderer path]
  "get the id associated with the parent path")
(delete-id! [renderer path]
  "delete the id associated with this path")
(on-destroy! [renderer path f]
  "run this function when the node at path is destroyed")
(set-data! [renderer path d]
  "associate data with the given path")
(drop-data! [renderer path]
  "drop data associated with the given path")
(get-data [renderer path]
  "get the data associated with the given path")
```

The example function above doesn't use any of these. See the chat
sample app for some examples of usage.


### The data renderer

One goal of Pedestal is to allow for useful and functional user
interfaces to be automatically generated from a stream of deltas. We
are not there yet but we are well on the way.

The included data renderer allows you to run and interact with any
working application model without having to create your own
renderer. For now, this feature is helpful during development but
would never be deployed.

The data renderer is really just a set of handler functions and a render
configuration which maps all deltas to these functions.

```clojure
(ns data-renderer.example
  (:require [io.pedestal.app :as app]
            [io.pedestal.app.render :as render]
            [io.pedestal.app.render.push :as push-render]
            [io.pedestal.app.render.push.handlers.automatic :as auto]))

(defn ^:export main []
  (let [app (app/build dataflow-description)
        render-fn (push-render/renderer "content" 
                                        auto/data-renderer-config)]
    (render/consume-app-model app render-fn)
    (app/begin app)))
```

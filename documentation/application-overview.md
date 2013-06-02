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

A `transform` function receives input messages from the outside
world and applies a transformation to the data model. Each message
topic is mapped to a specific transform function. There is also a model
(state) associated with each of these functions. When called, it will be
passed the old value of its model and a message and it will return the new
model value.

This function can be thought of as a reducer over a stream of messages
with the same topic.

Transform functions are not related to the app tree deltas
`transform-enable` or `transform-disable`. Anyone can send a message
to any transform function at any time.

As a simple example, suppose that we have incoming messages which
report the temperature outside every minute. The topic for these
messages could be something like `:temperature` and the type could be
`:add-temperature`.

```clojure
{msg/topic :temperature msg/type :add-temperature :t 32}
```

The data model could be a vector of numbers. The transform function
would look like this:

```clojure
(defn add-temperature-transform [old-model message]
  (condp = (msg/type message)
    msg/init (:value message)
    :add-temperature (conj old-model (:t message))
    old-model))
```

As shown above, models should always handle the `::init` message type. This
message sets the initial value of the data model when the application
starts.

In the map which describes a dataflow, a transform is configured by
indicating the topic that the model consumes, the transform function
and providing an initial value to be sent to the transform.

```clojure
{:transform {:temperature {:init [] :fn add-temperature-transform}}}
```


### Effect

An `effect` function is used to generate messages which will be sent
out of the application model to have an effect on the outside world. This
function takes the input message and a data model associated with a
transform or combine as input and returns a sequence of messages.

The returned messages will be placed on the output queue when a
transaction completes.

Effect functions have three arguments: the input message, the old
data model value and the new data model value.

```clojure
(defn control-thermostat-effect [message old-model new-model]
  [{msg/topic :control 
    msg/type :change-target-temp
    :t (:target-temp new-model)}])
```

An effect function is configured in the dataflow description by
mapping a transform or combine to an effect function.

```clojure
{:effect {:some-transform-or-combine control-thermostat-effect}}
```


### Combine

A `combine` function takes one or more or the outputs of transform
functions (data models) and/or combine functions as input and produces
a new value based on its inputs. When an input changes during a dataflow,
the combine function will be called in order to update its value.

A combine function has two arities: four and two. When a combine
function has a single input, the four argument version is used.  When a
combine function has multiple inputs, the two argument version is
used. The four argument version takes the old combine state, the name
of the input and the old and new input values and returns a new
value. Having this version makes it much easier to implement the
common case of a single input combine.

```clojure
(defn half [state input-name old-value new-value]
  (/ new-value 2)))
```

The example above is a simple combine which takes a data model representing a
number and produces a number that is half of its input.

The two argument version takes the old combine state and a map of input
names to input values. Each input value is a map with `:old` and
`:new` keys containing the old and new state of each input.

```clojure
(defn sum [state inputs]
  (let [ns (keep :new (vals inputs))]
    (apply + ns)))
```

The example above takes multiple inputs where the values are numbers
and calculates their sum.

A combine function is configured in the dataflow description by
giving it a unique name and indicating the function to call and the
inputs to that function.

```clojure
{:combine 
  {:sum-combine 
    {:fn sum :input #{:number-of-apples :number-of-oranges}}}}
```


### Continue

A `continue` function can be used for recursion or message
composition. Each transform consumes a single message stream and
produces a data model. Every time a new message is processed, a new
transaction is run. Within that transaction, time stops. The state of
every data model is frozen so that the functions processing the
current message see a consistent view of the world. Some combine
functions will produce a single value from multiple data models. There
are times when we may want to generate a new message when several data
models are in a specific state. The combine function is used to
'combine' multiple values into a single value; the continue function
can then use this value to produce new input messages.

The generated messages will be used as input to transform functions
within the same transaction.

The continue function takes three arguments, the input name and the old
and new input value. It returns a sequence of messages which will be
processed within the same transaction.

```clojure
(defn calc-continue [input-name old-value new-value]
  (when-not (or (:good-enough? new-value)
                (= (:new-guess new-value) :NaN)))
    [{msg/topic :guess 
      msg/type :new-guess
      :guess (:new-guess new-value)}])
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

The last function to process data within a dataflow is the `emit` or
`treeify` function. This function takes the output from one or more
combine functions and/or transform functions (data models) as input
and returns a sequence of application tree deltas.

The first argument to the emit function is a map of inputs. The
keys in the map are the keyword names of the inputs. The values are
maps with `:new` and `:old` keys containing the new and old values of
each input.

The single argument version of this function is called when an emit
function must generate all deltas to build the part of the application
tree that it is responsible for. The two argument version is called
when any of the function's inputs have changed.

For the two argument version, the second argument is a set of
keywords. Each keyword is the name of an input that has changed.

The default emit implementation is available in the `io.pedestal.app` 
namespace and looks like this:

```clojure
(defn default-emitter-fn
  ([inputs]
     (concat [[:node-exit []]]
             (mapcat (fn [[k v]]
                       [[:node-create [k] :map]
                        [:value [k] (:new v)]])
                     inputs)))
  ([inputs changed-inputs]
     (mapv (fn [changed-input]
             [:value [changed-input] (:new (get inputs changed-input))])
           changed-inputs)))
```

Calling this function with the following arguments:

```clojure
(default-emitter-fn {:some-view {:old nil :new 42}})
```

will produce the application tree deltas shown below.

```clojure
[[:node-create [:some-view] :map]
 [:value [:some-view] 42]]
```

An emit function is configured in the dataflow description by mapping
a name to the function and its inputs.

```clojure
{:emit 
  {:some-emitter 
    {:fn an-emit-function :input #{:some-combine :some-transform}}}}
```


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

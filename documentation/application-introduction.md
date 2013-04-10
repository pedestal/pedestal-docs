---
title: Application Introduction
---

# Application Introduction

This document explains how to make a very simple Pedestal
application.

Most applications need to do the same basic things:

* Receive and process input
* Manage state
* Update the UI when state changes

Writing this kind of application in ClojureScript is straightforward.

```clojure
(ns hello-world
  (:require [domina :as dom]))

(def application-state (atom 0))

(defn render [old-state new-state]
  (dom/destroy-children! (dom/by-id "content"))
  (dom/append! (dom/by-id "content")
               (str "<h1>" new-state " Hello Worlds</h1>")))

(add-watch application-state :app-watcher
           (fn [key reference old-state new-state]
             (render old-state new-state)))

(defn receive-input []
  (swap! application-state inc)
  (.setTimeout js/window #(receive-input) 3000))

(defn ^:export main []
  (receive-input))
```

Here we have all of the basic parts that we need. There is an atom for
storing state and Clojure's update semantics for performing state
transitions. We can easily watch the atom for changes and call a
rendering function passing in the old and new state.

If you have ever built a ClojureScript application, this is the way
you start.

As the application above gets more complex, many problems will
arise. How many atoms should we have? What is the structure of the
data that goes into the atoms? When we are handed an old and new
state, how do we figure out what has changed? How do we know if we
should care about a change?

One of the largest problems with this approach is that the rendering
function is being asked to do a lot of work. It is handed an old and
new value and asked to render it. It has to figure out what has
changed and then figure out the state of the DOM so that it can make
the necessary change. There are only two ways to deal with this; both
are unacceptable.

The first is to look at the DOM and try to figure out what needs to be
modified, the other is to wipe out large sections of the DOM and
re-render everything. The first approach means that we put state in
the DOM. The second does not perform well.

Pedestal is designed to help us keep all state out of the DOM and
write applications which perform well.


## First Pedestal application

The example below shows the same application written with Pedestal.

```clojure
(ns hello-world
  (:require [io.pedestal.app.protocols :as p]
            [io.pedestal.app :as app]
            [io.pedestal.app.messages :as msg]
            [io.pedestal.app.render :as render]
            [domina :as dom]))

(defn count-model [old-state message]
  (condp = (msg/type message)
    msg/init (:value message)
    :inc (inc old-state)))

(defmulti render (fn [& args] (first args)))

(defmethod render :default [_] nil)

(defmethod render :value [_ _ old-value new-value]
  (dom/destroy-children! (dom/by-id "content"))
  (dom/append! (dom/by-id "content")
               (str "<h1>" new-value " Hello Worlds</h1>")))

(defn render-fn [deltas input-queue]
  (doseq [d deltas] (apply render d)))

(def count-app {:models {:count {:init 0 :fn count-model}}})

(defn receive-input [input-queue]
  (p/put-message input-queue {msg/topic :count msg/type :inc})
  (.setTimeout js/window #(receive-input input-queue) 3000))

(defn ^:export main []
  (let [app (app/build count-app)]
    (render/consume-app-model app render-fn)
    (receive-input (:input app))
    (app/begin app)))
```

This is a lot more code to do the same thing. What are the benefits of
this code over the example above?

The first thing to notice is that there is no explicit state
management. There is no atom, no watcher and no swap!. The application
that is built in `main` manages state transitions. The `count-model`
function receives its old state and produces a new state without
having to produce side effects.

Because state transitions are handled by the application engine, most
of our application logic can be written as pure functions.

The state is no longer a global thing that can be updated from
anywhere. All updates to the data model happen in one place. In this
small application, they take place within the `count-model` function.

The application data flow is described with a map, `count-app`. This
map is then used to build the application. The description of
functions and inputs have been separated from the execution strategy.
This separation provides many benefits:

* multiple execution strategies for the same set of functions
* amazing debugging tools
* easy to test
* easy to reuse
* forces better design

This separation forces developers to think about functions
independent from execution order.

In the code above, renderers receive deltas instead of two
states. Because renderers know exactly what has changed they can
usually be written as very simple functions.

## Using the Pedestal push renderer

In the example above, the rendering code is doing all the work of
dispatching deltas to the correct rendering functions. This shows that
it is easy to do this kind of thing yourself. Pedestal includes a
rendering function implementation which is helpful when writing
applications where the rendering is controlled by pushing changes out
to the renderer from the underlying models. This is implemented in
`io.pedestal.app.render.push`.

The example below shows the same application using the push renderer.


```clojure
(ns hello-world
  (:require [io.pedestal.app.protocols :as p]
            [io.pedestal.app :as app]
            [io.pedestal.app.messages :as msg]
            [io.pedestal.app.render :as render]
            [io.pedestal.app.render.push :as push]
            [domina :as dom]))

(defn count-model [old-state message]
  (condp = (msg/type message)
    msg/init (:value message)
    :inc (inc old-state)))

(defn render-value [renderer [_ _ old-value new-value] input-queue]
  (dom/destroy-children! (dom/by-id "content"))
  (dom/append! (dom/by-id "content")
               (str "<h1>" new-value " Hello Worlds</h1>")))

(def count-app {:models {:count {:init 0 :fn count-model}}})

(defn receive-input [input-queue]
  (p/put-message input-queue {msg/topic :count msg/type :inc})
  (.setTimeout js/window #(receive-input input-queue) 3000))

(defn ^:export main []
  (let [app (app/build count-app)
        render-fn (push/renderer "content" [[:value [:*] render-value]])]
    (render/consume-app-model app render-fn)
    (receive-input (:input app))
    (app/begin app)))
```

There are two big differences in this implementation: all dispatching
is handled by the provided rendering function and the rendering
handler, `render-value`, receives a renderer object and the
input-queue. The renderer can be used to help in mapping changes to the
DOM and the input-queue is used to send messages back to the
application.

The renderer is configured to send all `:value` changes to the
`render-value` function.


## Using templates

The only remaining problem with this code is that we have included a
lot of specific HTML and formatting in with the Clojure code. It would
be good to extract this to a template.

The example below shows the same application using templates to both
generate and update HTML.

```clojure
(ns hello-world
  (:require [io.pedestal.app.protocols :as p]
            [io.pedestal.app :as app]
            [io.pedestal.app.messages :as msg]
            [io.pedestal.app.render :as render]
            [io.pedestal.app.render.push :as push]
            [domina :as dom])
  (:require-macros [hello-world.html-templates :as html-templates]))

(def templates (html-templates/hello-world-templates))

(defn count-model [old-state message]
  (condp = (msg/type message)
    msg/init (:value message)
    :inc (inc old-state)))

(defn render-page [renderer [_ path] input-queue]
  (let [parent (push/get-parent-id renderer path)
        html (templates/add-template renderer path (:hello-world-page templates))]
    (dom/append! (dom/by-id parent) (html {:message ""}))))

(defn render-value [renderer [_ path old-value new-value] input-queue]
  (templates/update-t renderer path {:message (str new-value)}))

(def render-config
  [[:node-create [:*] render-page]
   [:value       [:*] render-value]])

(def count-app {:models {:count {:init 0 :fn count-model}}})

(defn receive-input [input-queue]
  (p/put-message input-queue {msg/topic :count msg/type :inc})
  (.setTimeout js/window #(receive-input input-queue) 3000))

(defn ^:export main []
  (let [app (app/build count-app)
        render-fn (push/renderer "content" render-config)]
    (render/consume-app-model app render-fn)
    (receive-input (:input app))
    (app/begin app)))

```

In this example, we have extracted the render-config and we now
respond to two kinds of updates: `:node-create` and `:value`. When we
receive a `:node-create` delta, we render the page using a
template. When we receive a `:value` delta, we simply update the value
in the existing template.

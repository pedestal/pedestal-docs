---
title: Application Introduction
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

# Application Introduction

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
rendering function, passing in the old and new state.

If you have ever built a ClojureScript application, you may have
started in this way.

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

You may have noticed the word "change" a few times in the above
paragraphs. The main source of complexity which arises from a
large application of this type is dealing with change.

Pedestal helps us deal with this complexity by giving us tools to
model, report and react to change. 


## First Pedestal application

The example below shows the same application written with Pedestal.

```clojure
(ns hello-world
  (:require [io.pedestal.app.protocols :as p]
            [io.pedestal.app :as app]
            [io.pedestal.app.messages :as msg]
            [io.pedestal.app.render :as render]
            [io.pedestal.app.render.push :as push]
            [domina :as dom]))

(defn render-value [renderer [_ path old-value new-value] input-queue]
  (let [id (push/get-parent-id renderer path)]
    (dom/destroy-children! (dom/by-id id))
    (dom/append! (dom/by-id id)
                 (str "<h1>" new-value " Hello Worlds</h1>"))))

(defn inc-t [old-state message]
  (inc old-state))

(def count-app {:version 2
                :transform [[:inc [:count] inc-t]]})

(defn receive-input [input-queue]
  (p/put-message input-queue {msg/type :inc msg/topic [:count]})
  (.setTimeout js/window #(receive-input input-queue) 3000))

(defn ^:export main []
  (let [app (app/build count-app)
        render-fn (push/renderer "content" [[:value [:*] render-value]])]
    (render/consume-app-model app render-fn)
    (receive-input (:input app))
    (app/begin app)))

```

Ignoring the required namespaces and the setup code in the `main`
function, this is about the same amount of code.

The benefits of the Pedestal version include:

* no explicit state management
* application behavior can be defined by pure functions
* detailed change reporting

In the Pedestal version, there is no explicit state management. There
is no atom, no watcher and no `swap!`. Much like a Clojure reference
type, the application that is built in `main` manages state
transitions. The `inc-t` function receives a value and produces a new
value without having to produce side effects.

Because state transitions are handled by the application engine, most
of our application logic can be written as pure functions.

The state is no longer a global thing which can be updated from
anywhere. All updates to the information model happen in one place. In
this small application, they take place within the `inc-t` function.

In the Pedestal version, the rendering function is passed a
description of the exact change which was made. Rendering code no
longer has to find changes, make huge changes to the DOM or look for
state in the DOM. It simply makes the change it is told to make. This
is usually implemented in a small function which makes a very precise
change.

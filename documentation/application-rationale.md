---
title: Application Rationale
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

# Application Rationale

The Pedestal application library is designed to help developers create
large applications which run in the browser.

When creating these kinds of applications, there are many problems
that a developer will have to solve, some of which are listed
below. Pedestal is designed to address these problems.


### State Management

Rich, collaborative applications will need to deal with a lot of
application state. Pedestal provides a way to do this which fits into
Clojure's philosophy on state, viewing state as a succession of
values. The Pedestal application library provides a mechanism for
managing state transitions which frees the developer to write nothing
but pure functions.


### Rendering State Changes

Every application needs to reflect changes made to the state of the
application in the user interface. This seems easy when an application
is small but can become very difficult to deal with as it grows. When
data models and rendering are tightly coupled it becomes difficult to
change one without breaking the other.

Pedestal introduces a clear separation between data models and
rendering. In fact, it introduces a new model, the application model.


### Filtering State Changes

Large applications allow users to performs many different tasks. Each
task only cares about some subset of the entire application's
state. Pedestal provides a way to allow rendering code to see only the
state changes that are necessary to support the current task.


### Slow Development Process

When the parts of a system are not properly decoupled, the whole
system must be run in order to work on any part of it. This
can drastically slow down development time when creating rich,
collaborative applications. The time that it takes to start and
restart a system combined with the time that it takes to manually
simulate the actions of multiple agents can become overwhelming.

One approach to this problem would be to automate testing. But this
does not address the more fundamental problem of coupling. A better
solution would be to decouple the system so that each part can be
developed and tested in isolation from the other parts.

Pedestal is designed to allow applications to be built in this way.


### Debugging

In a message-driven system, it is sometimes hard to determine the
cause of a problem that is discovered when testing or running a part
of the system.

In a Pedestal application, each new message is processed within a
transaction.  Each transaction ties a single input message to all of
the state changes and output produced by processing that input.

This makes it possible to track corrupted state and invalid rendering
data to the inputs that caused them. In a debugging environment, all
transitional states can be captured and used to reproduce the problem
until it is fixed. Captured rendering deltas can be used to render what
was visible to the user when the problem occurred.


### Testing

It is difficult to test applications which run in the browser. All
application logic in a Pedestal application can be written and tested
in Clojure.

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

The Pedestal application library (pedestal-app) is designed to help
developers create interactive web applications.

Pedestal reduces application complexity by giving developers tools to
model, report and react to change.


## The problem

Interactive applications constantly receive inputs from multiple
sources. This property forces them to be long-running, single-page
applications which must have state.

There are three high-level tasks that this kind of application must
perform:

* Receive and process input
* Manage state
* Update the UI when state changes

There are hard problems associated with each of these tasks.

All I/O in the browser is asynchronous. If we receive input from users
or services then we must create callback functions to process these
inputs. This reduces our ability to control how our program executes,
and can make programs hard to understand. This problem is often
referred to as **Callback Hell**.

Inputs supply new information to our application which must be stored
in some way. While applying changes to state, which are triggered by
asynchronous inputs, we must ensure that we are always seeing a
**consistent view of state**. Additionally, there may be many parts of
that model which need to change based on the input. Where does the
code which knows about these **data dependencies** live? If it is the
responsibility of the code processing the input message then this code
becomes brittle and must be changed every time we add a new feature to
the application.

The purpose of a user interface is to be a visual representation of
the information model. When the model changes, the UI will need to
change. In order to do this efficiently, we need to know **what has
changed**.

These are the problems that Pedestal addresses.


## Pedestal's solution

Every callback function in Pedestal has one job: convert an event
into a message (data) and place this message on the application's
**input queue**. This addresses the two problems of callbacks: it helps us
understand how our program works and it gives back control.

Event wiring code is just that, it wires up an event, captures it,
converts it to data and puts it on a queue. Callback functions are no
longer directly causing any other code in our application to run.

We can now think of all input as being conveyed to our application on
a queue. We are in control of how and when the messages on this queue
are processed.

Messages on this queue are processed one at a time. For each input
message, a single **transaction** is run which results in a new
state. While this transaction is running, no other input can change
the state. This ensures that we have a consistent state within a
transaction.

Within a transaction, each change is defined by a pure function. Each
function can focus on making one change. Changes to dependencies in
the information model are handled by **dataflow**. This allows changes to
automatically propagate when new inputs are received. New features are
added by creating new dataflow functions rather than updating existing
ones.

For each transaction, the changes which have been made to the
information model are translated into instructions which are sent to
the renderer. The instructions describe the exact changes which need
to be made to the UI. This technique of **communicating change**
decouples rendering from state and allows rendering code to make
efficient changes to the view. 

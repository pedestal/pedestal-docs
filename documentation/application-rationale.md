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

Pedestal reduces application complexity by giving developers tools to
model, report and react to change.

## The problem

All applications need to do the same three things:

* Receive and process input
* Manage state
* Update the UI when state changes

All I/O in the browser is asynchronous. If we receive input from users
or services then we must create callback functions to process these
inputs. This reduces our ability to control how our program executes,
and can make programs hard to understand. This problem is often
referred to as **Callback Hell**.

Inputs supply new information to our application which must be stored
in some way. While applying changes to state, which are triggered by
asynchronous inputs, we must ensure that we are always seeing a
**consistent view of state**. Additionally, if we model the UI as part
of the application's state, then there may be many parts of that model
which need to change based on the input. Where does the code which
knows about these **data dependencies** live? If it is the
responsibility of the code processing the input message then this code
becomes brittle and must be changed every time we add a new feature to
the UI.

The purpose of a user interface is to be a visual representation of
the data model. When the model changes, the UI will need to change. In
order to do this efficiently, we need to know **what has changed**.

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
the data model are handled by **dataflow**. This allows changes to
automatically propagate when new inputs are received. New features are
added by creating new dataflow functions rather than updating existing
ones.

For each transaction, the changes which have been made to the data
model are reported to rendering code as a list of instructions. The
instructions describe the exact changes which need to be made to the
UI. Each application may have different requirements on how fine the
resolution of **change reporting** is. The application developer has
complete control over the granularity of change reporting.

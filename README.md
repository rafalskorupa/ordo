# Ordo

Ordo App is sandbox app built on top Commanded ecosystem.

## Context explanation

### Ordo.Actor

One module that defines "Actor" through the Application. All queries and commands should use this as a first argument.

It's not necessary now, but having it already defined and separated allows to have unified way to check whether the system's user can have access to resource or can perform given action. 

### Ordo.Authentication

Ordo.Authentication is module responsible for handling system's accounts.
Account is an entity that allows to login to system (web page), by a decision is not linked to any 'user' allows account be used for multiple users (if defined later).

### Ordo.Corpos

Ordo.Corpos is a module responsible for handling "Corpos" - tenants.

Features:
* List Corpos
* Create Corpo

### Ordo.People

Ordo.People is a module responsible for managing Employees CRUD. Employees can have, but are not required to have an account to login into the system.

Features:
* List Employees
* Create Employee in Corpo
* Update Employee in Corpo
* Delete Employee in Corpo
* Send Invitation to App to Employee based on email

### Ordo.Invitations

Module responsible for invitations to Corpos. In current version the invitation can be created from Corpo and it's visible on `auth/corpos` path when choosing Corpo to login.

Invitations doesn't require email to be already registered in the system, but Users can access them only if invitation email matches 

Features:
* List Invitations for current Account (based on matching `email`)
* Accept Invitation

### Ordo.Tasks

Module reponsible for managing Todo Lists, Tasks and Boards

#TODO(rsko): When adding assignee to a task new "Add assignee" button doesn't display dropdown - rewrite to separate component

### Ordo.Notifications

Context responsible for sending notifications

Currently, Employee will receive in-app notification if:
* Someone else assigned task to him
* Someone else unassigned task from him

### Ordo.Nasa

Calculates fuel required for a Space Trip.

Solves a problem with recursively calculating values based on formulas.

#TODO(rsko): Describe formulas and problem

## Known Issues 

* Web layer is not tested
* Fixtures have to be refactored, still figuring out the way to do it with gracefully handling need for an Actor in every command
* Multiple invitations can be created for one email address - it might be a feature, but I see it as a bug


## Business Logic questions

*  Notifications are sent for employees without account - whenever account is linked all notifications are assigned to user - should it behave that way? I see a value in that, but it's not a solution that was picked, rather that was just applied

## Setup

```
mix deps.get
mix db.create
iex -S mix phx.server
```
Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

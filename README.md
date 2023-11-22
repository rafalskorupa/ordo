# Ordo

Ordo App is sandbox app built on top Commanded ecosystem.

Ordo.Authentication is module responsible for handling system's accounts.
Account is an entity that allows to login to system (web page), by a decision is not linked to any 'user' allows account be used for multiple users (if defined later).

Ordo.Corpos is a module responsible for handling "Corpos" - tenants.

Ordo.People is a module responsible for managing Employees CRUD. Employees can have, but are not required to have an account to login into the system.


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

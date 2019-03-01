# vutuv

vutuv is a business network which is hosted at [https://www.vutuv.de](https://www.vutuv.de). Think of it as a free, fast and secure open-source alternative for [LinkedIn](https://www.linkedin.com) or [XING](https://www.xing.com). The first version of vutuv can be found in the [branch v1.1](https://github.com/vutuv/vutuv/tree/v1.1).

# Development How-To

vutuv is a [Phoenix Framework](http://www.phoenixframework.org/) application. Please install the following software first ([asdf-vm is a good version manager](https://github.com/asdf-vm/asdf)):

- Erlang version 21.2.3  
- Elixir version 1.8.1
- nodejs version 6.8.0

## Database

We use for production and development [PostgreSQL](https://www.postgresql.org). Please make sure that your database configuration in `config/dev.exs` is correct.

  * Create and migrate your database with `mix ecto.setup`

# Misc

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Learn more about Phoenix

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

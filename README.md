# vutuv

[![Build Status](https://travis-ci.org/vutuv/vutuv.svg?branch=master)](https://travis-ci.org/vutuv/vutuv)

vutuv is a business network which is hosted at [https://www.vutuv.de](https://www.vutuv.de). Think
of it as a free, fast and secure open-source alternative for [LinkedIn](https://www.linkedin.com) or
[XING](https://www.xing.com). The first version of vutuv can be found in the [branch
v1.1](https://github.com/vutuv/vutuv/tree/v1.1).

## Getting started

vutuv is a [Phoenix Framework](http://www.phoenixframework.org/) application.  Please install the
following software first ([asdf-vm is a good version manager](https://github.com/asdf-vm/asdf)):

* Erlang version > 21.2.3
* Elixir version > 1.8.1
* nodejs version > 6.8.0

After cloning the repository, run `mix deps.get` and `(cd assets && npm install)`
to install dependencies.

To setup the database, run `mix ecto.setup`.

To start the Phoenix endpoint within an iex shell, run `iex -S mix phx.server`.

### Database

We use for production and development [PostgreSQL](https://www.postgresql.org).
Please make sure that your database configuration in `config/dev.exs` is correct.

* Create and migrate your database with `mix ecto.setup`
* Reset your database with `mix ecto.reset`

## Recommended tooling

### Pre-commit

We encourage you to use [pre-commit](https://pre-commit.com/), which adds
pre-commit git hooks (to check code before it is committed) to your local repository.

To install pre-commit, run `pip install pre-commit` (or `brew install pre-commit`
if using homebrew).

To add pre-commit to your local repository, run `pre-commit install` in the
root directory.

See the `.pre-commit-config.yaml` file for more information about the
configured checks.

### Dialyzer

Dialyzer can be used to analyze the Elixir code, especially for type errors.
We can use it through [dialyxir](https://github.com/jeremyjh/dialyxir), which
is installed as a dev dependency.

To run dialyzer, run `mix dialyzer`.

**NOTE**: To make dialyzer more effective, we need to write a specification, `@spec`,
for each public function.

## License

MIT license. See the [LICENSE](https://github.com/vutuv/vutuv/blob/master/LICENSE.TXT) for details.

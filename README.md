# vutuv

[![Build Status](https://travis-ci.org/vutuv/vutuv.svg?branch=master)](https://travis-ci.org/vutuv/vutuv)

vutuv is a business network which is hosted at [https://www.vutuv.de](https://www.vutuv.de). Think
of it as a free, fast and secure open-source alternative for [LinkedIn](https://www.linkedin.com) or
[XING](https://www.xing.com). The first version of vutuv can be found in the [branch
v1.1](https://github.com/vutuv/vutuv/tree/v1.1).

## Getting started

vutuv is a [Phoenix Framework](http://www.phoenixframework.org/) application.  Please install the
following software first ([asdf-vm is a good version manager](https://github.com/asdf-vm/asdf)):

* Erlang > 21.1
* Elixir > 1.8
* nodejs > 6.8.0
* postgresql

After cloning the repository, run `mix deps.get` and `(cd assets && npm install)`
to install dependencies.

To create the database and run migrations, run `mix ecto.setup`.

To start the Phoenix endpoint within an iex shell, run `iex -S mix phx.server`.

See the [contributing guide](https://github.com/vutuv/vutuv/blob/master/CONTRIBUTING.md)
for more information about setting up your development environment and opening pull
requests.

### Custom generators

We are using custom templates for context and schema generation (when
using the Phoenix `phx.gen.*` generators).

See the [Custom generator wiki page](https://github.com/vutuv/vutuv/wiki/Custom-generators)
for help using the Phoenix generators with these templates.

### SMTP Setup
The system uses the [Bamboo](https://github.com/thoughtbot/bamboo) email
library by [thoughtbot](https://thoughtbot.com/) to send emails via SMTP.

#### SMTP Setup Development
In the development environment emails are not sent to an actual SMTP
server but displayed in the browser via [Bamboo.EmailPreviewPlug](https://hexdocs.pm/bamboo/Bamboo.EmailPreviewPlug.html). To see which emails have been sent, visit [http://localhost:4000/sent_emails](http://localhost:4000/sent_emails)

## License

MIT license. See the [LICENSE](https://github.com/vutuv/vutuv/blob/master/LICENSE.TXT) for details.

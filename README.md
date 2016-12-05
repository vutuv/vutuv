[![Stories in Ready](https://badge.waffle.io/vutuv/vutuv.png?label=ready&title=Ready)](https://waffle.io/vutuv/vutuv)
[![Build
Status](https://travis-ci.org/vutuv/vutuv.svg?branch=master)](https://travis-ci.org/vutuv/vutuv)

# vutuv
vutuv is a free, fast and open source social network service to host and share information about humans and organizations. It's hosted at https://www.vutuv.de. Please have a look at our [blog](https://medium.com/@vutuv) for more information about it.

# Do you want to participate in the development?

Great! We encourage new developers to participate in this project. Even a one line fix or improvement makes a big difference. Please do not hesitate to contact stefan.wintermeyer@amooma.de if you have any questions. Otherwise just create a pull request. You find a document with additional information about this in the file [faster_pr_reviews.md](https://github.com/vutuv/vutuv/blob/master/faster_pr_reviews.md).

We use [MIT License](https://mit-license.org/).

And please do add an issue for any problem or feature request.

We run a private Slack channel. Once you get involved by commiting code we'll invite you to it.

# Development How-To

Vutuv is a [Phoenix Framework](http://www.phoenixframework.org/) application. Please install the following software first:

- [latest version of Erlang/Elixir](http://elixir-lang.org/install.html).
- [Phoenix Framework](http://www.phoenixframework.org/)
- [MySQL](http://www.mysql.com/)

Make sure that your database configuration in `config/dev.exs` is correct.

## Create your secret config

In order to compile your application, You'll need to create a `secret.config` file.
This file isn't included with the source files. It wouldn't be secret if it was!

Go to the `/config` directory and create two files named
`dev.secret.exs` and `prod.secret.exs` with this content:
```elixir
use Mix.Config
```

## Configure your SMTP setup

The system uses the [Bamboo](https://github.com/thoughtbot/bamboo) email
library by [thoughtbot](https://thoughtbot.com/) to send emails via SMTP.

### Development

In the development environment emails are not sent to an actual SMTP
server but displayed in the browser via [Bamboo.EmailPreviewPlug](https://hexdocs.pm/bamboo/Bamboo.EmailPreviewPlug.html). To see which emails have been send you have to visit https://www.vutuv.de/sent_emails

### Production

The default setup is a local SMTP server on port 25 with no authentication. You can change this in `config/prod.exs` in the following section:
```elixir
config :vutuv, Vutuv.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "127.0.0.1",
  port: 25,
  username: "",
  password: "",
```
For more information on the these settings, consult the [bamboo docs](https://github.com/thoughtbot/bamboo).

## Start the application

You should now be able to run the application by following the steps below.

```bash
$ cd vutuv
$ mix deps.get
$ mix deps.compile
$ npm install
$ mix ecto.create
$ mix ecto.migrate
$ mix phoenix.server
```

## First steps in the application

You need to register as a new user on http://localhost:4000

After creating a couple of example users you can login to them and
connect to other others by browsing to their page and click on the "Follow" button.

To view the admin control panel, you'll need to flag your account as an admin. This can be done with the following sql query:
`update users set administrator = true where id = <user_id>;`
replacing `<user_id>` with your user id.

You can then view the admin control panel at http://localhost:4000/admin

# Sponsors

We are glad to have some sponsors which help us to run https://www.vutuv.de

- [Github](https://github.com)
  They host our git repository for free.
- [Travis CI](BrowserStack)
  They don't charge us for using their service.
- [Ghost Inspector](https://ghostinspector.com)
  They sponsor us with 1,000 test runs per month and access to premium features.
- [tiny png](https://tinypng.com)
  They initially sponsored us with 20,000 free hits to their image API.
- [BrowserStack](https://www.browserstack.com)
  They don't charge us for using their screenshot API.

In total those companies sponsor us with more than 500 USD every month. Thank you!

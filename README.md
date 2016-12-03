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

## Quickstart with Docker

You can also bootstrap your development environment with docker, without installing any dependencies on your host system. You need:
- [Docker Engine >= 1.10](https://docs.docker.com/engine/)
- [Docker Compose >= 1.6](https://docs.docker.com/engine/)

Now you should be able to build and start vutuv with this command:
```bash
$ docker-compose up -d
```

Docker Compose already configures a mariadb database for you, installs all required dependencies and migrates the database schema. You can access the application as usual on http://localhost:4000

### Run tests with docker

To execute the tests, first connect to the running app container and run them inside the container:
```bash
$ docker exec -it vutuv_app_1 bash
$ MIX_ENV=test mix test
```

## Configure your SMTP setup

The system uses the [Bamboo](https://github.com/thoughtbot/bamboo) email
library by [thoughtbot](https://thoughtbot.com/) to send emails via SMTP.

### Development

In the development environment emails are not sent to an actual SMTP
server but displayed in the browser via [Bamboo.EmailPreviewPlug](https://hexdocs.pm/bamboo/Bamboo.EmailPreviewPlug.html). To see which emails have been send you have to visit http://localhost:4000/sent_emails

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

## Start the application without Docker

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

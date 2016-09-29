[![Stories in Ready](https://badge.waffle.io/vutuv/vutuv.png?label=ready&title=Ready)](https://waffle.io/vutuv/vutuv)
[![Build
Status](https://travis-ci.org/vutuv/vutuv.svg?branch=master)](https://travis-ci.org/vutuv/vutuv)

# vutuv
vutuv is a social network service to host and share information about humans and organizations.

# Before you start

Make sure you're running the latest version of erlang/elixir. You can download it [here.](http://elixir-lang.org/install.html)

This is a [Phoenix Framework](http://www.phoenixframework.org/) application. Please install it before going forward.

Make sure that your database configuration in `config/dev.exs` is correct (we use MySQL by default).

# Create your secret config

In order to compile your application, You'll need to create a secret.config file.
This file isn't included with the source files. It wouldn't be secret if it was! 
You'll need to create it manually. Browse to `/config` and create two files named 
`dev.secret.exs` and `prod.secret.exs` They should each look like this:
```
use Mix.Config
```
You should now be able to run the application by following the steps below.

# Run the application

```bash
$ cd vutuv
$ mix deps.get
$ mix deps.compile
$ npm install
$ mix ecto.create
$ mix ecto.migrate
$ mix phoenix.server
```

# First steps in the application

You need to register as a new user on http://localhost:4000

After creating a couple of example users you can login to them and
connect to other others by browsing to their page
e.g. http://localhost:4000/users/1 and click on the "Follow" button.

To view the admin control panel, you'll need to flag your account as an admin. This can be done with the following sql query:
`update users set administrator = true where id = <user_id>;`
replacing `<user_id>` with your user id.

You can then view the admin control panel at http://localhost:4000/admin

# Configuring your secret config

An example secret config looks like this
```
use Mix.Config

config :vutuv, Vutuv.Endpoint,
  facebook_client_id: "<client id>",
  facebook_client_secret: "<secret key>"
```

To use facebook login, sign up for facebook's api to get your own client id and secret key,
then replace the placeholders in the above example with the respective information. You will
also need to do some configuration in facebook's developer portal to match your host machine's
configuration. For more information refer to facebooks documentation on their developer
portal [here](https://developers.facebook.com/docs/apps/register).

# Do you want to participate?

Great! This is an open-source project. Please feel free to create a pull request for stuff you want to change.
And please do add an issue for any problem or feature request.

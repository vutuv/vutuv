[![Stories in Ready](https://badge.waffle.io/vutuv/vutuv.png?label=ready&title=Ready)](https://waffle.io/vutuv/vutuv)
[![Build
Status](https://travis-ci.org/vutuv/vutuv.svg?branch=master)](https://travis-ci.org/vutuv/vutuv)

# vutuv
vutuv is a social network service to host and share information about humans and organizations.

# Before you start

Make sure you're running the latest version of erlang/elixir. You can download it (here.)[http://elixir-lang.org/install.html]

This is a [Phoenix Framework](http://www.phoenixframework.org/) application. Please install it before going forward.

Make sure that your database configuration in `config/dev.exs` is correct (we use MySQL by default).

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

# Do you want to participate?

Great! This is an open-source project. Please feel free to create a pull request for stuff you want to change.
And please do add an issue for any problem or feature request.

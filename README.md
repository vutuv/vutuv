[![Stories in Ready](https://badge.waffle.io/vutuv/vutuv.png?label=ready&title=Ready)](https://waffle.io/vutuv/vutuv)
[![Build
Status](https://travis-ci.org/vutuv/vutuv.svg?branch=master)](https://travis-ci.org/vutuv/vutuv)

# vutuv
vutuv is a social network service to host and share information about humans and organizations.

# Run the application

This is a [Phoenix Framework](http://www.phoenixframework.org/) application. Please install it before going forward.

Make sure that your database configuration in `config/dev.exs` is correct.

```bash
$ cd vutuv
$ mix deps.get
$ npm install
$ mix ecto.create
$ mix ecto.migrate
$ mix phoenix.server
```

# Do you want to participate?

Great! This is an open-source project. Please feel free to create a pull request for stuff you want to change. 
And please do add an issue for any problem or feature request.

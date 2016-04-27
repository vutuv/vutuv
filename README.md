[![Stories in Ready](https://badge.waffle.io/vutuv/vutuv.png?label=ready&title=Ready)](https://waffle.io/vutuv/vutuv)

# vutuv
vutuv is a social network service to host and share information about humans and organizations.

# Run the application

This is a [Phoenix Framework](http://www.phoenixframework.org/) application. Please install it before going forward.

Make sure that your database configuration in `config/dev.exs` is correct.

```bash
$ cd vutuv
$ mix deps.get
$ mix ecto.create
$ mix ecto.migrate
$ mix phoenix.server
```

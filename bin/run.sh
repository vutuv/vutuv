#!/bin/sh

mix ecto.create
mix ecto.migrate

mix phoenix.server

# Vutuv API

This guide provides a brief overview of the Vutuv API.

## Routes

Run `mix phx.routes` to get the list of routes. All the routes that start with `api/v2`
are the API routes.

In development, the base url for all these routes is "http://localhost:4000/".

## Authorization

To access protected resources, you will get a token, by logging in, and use this token
when accessing the resource. See the examples section below for examples of how you
can do this with cURL.

In general, you can view resources without being logged in, but if you want to create,
update or delete resources, then you need to be authenticated.

## Examples with cURL

With all of the examples below, add `-v` for verbose information.

### Read user data

To list users:

`curl http://localhost:4000/api/v2/users`

To see a certain user's data (in this case, user 2):

`curl http://localhost:4000/api/v2/users/2`

### Create user data

The following command creates a user:

`curl -H "Content-Type: application/json" -d '{"user":{"email":"arrr@example.com","password":"reallyHard2gue$$","gender":"male","full_name":"Arrr Arrr"}}' http://localhost:4000/api/v2/users`

### Logging in

The following command logs in a user and returns {"access_token":_token_}:

`curl -H "Content-Type: application/json" -d '{"email":"jane.doe@example.com","password":"reallyHard2gue$$"}' http://localhost:4000/api/v2/sessions`

### Using the token to access other data

First, save the token value, by running the command `export token=token_value`

Then, by using `-H token` in the curl command, you can access email_address data
and update, or delete, user data.

For example, the next command updates the user by adding a preferred_name:

`curl -X PUT -H "Content-Type: application/json" -H token -d '{"user":{"preferred_name":"franniepoohs"}}' http://localhost:4000/api/v2/users/1`

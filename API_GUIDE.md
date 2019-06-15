# Vutuv API

This guide provides a brief overview of the Vutuv API.

## Routes

Below is a list of api routes. The base url for each route, in development, is
"http://localhost:4000/api/v1".

| Route | Action | Method | Authorization |
| :---- | :----- | :----- | :---------- |
| "/users" | List users | GET | None |
| "/users/:id" | Show user data | GET | None |
| "/users" | Create user | POST | None |
| "/users/:id" | Update user data | PUT | Token |
| "/users/:id" | Delete user data | DELETE | Token |
| "/sessions" | Create session | POST | Email address and password |
| "/users/:user_id/email_addresses" | List email addresses | GET | Token |
| "/users/:user_id/email_addresses/:id" | Show email address data | GET | Token |
| "/users/:user_id/email_addresses" | Create email address | POST | Token |
| "/users/:user_id/email_addresses/:id" | Update email address data | PUT | Token |
| "/users/:user_id/email_addresses/:id" | Delete email address data | DELETE | Token |

## Examples with cURL

With all of the examples below, add `-v` for verbose information.

### Read user data

To list users:

`curl http://localhost:4000/api/v1/users`

To see a certain user's data (in this case, user 2):

`curl http://localhost:4000/api/v1/users/2`

### Create user data

The following command creates a user:

`curl -H "Content-Type: application/json" -d '{"user":{"email":"arrr@example.com","password":"reallyHard2gue$$","profile":{"gender":"male","full_name":"Arrr Arrr"}}}' http://localhost:4000/api/v1/users`

### Logging in

The following command logs in a user and returns {"access_token":_token_}:

`curl -H "Content-Type: application/json" -d '{"email":"jane.doe@example.com","password":"reallyHard2gue$$"}' http://localhost:4000/api/v1/sessions`

### Using the token to access other data

First, save the token value, by running the command `export token=token_value`

Then, by using `-H token` in the curl command, you can access email_address data
and update, or delete, user data.

For example, the next command updates the user by adding a preferred_name:

`curl -X PUT -H "Content-Type: application/json" -H token -d '{"user":{"profile":{"preferred_name":"franniepoohs"}}}' http://localhost:4000/api/v1/users/1`

# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# It is also run when you use `mix ecto.setup` or `mix ecto.reset`
#

users = [
  %{
    "email" => "jane.doe@example.com",
    "password" => "password",
    "gender" => "female",
    "first_name" => "jane",
    "last_name" => "doe"
  },
  %{
    "email" => "john.smith@example.org",
    "password" => "password",
    "gender" => "male",
    "first_name" => "john",
    "last_name" => "smith"
  }
]

for user <- users do
  {:ok, user} = Vutuv.Accounts.create_user(user)
  Vutuv.Accounts.confirm_user_email(user)
end

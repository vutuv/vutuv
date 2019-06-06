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
    "first_name" => "Jane",
    "last_name" => "Doe"
  },
  %{
    "email" => "john.smith@example.org",
    "password" => "password",
    "gender" => "male",
    "first_name" => "John",
    "last_name" => "Smith"
  }
]

for user <- users do
  {:ok, %{email_addresses: [email_address]} = user} = Vutuv.Accounts.create_user(user)
  Vutuv.Accounts.confirm_user(user)
  Vutuv.Accounts.confirm_email_address(email_address)

  Vutuv.Accounts.create_email_address(user, %{
    "value" => "#{user.profile.first_name}_123@example.com"
  })
end

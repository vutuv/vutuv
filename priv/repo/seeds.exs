# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# It is also run when you use `mix ecto.setup` or `mix ecto.reset`
#

users = [
  %{
    "email" => "jane.doe@example.com",
    "password" => "reallyHard2gue$$",
    "profile" => %{
      "gender" => "female",
      "full_name" => "Jane Doe"
    }
  },
  %{
    "email" => "john.smith@example.org",
    "password" => "reallyHard2gue$$",
    "profile" => %{
      "gender" => "male",
      "full_name" => "John Smith"
    }
  }
]

for user <- users do
  {:ok, %{email_addresses: [email_address]} = user} = Vutuv.Accounts.create_user(user)
  Vutuv.Accounts.confirm_user(user)
  Vutuv.Accounts.confirm_email_address(email_address)

  name = String.replace(user.profile.full_name, " ", ".")

  Vutuv.Accounts.create_email_address(user, %{
    "value" => "#{name}_123@example.com"
  })
end

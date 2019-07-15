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
    "full_name" => "Jane Doe",
    "gender" => "female"
  },
  %{
    "email" => "john.smith@example.org",
    "password" => "reallyHard2gue$$",
    "full_name" => "John Smith",
    "gender" => "male"
  }
]

for user <- users do
  {:ok, %{email_addresses: [email_address], user_credential: user_credential} = user} =
    Vutuv.Accounts.create_user(user)

  Vutuv.Accounts.confirm_user(user_credential)
  Vutuv.Accounts.confirm_email_address(email_address)
  name = String.replace(user.full_name, " ", ".")

  Vutuv.Accounts.create_email_address(user, %{
    "value" => "#{name}_123@example.com"
  })

  Vutuv.Socials.create_post(user, %{
    body: String.duplicate("Blablabla ", 25),
    title: "Something to do with #{user.full_name}",
    visibility_level: "public"
  })
end

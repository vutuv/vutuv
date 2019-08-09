defmodule VutuvWeb.AuthTestHelpers do
  use Phoenix.ConnTest

  alias Vutuv.{Accounts, Sessions}
  alias VutuvWeb.Auth.Token

  def add_user(email) do
    user_params = %{
      "email" => email,
      "password" => "reallyHard2gue$$",
      "gender" => Enum.random(["female", "male"]),
      "full_name" => "#{Faker.Name.first_name()} #{Faker.Name.last_name()}"
    }

    {:ok, user} = Accounts.create_user(user_params)
    user
  end

  def gen_key(email), do: Token.sign(%{"email" => email})

  def add_user_confirmed(email) do
    %{email_addresses: [email_address]} = user = add_user(email)

    %{"user_id" => user.id}
    |> Accounts.get_user_credential!()
    |> Accounts.confirm_user()

    Accounts.verify_email_address(email_address)
    user
  end

  def add_reset_user(email), do: add_user_confirmed(email)

  def add_session(conn, user) do
    {:ok, %{id: session_id}} = Sessions.create_session(%{user_id: user.id})

    conn
    |> put_session(:phauxth_session_id, session_id)
    |> configure_session(renew: true)
  end

  def add_token_conn(conn, user) do
    {:ok, %{id: session_id}} = Sessions.create_session(%{user_id: user.id})
    user_token = Token.sign(%{"session_id" => session_id})

    conn
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", user_token)
  end
end

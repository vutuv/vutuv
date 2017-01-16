defmodule Vutuv.Auth do
  import Ecto.Query
  alias Plug.Conn

  def login(conn, user) do
    user = validate_user(user)
    conn
    |> Conn.assign(:current_user, user)
    |> Conn.put_session(:user_id, user.id)
    |> Conn.configure_session(renew: true)
  end

  def login_by_email(conn, email) do
    email = String.downcase(email)

    Vutuv.User
    |> join(:inner, [u], e in assoc(u, :emails))
    |> where([u, e], e.value == ^email)
    |> Vutuv.Repo.one()
    |> send_email(Vutuv.Auth.logout(conn), email)
  end

  defp send_email(nil, conn, _), do: {:error, :not_found, conn}

  defp send_email(user, conn, email) do
    case Plug.Conn.get_req_header(conn, "x-iorg-fbs") do #checks for header indicating user is a free basic member
      ["true"] -> #if user is free basic, send free basic email
        Vutuv.MagicLinkHelpers.gen_magic_link(user, "login")
        |> Vutuv.Emailer.fbs_login_email(email, user)
        |> Vutuv.Mailer.deliver_now
        {:ok, put_pin_cookie(conn, email)}
      _ ->
        Vutuv.MagicLinkHelpers.gen_magic_link(user, "login")
        |> Vutuv.Emailer.login_email(email, user)
        |> Vutuv.Mailer.deliver_now
        {:ok, conn}
    end
  end

  def logout(conn) do
    conn
    |> Conn.configure_session(drop: true)
    |> Conn.delete_session(:user_id)
  end

  defp validate_user(user) do
    user
    |> Ecto.Changeset.cast(%{validated?: true}, [:validated?])
    |> Vutuv.Repo.update!
  end

  defp put_pin_cookie(conn, email) do
    salt = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:secret_key_base]
    payload = Phoenix.Token.sign(conn, salt, email)
    conn
    |> Plug.Conn.delete_resp_cookie("_vutuv_fbs_temp", max_age: 1800)
    |> Plug.Conn.put_resp_cookie("_vutuv_fbs_temp", payload, max_age: 1800)
  end
end
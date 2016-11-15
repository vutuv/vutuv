defmodule Vutuv.Plug.RequireUserLoggedOut do  
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    logged_in?(conn, conn.assigns[:current_user])
  end

  defp logged_in?(conn, nil), do: conn
  defp logged_in?(conn, user) do
    conn
    #|> Phoenix.Controller.put_flash(:error, "You must be logged out to do this")
    |> Phoenix.Controller.redirect(to: Vutuv.Router.Helpers.user_path(conn, :show, user))
    |> halt
  end
end
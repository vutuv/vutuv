defmodule Vutuv.Plug.RequireUserLoggedOut do  
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    logged_in?(conn, get_session(conn, :user_id))
  end

  defp logged_in?(conn, nil), do: conn
  defp logged_in?(conn, _) do
    redirect(conn, conn.assigns[:current_user])
  end

  defp redirect(conn, nil), do: conn 
  defp redirect(conn, user) do
    conn
    |> Phoenix.Controller.redirect(to: Vutuv.Router.Helpers.user_path(conn, :show, user))
    |> halt
  end

end
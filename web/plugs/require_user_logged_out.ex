defmodule Vutuv.Plug.RequireUserLoggedOut do  
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    logged_in?(conn, get_session(conn, :user_id))
  end

  defp logged_in?(conn, nil), do: conn
  defp logged_in?(conn, _) do
    conn
    |> Phoenix.Controller.redirect(to: Vutuv.Router.Helpers.user_path(conn, :show, conn.assigns[:current_user]))
    |> halt
  end
end
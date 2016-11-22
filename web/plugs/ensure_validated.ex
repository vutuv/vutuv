defmodule Vutuv.Plug.EnsureValidated do
  import Plug.Conn
  
  def init(opts) do

  end

  def call(conn, repo) do
    conn.assigns[:user]
    |> validated?(conn)
  end

  defp validated?(_, conn), do: conn

  defp not_found(conn) do
    conn
    |> put_status(404)
    |> Phoenix.Controller.render(Vutuv.ErrorView, "404.html")
    |> halt
  end
end

defmodule Vutuv.Plug.EnsureValidated do
  import Plug.Conn
  
  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    conn.assigns[:user]
    |> validated?(conn)
  end

  defp validated?(%Vutuv.User{validated?: true}, conn), do: conn

  defp validated?(%Vutuv.User{validated?: nil}, conn), do: conn

  defp validated?(_, conn), do: not_found(conn)

  defp not_found(conn) do
    conn
    |> put_status(404)
    |> Phoenix.Controller.render(Vutuv.ErrorView, "404.html")
    |> halt
  end
end

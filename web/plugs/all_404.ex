defmodule Vutuv.Plug.All404 do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _) do
    conn
    |> put_status(404)
    |> Phoenix.Controller.render(Vutuv.ErrorView, "404.html")
    |> halt
  end
end

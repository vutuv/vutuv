defmodule Vutuv.Plug.AuthUser do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts) do
  	opts
  end

  def call(conn, _default) do
    if(conn.assigns[:user].id == conn.assigns[:current_user].id) do
      conn
    else
      conn
      |> put_status(403)
      |> render(Vutuv.ErrorView, "403.html")
      |> halt
    end
  end
end

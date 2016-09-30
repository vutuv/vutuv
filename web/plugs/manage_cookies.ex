defmodule Vutuv.Plug.ManageCookies do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    IO.puts "\n\n#{inspect conn}\n\n"
    if(conn.assigns[:current_user]) do
      conn
    else
       configure_session(conn, ignore: true)
    end
  end
end
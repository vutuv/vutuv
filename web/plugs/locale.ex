defmodule Vutuv.Plug.Locale do  
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    loc = Plug.Conn.get_req_header(conn,"accept-language")
    |>hd
    |>String.split(",")
    |>hd
    assign(conn, :locale, loc)
  end
end
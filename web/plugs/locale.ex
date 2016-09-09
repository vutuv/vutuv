defmodule Vutuv.Plug.Locale do  
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    loc = Plug.Conn.get_req_header(conn,"accept-language")
    |>hd
    |>String.split(",")
    |>hd
    IO.puts inspect Plug.Conn.get_req_header(conn,"accept-language")
    IO.puts loc
    Gettext.put_locale(Vutuv.Gettext, loc)
    assign(conn, :locale, loc)
  end
end
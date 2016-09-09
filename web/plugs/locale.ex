defmodule Vutuv.Plug.Locale do  
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    loc = Plug.Conn.get_req_header(conn,"accept-language")
    |>hd
    |>String.split(",")
    |>hd
    IO.puts "\n\n"<>loc<>"\n\n"
    assign(conn, :locale, loc)
  end
end
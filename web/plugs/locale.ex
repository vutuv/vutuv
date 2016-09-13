defmodule Vutuv.Plug.Locale do  
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    locs = Plug.Conn.get_req_header(conn,"accept-language")
    |>hd
    |>String.split(",")
    r = Enum.reduce([{nil, false}|locs], fn f, acc ->
      case acc do
        {_, false} ->
          loc = String.split(f,";")
          |>hd
          |>String.split("-")
          |>hd
          if locale_supported?(loc), do: {loc, true}, else: {nil, false}
        {_, true} -> acc
      end
    end) 
   loc = case r do
      {loc, true} -> loc
      _ -> 
        locs
        |>hd
        |>String.split("-")
        |>hd
    end
    IO.puts "\n\n#{loc}\n\n"
    Gettext.put_locale(Vutuv.Gettext, loc)
    assign(conn, :locale, loc)
  end

  def locale_supported?(loc) do
    {:ok, config} = Application.fetch_env(:vutuv, Vutuv.Endpoint)
    supported_locales = config[:locales]
    Enum.any?(supported_locales,fn f -> String.contains?(loc,f) end)
  end
end
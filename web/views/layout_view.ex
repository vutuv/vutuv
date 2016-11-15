defmodule Vutuv.LayoutView do
  use Vutuv.Web, :view
  import Vutuv.UserHelpers

  defp embed_css(conn) do
    filepath = "/home/vutuv/Github/vutuv/priv/static/css/app.css"
    debug = ~s[<!--
      file debug\n
      filepath #{inspect filepath}\n
      filepath exists?: #{inspect(File.exists?(filepath))}\n
      -->\n
    ]
    case File.read(filepath) do
      {:ok, data} -> "#{debug}<style>\n#{data}\n</style>"
      {:error, _} -> "#{debug}<link rel=\"stylesheet\" href=\"#{static_path(conn, "/css/app.css")}\">"
    end
    |> raw
  end
end

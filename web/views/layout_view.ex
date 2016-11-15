defmodule Vutuv.LayoutView do
  use Vutuv.Web, :view
  import Vutuv.UserHelpers

  defp embed_css(conn) do
    filepath = "/home/vutuv/Github/vutuv/priv/static/css/app.css"
    alt_filepath = Mix.Project.app_path<>"/priv/static"<>static_path(conn, "/css/app.css")
    debug = ~s[<!--
      file debug\n
      filepath #{inspect filepath}\n
      filepath2 #{inspect alt_filepath}\n
      filepath exists?: #{inspect(File.exists?(filepath))}\n
      filepath2 exists?: #{inspect(File.exists?(alt_filepath))}\n
      -->\n
    ]
    case File.read(filepath) do
      {:ok, data} -> "#{debug}<style>\n#{data}\n</style>"
      {:error, _} -> "#{debug}<link rel=\"stylesheet\" href=\"#{static_path(conn, "/css/app.css")}\">"
    end
    |> raw
  end
end

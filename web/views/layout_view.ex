defmodule Vutuv.LayoutView do
  use Vutuv.Web, :view
  import Vutuv.UserHelpers

  defp embed_css(conn) do
    filepath = File.cwd!<>static_path(conn, "/css/app.css")
    debug = ~s[<!--
      file debug\n
      just static_path: #{inspect(static_path(conn, "/css/app.css"))}\n
      static_path with /priv/static appended: #{inspect("/priv/static"<>static_path(conn, "/css/app.css"))}\n
      static_path priv/static and cwd: #{inspect(File.cwd!<>"/priv/static"<>static_path(conn, "/css/app.css"))}\n
      static_path with cwd: #{inspect(File.cwd!<>static_path(conn, "/css/app.css"))}\n
      cwd: #{inspect(File.cwd!)}\n
      -->\n
    ]
    case File.read(filepath) do
      {:ok, data} -> "#{debug}<style>\n#{data}\n</style>"
      {:error, _} -> "#{debug}<link rel=\"stylesheet\" href=\"#{static_path(conn, "/css/app.css")}\">"
    end
    |> raw
  end
end

defmodule Vutuv.LayoutView do
  use Vutuv.Web, :view
  import Vutuv.UserHelpers

  defp embed_css(conn) do
    filepath = File.cwd!<>static_path(conn, "/css/app.css")
    debug = ~s[<!--
      file debug\n
      just static_path: #{File.exists?(static_path(conn, "/css/app.css"))}\n
      static_path with /priv/static appended: #{File.exists?("/priv/static"<>static_path(conn, "/css/app.css"))}\n
      static_path priv/static and cwd: #{File.exists?(File.cwd!<>"/priv/static"<>static_path(conn, "/css/app.css"))}\n
      static_path with cwd: #{File.exists?(File.cwd!<>static_path(conn, "/css/app.css"))}\n
      cwd: #{File.exists?(File.cwd!)}\n
      -->\n
    ]
    case File.read(filepath) do
      {:ok, data} -> "#{debug}<style>\n#{data}\n</style>"
      {:error, _} -> "#{debug}<link rel=\"stylesheet\" href=\"#{static_path(conn, "/css/app.css")}\">"
    end
    |> raw
  end
end

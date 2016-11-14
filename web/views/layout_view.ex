defmodule Vutuv.LayoutView do
  use Vutuv.Web, :view
  import Vutuv.UserHelpers

  defp embed_css(conn) do
    base = "data:text/css;charset=utf-8;base64,"
    filepath = File.cwd!<>"/priv/static"<>static_path(conn, "/css/app.css")
    case File.read(filepath) do
      {:ok, data} -> "<link rel=\"stylesheet\" href=\"#{base}#{Base.encode64(data)}\">"
      {:error, _} -> "<link rel=\"stylesheet\" href=\"#{filepath}\">"
    end
    |> raw
  end
end

defmodule Vutuv.UrlView do
  use Vutuv.Web, :view
  import Vutuv.UserHelpers

  def linkable_url(string) do
    if Enum.count(String.split(string, "://")) > 1 do
      string
    else
      "http://#{string}"
    end
  end
end

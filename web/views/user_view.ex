defmodule Vutuv.UserView do
  use Vutuv.Web, :view
  import Vutuv.UserHelpers
  import Phoenix.HTML.SimplifiedHelpers.TimeAgoInWords

  def avatar_url(user) do
    Vutuv.Avatar.url({user.avatar, user}, :original)
    |> String.replace("web/static/assets", "")
  end
end

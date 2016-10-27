defmodule Vutuv.UserView do
  use Vutuv.Web, :view
  import Vutuv.UserHelpers
  alias Vutuv.UserSkill
  alias Vutuv.Endorsement
  alias Vutuv.Skill

  def avatar_url(user) do
    Vutuv.Avatar.url({user.avatar, user}, :original)
    |> String.replace("web/static/assets", "")
  end
end

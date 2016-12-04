defmodule Vutuv.UserSkillView do
  use Vutuv.Web, :view
  import Vutuv.UserHelpers
  alias Vutuv.Skill

  def render_upvotes(number) do
    case {number} do
      {1} ->
        ['1 ', Vutuv.Gettext.gettext("upvote")]
      {number} when is_integer(number) ->
        [Integer.to_string(number), ' ', Vutuv.Gettext.gettext("upvotes")]
      _ ->
        []
    end
  end

end

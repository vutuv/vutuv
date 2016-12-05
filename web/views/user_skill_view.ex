defmodule Vutuv.UserSkillView do
  use Vutuv.Web, :view
  import Vutuv.UserHelpers
  alias Vutuv.Skill

  def render_upvotes(0) do
    []
  end

  def render_upvotes(1) do
    ['1 ', Vutuv.Gettext.gettext("upvote")]
  end

  def render_upvotes(number) when is_integer(number) do
    [Integer.to_string(number), ' ', Vutuv.Gettext.gettext("upvotes")]
  end

end

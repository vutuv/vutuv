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

  def skill_error_tag(nil, _), do: nil

  def skill_error_tag(list, key) do
    if error = Keyword.get(list, key) do
      content_tag :span, translate_error(error), class: "editform__error"
    end
  end
end

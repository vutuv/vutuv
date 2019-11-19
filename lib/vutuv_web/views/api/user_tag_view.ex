defmodule VutuvWeb.Api.UserTagView do
  use VutuvWeb, :view
  alias VutuvWeb.Api.UserTagView

  def render("index.json", %{user_tags: user_tags}) do
    %{data: render_many(user_tags, UserTagView, "user_tag.json")}
  end

  def render("show.json", %{user_tag: user_tag}) do
    %{data: render_one(user_tag, UserTagView, "user_tag.json")}
  end

  def render("user_tag.json", %{user_tag: %{tag: tag} = user_tag}) do
    %{
      id: user_tag.id,
      tag_id: user_tag.tag_id,
      user_id: user_tag.user_id,
      tag: %{description: tag.description, name: tag.name}
    }
  end
end

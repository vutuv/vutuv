defmodule VutuvWeb.Api.UserTagEndorsementView do
  use VutuvWeb, :view
  alias VutuvWeb.Api.UserTagEndorsementView

  def render("index.json", %{user_tag_endorsements: user_tag_endorsements}) do
    %{
      data:
        render_many(user_tag_endorsements, UserTagEndorsementView, "user_tag_endorsement.json")
    }
  end

  def render("show.json", %{user_tag_endorsement: user_tag_endorsement}) do
    %{data: render_one(user_tag_endorsement, UserTagEndorsementView, "user_tag_endorsement.json")}
  end

  def render("user_tag_endorsement.json", %{user_tag_endorsement: user_tag_endorsement}) do
    %{
      id: user_tag_endorsement.id,
      user_id: user_tag_endorsement.user_id,
      user_tag_id: user_tag_endorsement.user_tag_id
    }
  end
end

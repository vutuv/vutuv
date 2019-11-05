defmodule VutuvWeb.Api.UserView do
  use VutuvWeb, :view

  alias VutuvWeb.Api.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      avatar: user.avatar,
      birthday: user.birthday,
      full_name: user.full_name,
      gender: user.gender,
      headline: user.headline,
      honorific_prefix: user.honorific_prefix,
      honorific_suffix: user.honorific_suffix,
      locale: user.locale,
      noindex: user.noindex,
      preferred_name: user.preferred_name,
      slug: user.slug,
      subscribe_emails: user.subscribe_emails
    }
  end
end

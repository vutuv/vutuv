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
    %{id: user.id, profile: %{full_name: user.profile.full_name}, slug: user.slug}
  end
end

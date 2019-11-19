defmodule VutuvWeb.Api.PostView do
  use VutuvWeb, :view
  alias VutuvWeb.Api.PostView

  def render("index.json", %{posts: posts}) do
    %{data: render_many(posts, PostView, "post.json")}
  end

  def render("show.json", %{post: post}) do
    %{data: render_one(post, PostView, "post.json")}
  end

  def render("post.json", %{post: post}) do
    %{
      id: post.id,
      body: post.body,
      title: post.title,
      user_id: post.user_id,
      visibility_level: post.visibility_level
    }
  end
end

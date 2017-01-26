defmodule Vutuv.Api.UserView do
  use Vutuv.Web, :view
  import Vutuv.Api.ApiHelpers

  @attributes ~w(
    first_name last_name middlename nickname honorific_prefix honorific_suffix gender
    birthdate
  )a
  @relationships ~w(
    emails
  )a

  def render("index.json", %{users: users}) do
    %{data: render_many(users, Vutuv.Api.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, Vutuv.Api.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id, type: "user"}
    |> put_attributes(user, @attributes)
    |> put_relationship(:emails, Vutuv.Api.EmailView, "index_lite.json", user)
    |> put_relationship(:work_experiences, Vutuv.Api.WorkExperienceView, "index_lite.json", user)
    |> put_relationship(:addresses, Vutuv.Api.AddressView, "index_lite.json", user)
    |> put_relationship(:phone_numbers, Vutuv.Api.PhoneNumberView, "index_lite.json", user)
    |> put_relationship(:social_media_accounts, Vutuv.Api.SocialMediaAccountView, "index_lite.json", user)
    |> put_relationship(:urls, Vutuv.Api.UrlView, "index_lite.json", user)
    #|> put_relationship(:user_tags, Vutuv.Api.UserTagView, "index.json", user)
    |> put_relationship(:followers, Vutuv.Api.FollowerView, "index_lite.json", user)
    |> put_relationship(:followees, Vutuv.Api.FolloweeView, "index_lite.json", user)
    |> put_relationship(:groups, Vutuv.Api.GroupView, "index_lite.json", user)
  end
end

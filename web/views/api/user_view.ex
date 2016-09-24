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
    %{id: user.id,
      type: "user",
      attributes: to_attributes(user, @attributes),
      relationships: %{
        emails: Vutuv.Api.EmailView.render("index_lite.json", user),
        work_experiences: Vutuv.Api.WorkExperienceView.render("index_lite.json", user),
        addresses: Vutuv.Api.AddressView.render("index_lite.json", user),
        phone_numbers: Vutuv.Api.PhoneNumberView.render("index_lite.json", user),
        social_media_accounts: Vutuv.Api.SocialMediaAccountView.render("index_lite.json", user),
        urls: Vutuv.Api.UrlView.render("index_lite.json", user),
        user_skills: Vutuv.Api.UserSkillView.render("index.json", user)
      }
    }
  end
end

defmodule VutuvWeb.Api.SocialMediaAccountView do
  use VutuvWeb, :view
  alias VutuvWeb.Api.SocialMediaAccountView

  def render("index.json", %{social_media_accounts: social_media_accounts}) do
    %{
      data:
        render_many(social_media_accounts, SocialMediaAccountView, "social_media_account.json")
    }
  end

  def render("show.json", %{social_media_account: social_media_account}) do
    %{data: render_one(social_media_account, SocialMediaAccountView, "social_media_account.json")}
  end

  def render("social_media_account.json", %{social_media_account: social_media_account}) do
    %{
      id: social_media_account.id,
      provider: social_media_account.provider,
      user_id: social_media_account.user_id,
      value: social_media_account.value
    }
  end
end

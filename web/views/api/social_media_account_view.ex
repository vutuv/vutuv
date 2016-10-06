defmodule Vutuv.Api.SocialMediaAccountView do
  use Vutuv.Web, :view
  import Vutuv.Api.ApiHelpers

  @attributes ~w(provider value)a


  def render("index.json", %{social_media_accounts: social_media_accounts}) do
    %{data: render_many(social_media_accounts, Vutuv.Api.SocialMediaAccountView, "social_media_account.json")}
  end
  
  def render("index_lite.json", %{social_media_accounts: social_media_accounts}) do
    %{data: render_many(social_media_accounts, Vutuv.Api.SocialMediaAccountView, "social_media_account_lite.json")}
  end

  def render("show.json", %{social_media_account: social_media_account}) do
    %{data: render_one(social_media_account, Vutuv.Api.SocialMediaAccountView, "social_media_account.json")}
  end

  def render("show_lite.json", %{social_media_account: social_media_account}) do
    %{data: render_one(social_media_account, Vutuv.Api.SocialMediaAccountView, "social_media_account_lite.json")}
  end

  def render("social_media_account.json", %{social_media_account: social_media_account} = params) do
    render("social_media_account_lite.json", params)
    |> put_attributes(social_media_account, @attributes)
  end

  def render("social_media_account_lite.json", %{social_media_account: social_media_account}) do
    %{id: social_media_account.id, type: "social_media_account"}
  end
end

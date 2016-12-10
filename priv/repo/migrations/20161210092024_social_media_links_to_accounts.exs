defmodule Vutuv.Repo.Migrations.SocialMediaLinksToAccounts do
  use Ecto.Migration
  import Ecto.Query

  def change do
  	urls = Vutuv.Repo.all(from u in Vutuv.Url, preload: [:user])
  	for(url <- urls) do
  		cond do
  			String.match?(url.value, ~r/.*(linkedin.com\/in\/).+/) -> migrate_url(url, ~r/.*(linkedin.com\/in\/)/, "LinkedIn")

  			String.match?(url.value, ~r/.*(xing.com\/profile\/).+/) -> migrate_url(url, ~r/.*(xing.com\/profile\/)/, "XING")

  			String.match?(url.value, ~r/.*(plus.google.com\/\+).+/) -> migrate_url(url, ~r/.*(plus.google.com\/\+)/, "Google+")

  			true -> :no_match
  		end
  	end
  	|> IO.inspect
  end

  def migrate_url(url, regex, provider) do
  	account = String.replace(url.value, regex, "")
  	Ecto.build_assoc(url.user, :social_media_accounts)
  	|> Vutuv.SocialMediaAccount.changeset(%{value: account, provider: provider})
  	|> Vutuv.Repo.insert
  	|> case do
  		{:ok, _} ->
  			Vutuv.Repo.delete(url)
  			:ok
  		{:error, changeset} -> :error
  	end
  end
end

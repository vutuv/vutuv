defmodule Vutuv.Repo.Migrations.AddSocialMediaUniqueIndex do
  use Ecto.Migration

  def change do
  	create unique_index(:social_media_accounts, [:value], unique: true)
  end
end

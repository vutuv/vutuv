defmodule Vutuv.Repo.Migrations.RenameMagicLinkExpirationColumn do
  use Ecto.Migration

  def change do
  	rename table(:users), :magic_link_expiration, to: :magic_link_created_at
  end
end

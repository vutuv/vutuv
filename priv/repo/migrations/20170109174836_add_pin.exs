defmodule Vutuv.Repo.Migrations.AddPin do
  use Ecto.Migration

  def change do
  	alter table(:magic_links) do
  		add :pin, :string
  		add :pin_created_at, :datetime
  		add :pin_login_attempts, :integer
  	end
  end
end

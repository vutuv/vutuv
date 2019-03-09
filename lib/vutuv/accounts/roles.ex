defmodule Vutuv.Accounts.Role do
  use Ecto.Schema
  import Ecto.Changeset


  schema "roles" do
    field :description, :string
    field :group_name, :string, default: "user"
    belongs_to :user, Vutuv.Accounts.User

    timestamps()
  end

  def changeset(role, attrs) do
    role
    |> cast(attrs, [:group_name, :description])
    |> validate_required([:group_name, :user_id, ])
    |> validate_length(:group_name, max: 80)
  end
end

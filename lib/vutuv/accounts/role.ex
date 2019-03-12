defmodule Vutuv.Accounts.Role do
  use Ecto.Schema
  import Ecto.Changeset

  alias Vutuv.Accounts.User

  schema "roles" do
    field :description, :string
    field :group_name, :string, default: "regular user"
    many_to_many :user, User, join_through: "user_roles"

    timestamps()
  end

  def changeset(role, attrs) do
    role
    |> cast(attrs, [:group_name, :description])
    |> validate_required([:group_name])
    |> validate_length(:group_name, max: 80)
  end
end

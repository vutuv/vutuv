defmodule Vutuv.Accounts.EmailAddress do
  use Ecto.Schema
  import Ecto.Changeset


  schema "email_addresses" do
    belongs_to :user, Vutuv.Accounts.User
    field :value, :string
    field :description, :string
    field :is_public, :boolean, default: true
    field :position, :integer
    field :verified, :boolean, default: false

    timestamps()
  end

  def changeset(email_address, attrs) do
    email_address
    |> cast(attrs, [:value, :user_id])
    |> validate_required([:value])
    |> validate_format(:value, ~r/^[A-Za-z0-9\._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$/)
    |> validate_length(:value, max: 255)
    |> unique_constraint(:value, downcase: true)
  end
end
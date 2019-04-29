defmodule Vutuv.Accounts.EmailAddress do
  use Ecto.Schema
  import Ecto.Changeset

  alias Vutuv.Accounts.User

  @type t :: %__MODULE__{
          id: integer,
          value: String.t(),
          user_id: integer,
          user: User.t() | %Ecto.Association.NotLoaded{},
          is_public: boolean,
          description: String.t(),
          position: integer,
          verified: boolean,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "email_addresses" do
    field :value, :string
    field :description, :string
    field :is_public, :boolean, default: true
    field :position, :integer
    field :verified, :boolean, default: false
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(email_address, attrs) do
    email_address
    |> cast(attrs, [:user_id, :value, :description, :is_public, :position])
    |> validate_required([:value])
    |> validate_format(:value, ~r/^[A-Za-z0-9\._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$/)
    |> validate_length(:value, max: 255)
    |> unique_constraint(:value, downcase: true)
  end

  def verify_changeset(%__MODULE__{} = email_address) do
    change(email_address, %{verified: true})
  end
end

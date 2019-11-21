defmodule Vutuv.Devices.EmailAddress do
  use Ecto.Schema

  import Ecto.Changeset

  alias Vutuv.UserProfiles.User

  @type t :: %__MODULE__{
          id: integer,
          value: String.t(),
          user_id: integer,
          user: User.t() | %Ecto.Association.NotLoaded{},
          is_public: boolean,
          description: String.t(),
          is_primary: boolean,
          verified: boolean,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "email_addresses" do
    field :value, :string
    field :description, :string
    field :is_public, :boolean, default: true
    field :is_primary, :boolean, default: false
    field :verified, :boolean, default: false

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%__MODULE__{} = email_address, attrs) do
    email_address
    |> cast(attrs, [:value, :description, :is_public, :is_primary])
    |> validate_required([:value])
    |> validate_format(
      :value,
      ~r/^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-\.]+\.[a-zA-Z]{2,}$/
    )
    |> validate_length(:value, max: 255)
    |> validate_length(:description, max: 255)
    |> unique_constraint(:value, downcase: true, message: "duplicate")
  end

  def create_changeset(%__MODULE__{} = email_address, attrs) do
    attrs = Map.delete(attrs, "is_primary")
    changeset(email_address, attrs)
  end

  def update_changeset(%__MODULE__{} = email_address, attrs) do
    if Map.has_key?(attrs, "value") do
      email_address
      |> change(attrs)
      |> add_error(:value, "the email_address value cannot be updated")
    else
      email_address
      |> cast(attrs, [:description, :is_public])
      |> validate_length(:description, max: 255)
    end
  end
end

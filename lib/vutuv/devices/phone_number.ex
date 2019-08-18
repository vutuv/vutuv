defmodule Vutuv.Devices.PhoneNumber do
  use Ecto.Schema
  import Ecto.Changeset

  alias Vutuv.UserProfiles.User

  @type t :: %__MODULE__{
          id: integer,
          user_id: integer,
          user: User.t() | %Ecto.Association.NotLoaded{},
          type: String.t(),
          value: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "phone_numbers" do
    field :type, :string
    field :value, :string

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%__MODULE__{} = phone_number, attrs) do
    phone_number
    |> cast(attrs, [:value, :type])
    |> update_change(:value, &String.trim/1)
    |> validate_required([:value, :type])
    |> validate_format(:value, ~r/^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\.\/0-9]*$/m)
  end

  @doc false
  def update_changeset(%__MODULE__{} = phone_number, attrs) do
    if Map.has_key?(attrs, "value") do
      phone_number
      |> change(attrs)
      |> add_error(:value, "the phone number value cannot be updated")
    else
      phone_number
      |> cast(attrs, [:value, :type])
      |> update_change(:value, &String.trim/1)
      |> validate_required([:value, :type])
      |> validate_format(:value, ~r/^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\.\/0-9]*$/m)
    end
  end
end

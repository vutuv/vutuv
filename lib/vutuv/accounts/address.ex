defmodule Vutuv.Accounts.Address do
  use Ecto.Schema

  import Ecto.Changeset

  alias Vutuv.Accounts.User

  @type t :: %__MODULE__{
          id: integer,
          city: String.t(),
          country: String.t(),
          description: String.t(),
          line_1: String.t(),
          line_2: String.t(),
          line_3: String.t(),
          line_4: String.t(),
          state: String.t(),
          zip_code: String.t(),
          user_id: integer,
          user: User.t() | %Ecto.Association.NotLoaded{},
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "addresses" do
    field :city, :string
    field :country, :string
    field :description, :string
    field :line_1, :string
    field :line_2, :string
    field :line_3, :string
    field :line_4, :string
    field :state, :string
    field :zip_code, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(address, attrs) do
    address
    |> cast(attrs, [
      :description,
      :line_1,
      :line_2,
      :line_3,
      :line_4,
      :zip_code,
      :city,
      :state,
      :country
    ])
    |> validate_required([:description, :country])
  end
end

defmodule Vutuv.MagicLink do
  use Vutuv.Web, :model

  schema "magic_links" do
    field :magic_link, :string
    field :magic_link_type, :string
    field :magic_link_created_at, Ecto.DateTime

    belongs_to :user, Vutuv.User
    timestamps 
  end

  @required_fields ~w()
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, [:magic_link, :magic_link_created_at, :magic_link_type])
  end
end

defmodule Vutuv.MagicLink do
  use Vutuv.Web, :model

  schema "magic_links" do
    field :value, :string
    field :magic_link, :string
    field :magic_link_type, :string
    field :magic_link_created_at, Ecto.DateTime
    field :pin, :string
    field :pin_created_at, Ecto.DateTime
    field :pin_login_attempts, :integer, default: 0


    belongs_to :user, Vutuv.User
    timestamps 
  end

  
  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:value, :magic_link, :magic_link_created_at, :magic_link_type, :pin, :pin_created_at, :pin_login_attempts])
  end
end

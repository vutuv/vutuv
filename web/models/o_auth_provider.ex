defmodule Vutuv.OAuthProvider do
  use Vutuv.Web, :model

  schema "oauth_providers" do
    field :provider_id, :string
    field :provider, :string

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
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:provider_id, :provider])
  end
end

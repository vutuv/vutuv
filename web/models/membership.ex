defmodule Vutuv.Membership do
  use Vutuv.Web, :model

  schema "memberships" do
    belongs_to :connection, Vutuv.Connection
    belongs_to :group, Vutuv.Group

    timestamps
  end

  @required_fields ~w(connection_id group_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields++@optional_fields)
  end
end

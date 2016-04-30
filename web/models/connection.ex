defmodule Vutuv.Connection do
  use Vutuv.Web, :model

  schema "connections" do
    belongs_to :follower, Vutuv.Follower
    belongs_to :followee, Vutuv.Followee

    timestamps
  end

  @required_fields ~w(follower_id followee_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

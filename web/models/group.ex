defmodule Vutuv.Group do
  use Vutuv.Web, :model

  schema "groups" do
    field :name, :string
    belongs_to :user, Vutuv.User
    has_many :memberships, Vutuv.Membership

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w(user_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields++@optional_fields)
  end


  def alphabetical(query) do
    from c in query, order_by: c.name
  end

  def names_and_ids(query) do
    from c in query, select: {c.name, c.id}
  end
end

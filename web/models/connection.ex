defmodule Vutuv.Connection do
  use Vutuv.Web, :model

  schema "connections" do
    belongs_to :follower, Vutuv.User
    belongs_to :followee, Vutuv.User

    has_many :memberships, Vutuv.Membership, on_delete: :delete_all
    has_many :groups, through: [:memberships, :group]

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
    |> cast(params, @required_fields++@optional_fields)
  end

  def latest(n) do
    Ecto.Query.from(u in Vutuv.Connection, order_by: [desc: :inserted_at], limit: ^n)
  end

  def contains(followee_id, follower_id) do
    Vutuv.Repo.one(from u in Vutuv.Connection, where: u.follower_id==^follower_id and u.followee_id==^followee_id, select: count("followee_id"))>=1
  end
end

defmodule Vutuv.Endorsement do
  use Vutuv.Web, :model

  schema "endorsements" do
    belongs_to :user, Vutuv.User
    belongs_to :user_skill, Vutuv.UserSkill

    timestamps
  end

  @required_fields ~w(user_id user_skill_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields++@optional_fields)
    |> unique_constraint(:user_id_user_skill_id)
  end

  def count(user_skill_id) do
    Vutuv.Repo.one!(from e in Vutuv.Endorsement, where: e.user_skill_id==^user_skill_id, select: count("*"))
  end

  def skill_endorsed?(user_skill_id, user_id) do
    Vutuv.Repo.one!(from e in Vutuv.Endorsement, where: e.user_skill_id==^user_skill_id and e.user_id==^user_id, select: count("*"))>0
  end

end

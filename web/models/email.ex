defmodule Vutuv.Email do
  use Vutuv.Web, :model

  schema "emails" do
    field :value, :string
    field :md5sum, :string
    belongs_to :user, Vutuv.User

    timestamps
  end

  @required_fields ~w(value)
  @optional_fields ~w(user_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> downcase_value
    |> validate_format(:value, ~r/@/)
    |> unique_constraint(:value)
    |> fill_md5sum
  end

  def downcase_value(changeset) do
    # If the value has been changed, downcase it.
    update_change(changeset, :value, &String.downcase/1)
  end

  def fill_md5sum(changeset) do
    # If the value has been changed, create md5sum.
    #
    if value = get_change(changeset, :value) do
      md5sum = :crypto.hash(:md5, value)
               |> Base.encode16
               |> String.downcase

      put_change(changeset, :md5sum, md5sum)
    else
      changeset
    end
  end

  def can_delete?(id) do
    Vutuv.Repo.one(from u in Vutuv.Email, where: u.user_id==^id, select: count("value"))>1
  end
end

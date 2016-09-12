defmodule Vutuv.Slug do
  use Vutuv.Web, :model
  alias Vutuv.Slug

  schema "slugs" do
    field :value, :string
    field :disabled, :boolean
    belongs_to :user, Vutuv.User
    timestamps
  end

  @required_fields ~w(value)
  @optional_fields ~w(id user_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> downcase_value
    |> validate_format(:value, ~r/^[a-z]{1}[a-z0-9-.]*$/u)
    |> unique_constraint(:value)
    |> validate_length(:value, min: 3)
    |> can_create_slug?(model)
  end

  def downcase_value(changeset) do
    # If the value has been changed, downcase it.
    update_change(changeset, :value, &String.downcase/1)
  end

  def can_create_slug?(changeset, model) do
    slug_count = 
    if(model.user_id != nil) do
      Vutuv.Repo.one(from s in Slug, where: s.user_id == ^model.user_id, select: count("*"))
    else
      0
    end
    if(slug_count == 0) do
      changeset
    else
      last_slug_inserted_days = 
          (:calendar.datetime_to_gregorian_seconds(:calendar.universal_time()) -
           :calendar.datetime_to_gregorian_seconds(
             Ecto.DateTime.to_erl(hd(Vutuv.Repo.all(from s in Slug, where: s.user_id == ^model.user_id, order_by: [desc: s.inserted_at], select: s.inserted_at)))))/86400
          
      user_age_days = 
          (:calendar.datetime_to_gregorian_seconds(:calendar.universal_time()) -
           :calendar.datetime_to_gregorian_seconds(Ecto.DateTime.to_erl(Vutuv.Repo.get(Vutuv.User, model.user_id).inserted_at)))/86400
          
      cond do
        slug_count<3 and user_age_days<30 -> changeset
        slug_count>=3 and last_slug_inserted_days>90 -> changeset
        true -> add_error(changeset, :value, "Reached max new slugs in time period.")
      end
    end
  end

end

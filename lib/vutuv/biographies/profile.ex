defmodule Vutuv.Biographies.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  alias Vutuv.Accounts.User

  @type t :: %__MODULE__{
          id: integer,
          user_id: integer,
          user: %Ecto.Association.NotLoaded{} | User.t(),
          first_name: String.t(),
          last_name: String.t(),
          middlename: String.t(),
          nickname: String.t(),
          gender: String.t(),
          birthday_day: integer,
          birthday_month: integer,
          birthday_year: integer,
          active_slug: String.t(),
          avatar: String.t(),
          headline: String.t(),
          honorific_prefix: String.t(),
          honorific_suffix: String.t(),
          locale: String.t(),
          noindex?: boolean,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "profiles" do
    belongs_to :user, User
    field :first_name, :string
    field :last_name, :string
    field :middlename, :string
    field :nickname, :string
    field :gender, :string
    field :birthday_day, :integer
    field :birthday_month, :integer
    field :birthday_year, :integer
    field :active_slug, :string
    field :avatar, :string
    field :headline, :string
    field :honorific_prefix, :string
    field :honorific_suffix, :string
    field :locale, :string
    field :noindex?, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [
      :first_name,
      :last_name,
      :middlename,
      :nickname,
      :honorific_prefix,
      :honorific_suffix,
      :gender,
      :birthday_day,
      :birthday_month,
      :birthday_year,
      :locale,
      :avatar,
      :active_slug,
      :headline,
      :noindex?
    ])
    |> validate_required([:gender])
    |> validate_first_name_or_last_name(attrs)
    |> validate_length(:first_name, max: 80)
    |> validate_length(:last_name, max: 80)
    |> validate_length(:middlename, max: 80)
    |> validate_length(:nickname, max: 80)
    |> validate_length(:honorific_prefix, max: 80)
    |> validate_length(:honorific_suffix, max: 80)
    |> validate_length(:headline, max: 255)
  end

  defp validate_first_name_or_last_name(changeset, %{}) do
    first_name = get_field(changeset, :first_name)
    last_name = get_field(changeset, :last_name)

    if first_name || last_name do
      changeset
    else
      message = "First name or last name must be present"

      changeset
      |> add_error(:first_name, message)
      |> add_error(:last_name, message)
    end
  end
end

defmodule Vutuv.Biographies.Profile do
  use Ecto.Schema
  import Ecto.Changeset
  use Arc.Ecto.Schema
  require VutuvWeb.Gettext
  @derive {Phoenix.Param, key: :active_slug}


  schema "profiles" do
    field :first_name, :string
    field :last_name, :string
    field :middlename, :string
    field :nickname, :string
    field :honorific_prefix, :string
    field :honorific_suffix, :string
    field :gender, :string
    field :birthday_day, :integer
    field :birthday_month, :integer
    field :birthday_year, :integer
    field :locale, :string
    field :avatar, Vutuv.Avatar.Type
    field :active_slug, :string
    field :headline, :string
    field :noindex?, :boolean, default: false
    field :validated?, :boolean, default: false
    belongs_to :user, Vutuv.Accounts.User

    timestamps()
  end

  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [:first_name, :last_name, :middlename, :nickname, :honorific_prefix, :honorific_suffix, :gender, :birthday_day, :birthday_month, :birthday_year, :locale, :avatar, :active_slug, :headline, :noindex?, :validated?, :send_birthday_reminder])
    |> validate_required([:user_id, :gender, :local, :birthday_day, :birthday_month])
    |> validate_first_name_or_last_name(attrs)
    |> validate_length(:first_name, max: 80)
    |> validate_length(:last_name, max: 80)
    |> validate_length(:middlename, max: 80)
    |> validate_length(:nickname, max: 80)
    |> validate_length(:honorific_prefix, max: 80)
    |> validate_length(:honorific_suffix, max: 80)
    |> validate_length(:headline, max: 255)
  end

  def gender_gettext("male") do
    VutuvWeb.Gettext.gettext("Male")
  end

  def gender_gettext("female") do
    VutuvWeb.Gettext.gettext("Female")
  end

  def gender_gettext(_) do
    VutuvWeb.Gettext.gettext("Other")
  end

  defp validate_first_name_or_last_name(changeset, %{}) do
    first_name = get_field(changeset, :first_name)
    last_name = get_field(changeset, :last_name)

    if first_name || last_name do
      # No error if any of those 2 are present.
      #
      changeset
    else
      # All the 2 fields are nil.
      #
      message = "First name or last name must be present"
      changeset
      |> add_error(:first_name, message)
      |> add_error(:last_name, message)
    end
  end
end

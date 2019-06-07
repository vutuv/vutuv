defmodule Vutuv.Biographies.Profile do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  alias Vutuv.Accounts.User
  alias Vutuv.Biographies.PhoneNumber
  alias Vutuv.Generals.Tag

  @type t :: %__MODULE__{
          id: integer,
          user_id: integer,
          user: User.t() | %Ecto.Association.NotLoaded{},
          full_name: String.t(),
          preferred_name: String.t(),
          gender: String.t(),
          birthday: Date.t(),
          active_slug: String.t(),
          avatar: String.t(),
          headline: String.t(),
          honorific_prefix: String.t(),
          honorific_suffix: String.t(),
          locale: String.t(),
          noindex?: boolean,
          phone_numbers: [PhoneNumber.t()] | %Ecto.Association.NotLoaded{},
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "profiles" do
    field :full_name, :string
    field :preferred_name, :string
    field :gender, :string
    field :birthday, :date
    field :active_slug, :string
    field :avatar, Vutuv.Avatar.Type
    field :headline, :string
    field :honorific_prefix, :string
    field :honorific_suffix, :string
    field :locale, :string
    field :noindex?, :boolean, default: false
    belongs_to :user, User
    has_many :phone_numbers, PhoneNumber, on_delete: :delete_all

    many_to_many :tags, Tag, join_through: "profile_tags", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [
      :full_name,
      :preferred_name,
      :honorific_prefix,
      :honorific_suffix,
      :gender,
      :birthday,
      :locale,
      :active_slug,
      :headline,
      :noindex?
    ])
    |> cast_attachments(attrs, [:avatar])
    |> validate_required([:full_name, :gender])
    |> validate_length(:full_name, max: 80)
    |> validate_length(:preferred_name, max: 80)
    |> validate_length(:honorific_prefix, max: 80)
    |> validate_length(:honorific_suffix, max: 80)
    |> validate_length(:headline, max: 255)
  end
end

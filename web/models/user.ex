defmodule Vutuv.User do
  use Vutuv.Web, :model
  use Arc.Ecto.Model

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :middlename, :string
    field :nickname, :string
    field :honorific_prefix, :string
    field :honorific_suffix, :string
    field :gender, :string
    field :birthdate, Ecto.Date
    field :verified, :boolean, default: false
    field :avatar, Vutuv.Avatar.Type
    field :magic_link, :string
    field :magic_link_expiration, Ecto.DateTime
    has_many :groups, Vutuv.Group, on_delete: :delete_all
    has_many :emails, Vutuv.Email, on_delete: :delete_all

    has_many :follower_connections, Vutuv.Connection, foreign_key: :followee_id, on_delete: :delete_all
    has_many :followers, through: [:follower_connections, :follower]

    has_many :followee_connections, Vutuv.Connection, foreign_key: :follower_id, on_delete: :delete_all
    has_many :followees, through: [:followee_connections, :followee]

    timestamps
  end

  @required_fields ~w()
  @optional_fields ~w(first_name last_name middlename nickname honorific_prefix honorific_suffix gender birthdate verified)

  @required_file_fields ~w()
  @optional_file_fields ~w(avatar)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_attachments(params, @required_file_fields, @optional_file_fields)
    |> cast_assoc(:emails)
    |> validate_first_name_or_last_name_or_nickname(params)
    |> validate_length(:first_name, max: 50)
    |> validate_length(:last_name, max: 50)
    |> validate_length(:middlename, max: 50)
    |> validate_length(:nickname, max: 50)
    |> validate_length(:honorific_prefix, max: 50)
    |> validate_length(:honorific_suffix, max: 50)
    |> validate_length(:gender, max: 50)
  end

  def validate_first_name_or_last_name_or_nickname(changeset, :empty) do
    changeset
  end

  def validate_first_name_or_last_name_or_nickname(changeset, _) do
    first_name = get_field(changeset, :first_name)
    last_name = get_field(changeset, :last_name)
    nickname = get_field(changeset, :nickname)

    if first_name || last_name || nickname do
      # No error if any of those 3 are present.
      #
      changeset
    else
      # All the 3 fields are nil.
      #
      message = "First name or last name or nickname must be present"
      changeset
      |> add_error(:first_name, message)
      |> add_error(:last_name, message)
      |> add_error(:nickname, message)  
    end
  end
end

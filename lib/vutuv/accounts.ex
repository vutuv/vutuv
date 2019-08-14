defmodule Vutuv.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto
  import Ecto.Query, warn: false

  alias Vutuv.{Downloads.GravatarWorker, Repo, Sessions, Sessions.Session, Tags.Tag}
  alias Vutuv.Accounts.{EmailAddress, PhoneNumber, User, UserCredential}

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  @doc """
  Returns a list of all users.
  """
  @spec list_users() :: [User.t()]
  def list_users() do
    Repo.all(User)
  end

  @doc """
  Returns a list of all users in a paginated struct.
  """
  @spec paginate_users(map) :: Scrivener.Page.t()
  def paginate_users(attrs) do
    Repo.paginate(User, attrs)
  end

  @doc """
  Gets a single user. Raises error if no user found.
  """
  @spec get_user!(map) :: User.t() | no_return
  def get_user!(%{"slug" => slug}) do
    Repo.get_by!(User, %{slug: slug})
  end

  def get_user!(%{"id" => user_id}) do
    Repo.get!(User, user_id)
  end

  def get_user!(%{"email" => email}) do
    %EmailAddress{user_id: user_id} = Repo.get_by!(EmailAddress, %{value: email})
    get_user!(%{"id" => user_id})
  end

  @doc """
  Gets a single user. Returns nil if no user found.
  """
  @spec get_user(integer) :: User.t() | nil
  def get_user(id) do
    Repo.get(User, id)
  end

  @doc """
  Gets a user based on the attrs.

  This is used by Phauxth to get user information.
  """
  @spec get_by(map) :: User.t() | nil
  def get_by(%{"session_id" => session_id}) do
    with %Session{user_id: user_id} <- Sessions.get_session(session_id),
         do: Repo.get(User, user_id)
  end

  @doc """
  Creates a user.
  """
  @spec create_user(map) :: {:ok, User.t()} | changeset_error
  def create_user(attrs) do
    email_attrs = %{
      "value" => attrs["email"],
      "position" => 1,
      "description" => "email when registering vutuv"
    }

    attrs =
      Map.merge(attrs, %{
        "email_addresses" => [email_attrs],
        "user_credential" => %{"password" => attrs["password"]}
      })

    with {:ok, user} <- %User{} |> User.create_changeset(attrs) |> Repo.insert(),
         {:ok, user} <- add_unique_slug(user) do
      GravatarWorker.fetch_gravatar({email_attrs["value"], user.id})
      {:ok, user}
    end
  end

  defp add_unique_slug(%{full_name: full_name} = user) do
    slug = Slugger.slugify_downcase(full_name, ?.)

    with {:error, _} <- update_user(user, %{"slug" => slug}) do
      prefix = Base.encode64(:crypto.strong_rand_bytes(6))
      update_user(user, %{"slug" => prefix <> "." <> slug})
    end
  end

  @doc """
  Updates a user.
  """
  @spec update_user(User.t(), map) :: {:ok, User.t()} | changeset_error
  def update_user(%User{} = user, attrs) do
    user |> User.changeset(attrs) |> Repo.update()
  end

  @doc """
  Deletes a user.
  """
  @spec delete_user(User.t()) :: {:ok, User.t()} | changeset_error
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  @spec change_user(User.t()) :: Ecto.Changeset.t()
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Confirms a user's account, setting the user_credential's confirmed value.
  """
  @spec confirm_user(UserCredential.t()) :: {:ok, UserCredential.t()} | changeset_error
  def confirm_user(user_credential) do
    user_credential |> UserCredential.confirm_changeset(true) |> Repo.update()
  end

  @doc """
  Updates a user's password.
  """
  @spec update_password(UserCredential.t(), map) :: {:ok, UserCredential.t()} | changeset_error
  def update_password(%UserCredential{user_id: user_id} = user_credential, attrs) do
    Sessions.delete_user_sessions(get_user!(%{"id" => user_id}))

    user_credential
    |> UserCredential.update_password_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Preloads a user(s) associations.
  """
  @spec with_associated_data(User.t(), list) :: User.t()
  def with_associated_data(%User{} = user, associations) do
    Repo.preload(user, associations)
  end

  @doc """
  Gets user credentials. Raises error if no user_credential found.
  """
  @spec get_user_credential!(map) :: UserCredential.t() | no_return
  def get_user_credential!(%{"email" => email}) do
    %EmailAddress{user_id: user_id} = Repo.get_by!(EmailAddress, %{value: email})
    get_user_credential!(%{"user_id" => user_id})
  end

  def get_user_credential!(%{"user_id" => user_id}) do
    Repo.get_by!(UserCredential, %{user_id: user_id})
  end

  @doc """
  Gets user credentials. Returns nil if no user_credential found.
  """
  @spec get_user_credential(map) :: UserCredential.t() | nil
  def get_user_credential(%{"email" => email}) do
    with %EmailAddress{user_id: user_id} <- Repo.get_by(EmailAddress, %{value: email}),
         do: get_user_credential(%{"user_id" => user_id})
  end

  def get_user_credential(%{"user_id" => user_id}) do
    Repo.get_by(UserCredential, %{user_id: user_id})
  end

  @doc """
  Adds an association between a user and existing tags.
  """
  @spec add_user_tags(User.t(), list) :: {:ok, User.t()} | changeset_error
  def add_user_tags(%User{} = user, tag_ids) do
    tags = Tag |> where([t], t.id in ^tag_ids) |> Repo.all()
    user |> Repo.preload([:tags]) |> User.user_tag_changeset(tags) |> Repo.update()
  end

  @doc """
  Returns a user's followers and leaders in a paginated struct.
  """
  @spec paginate_user_connections(User.t(), map, :followers | :leaders) :: Scrivener.Page.t()
  def paginate_user_connections(%User{} = user, attrs, connection) do
    user |> assoc(connection) |> Repo.paginate(attrs)
  end

  @doc """
  Adds leaders / followees to a user.

  If successful, the users in the leader_ids list will be added to the
  user's leaders. In addition, the user will be added to the followers
  list of the leaders.
  """
  @spec add_leaders(User.t(), list) :: {:ok, User.t()} | changeset_error
  def add_leaders(%User{} = user, leader_ids) do
    leaders = User |> where([l], l.id in ^leader_ids) |> Repo.all()

    user
    |> Repo.preload([:leaders])
    |> User.leader_changeset(leaders)
    |> Repo.update()
  end

  @doc """
  Returns a list of unverified email addresses.

  This is used by the EmailManager, which is responsible for handling
  unverified email addresses.
  """
  @spec unverified_email_addresses(integer) :: [EmailAddress.t()]
  def unverified_email_addresses(max_age) do
    inserted_at = DateTime.add(DateTime.utc_now(), -max_age)

    EmailAddress
    |> where([e], e.verified == false and e.inserted_at < ^inserted_at)
    |> Repo.all()
  end

  @doc """
  Returns a list of a user's email_addresses.
  """
  @spec list_email_addresses(User.t()) :: [EmailAddress.t()]
  def list_email_addresses(user) do
    Repo.all(assoc(user, :email_addresses))
  end

  @doc """
  Returns a list of a user's public email_addresses.
  """
  @spec list_email_addresses(User.t(), :public) :: [EmailAddress.t()]
  def list_email_addresses(user, :public) do
    user
    |> assoc(:email_addresses)
    |> where([e], e.is_public == true)
    |> Repo.all()
  end

  @doc """
  Gets an email_address from the email_address value.

  Only public email_addresses are returned. Returns nil if no email_address found.
  """
  @spec get_email_address(map) :: EmailAddress.t() | nil
  def get_email_address(%{"value" => value}) do
    Repo.get_by(EmailAddress, value: value, is_public: true)
  end

  @doc """
  Gets a specific user's email_address. Raises error if no email_address found.
  """
  @spec get_email_address!(User.t(), map) :: EmailAddress.t() | no_return
  def get_email_address!(%User{} = user, %{"id" => id}) do
    Repo.get_by!(EmailAddress, id: id, user_id: user.id)
  end

  @doc """
  Creates an email_address.
  """
  @spec create_email_address(User.t(), map) :: {:ok, EmailAddress.t()} | changeset_error
  def create_email_address(%User{} = user, attrs \\ %{}) do
    query = from e in EmailAddress, where: e.user_id == ^user.id
    email_count = Repo.aggregate(query, :count, :id)
    attrs = Map.put(attrs, "position", email_count + 1)

    user
    |> build_assoc(:email_addresses)
    |> EmailAddress.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an email_address.
  """
  @spec update_email_address(EmailAddress.t(), map) :: {:ok, EmailAddress.t()} | changeset_error
  def update_email_address(%EmailAddress{} = email_address, attrs) do
    email_address
    |> EmailAddress.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Verifies an email_address, setting the verified value to true.
  """
  @spec verify_email_address(EmailAddress.t()) :: {:ok, EmailAddress.t()} | changeset_error
  def verify_email_address(email_address) do
    email_address |> EmailAddress.verify_changeset() |> Repo.update()
  end

  @doc """
  Deletes an email_address.
  """
  @spec delete_email_address(EmailAddress.t()) :: {:ok, EmailAddress.t()} | changeset_error
  def delete_email_address(%EmailAddress{} = email_address) do
    Repo.delete(email_address)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking email_address changes.
  """
  @spec change_email_address(EmailAddress.t()) :: Ecto.Changeset.t()
  def change_email_address(%EmailAddress{} = email_address) do
    EmailAddress.changeset(email_address, %{})
  end

  def duplicate_email_error?(%Ecto.Changeset{changes: %{email_addresses: [email_address]}}) do
    Enum.any?(email_address.errors, fn {_, {msg, _}} -> msg == "duplicate" end)
  end

  def duplicate_email_error?(%Ecto.Changeset{errors: errors}) do
    Enum.any?(errors, fn {_, {msg, _}} -> msg == "duplicate" end)
  end

  def duplicate_email_error?(_), do: false

  @doc """
  Returns the list of phone_numbers.
  """
  @spec list_phone_numbers(User.t()) :: [PhoneNumber.t()]
  def list_phone_numbers(user) do
    Repo.all(assoc(user, :phone_number))
  end

  @doc """
  Gets a single phone_number. Raises error if no phone_number found.
  """
  @spec get_phone_number!(integer) :: PhoneNumber.t() | no_return
  def get_phone_number!(id), do: Repo.get!(PhoneNumber, id)

  @doc """
  Creates a phone_number.
  """
  @spec create_phone_number(User.t(), map) :: {:ok, PhoneNumber.t()} | changeset_error
  def create_phone_number(%User{} = user, attrs \\ %{}) do
    user
    |> build_assoc(:phone_numbers)
    |> PhoneNumber.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a phone_number.
  """
  @spec update_phone_number(PhoneNumber.t(), map) :: {:ok, PhoneNumber.t()} | changeset_error
  def update_phone_number(%PhoneNumber{} = phone_number, attrs) do
    phone_number
    |> PhoneNumber.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PhoneNumber.
  """
  @spec delete_phone_number(PhoneNumber.t()) :: {:ok, PhoneNumber.t()} | changeset_error
  def delete_phone_number(%PhoneNumber{} = phone_number) do
    Repo.delete(phone_number)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking phone_number changes.
  """
  @spec change_phone_number(PhoneNumber.t()) :: Ecto.Changeset.t()
  def change_phone_number(%PhoneNumber{} = phone_number) do
    PhoneNumber.changeset(phone_number, %{})
  end
end

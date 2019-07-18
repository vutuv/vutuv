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
    User |> user_query() |> Repo.all()
  end

  @doc """
  Returns a list of all users in a paginated struct.
  """
  @spec list_users(map) :: Scrivener.Page.t()
  def list_users(attrs) do
    User |> user_query() |> Repo.paginate(attrs)
  end

  @doc """
  Gets a single user.
  """
  @spec get_user(map) :: User.t() | nil
  def get_user(%{"slug" => slug}) do
    User |> where([u], u.slug == ^slug) |> user_query() |> Repo.one()
  end

  def get_user(%{"id" => user_id}) do
    User |> where([u], u.id == ^user_id) |> user_query() |> Repo.one()
  end

  def get_user(%{"session_id" => session_id}) do
    with %Session{user_id: user_id} <- Sessions.get_session(session_id),
         do: get_user(%{"id" => user_id})
  end

  def get_user(%{"email" => email}) do
    with %EmailAddress{user_id: user_id} <- Repo.get_by(EmailAddress, %{value: email}),
         do: get_user(%{"id" => user_id})
  end

  defp user_query(user) do
    user
    |> join(:left, [u], _ in assoc(u, :tags))
    |> preload([_, t], tags: t)
  end

  @doc """
  Gets a user based on the attrs.

  This is used by Phauxth to get user information.
  """
  @spec get_by(map) :: User.t() | nil
  def get_by(attrs), do: get_user(attrs)

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
    Sessions.delete_user_sessions(get_user(%{"id" => user_id}))

    user_credential
    |> UserCredential.update_password_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Gets user credentials.
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
  Updates the association between a user and already existing tags.
  """
  @spec update_user_tags(User.t(), list) :: {:ok, User.t()} | changeset_error
  def update_user_tags(%User{} = user, tag_ids) do
    tags = Tag |> where([t], t.id in ^tag_ids) |> Repo.all()
    user |> Repo.preload([:tags]) |> User.user_tag_changeset(tags) |> Repo.update()
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

  Only public email_addresses are returned.
  """
  @spec get_email_address(map) :: EmailAddress.t() | nil
  def get_email_address(%{"value" => value}) do
    EmailAddress
    |> where([e], e.value == ^value and e.is_public == true)
    |> Repo.one()
  end

  @doc """
  Gets a specific user's email_address.
  """
  @spec get_email_address(User.t(), map) :: EmailAddress.t() | nil
  def get_email_address(%User{} = user, %{"id" => id}) do
    user
    |> assoc(:email_addresses)
    |> where([e], e.id == ^id)
    |> Repo.one()
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
  Confirms an email_address, setting the verified value to true.
  """
  @spec confirm_email_address(EmailAddress.t()) :: {:ok, EmailAddress.t()} | changeset_error
  def confirm_email_address(email_address) do
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

  @doc """
  Returns the list of phone_numbers.
  """
  @spec list_phone_numbers(User.t()) :: [PhoneNumber.t()]
  def list_phone_numbers(user) do
    Repo.all(assoc(user, :phone_number))
  end

  @doc """
  Gets a single phone_number.
  """
  @spec get_phone_number(integer) :: PhoneNumber.t() | nil
  def get_phone_number(id), do: Repo.get(PhoneNumber, id)

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

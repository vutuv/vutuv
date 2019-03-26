defmodule Vutuv.Accounts do
  @moduledoc """
  The Accounts context.
  """
  import Ecto
  import Ecto.Query, warn: false

  alias Vutuv.{Accounts.User, Repo, Sessions, Sessions.Session, Accounts.EmailAddress}

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  @doc """
  Returns the list of users.
  """
  @spec list_users() :: [User.t()]
  def list_users() do
    Repo.all(
      from u in User,
        join: e in assoc(u, :email_addresses),
        preload: [email_addresses: e]
    )
  end

  @doc """
  Gets a single user.
  """
  @spec get_user(integer) :: User.t() | nil
  def get_user(id) do
    Repo.one(
      from u in User,
        where: u.id == ^id,
        join: e in assoc(u, :email_addresses),
        preload: [email_addresses: e]
    )
  end

  @doc """
  Gets a user based on the params.

  This is used by Phauxth to get user information.
  """
  @spec get_by(map) :: User.t() | nil
  def get_by(%{"session_id" => session_id}) do
    with %Session{user_id: user_id} <- Sessions.get_session(session_id),
         do: get_user(user_id)
  end

  def get_by(%{"email" => email}) do
    Repo.one(
      from u in User,
        join: e in assoc(u, :email_addresses),
        where: e.value == ^email,
        preload: [email_addresses: e]
    )
  end

  def get_by(%{"user_id" => user_id}), do: Repo.get(User, user_id)

  @doc """
  Creates a user.
  """
  @spec create_user(map) :: {:ok, User.t()} | changeset_error
  def create_user(attrs) do
    user = User.create_changeset(%User{}, attrs)

    email =
      EmailAddress.changeset(%EmailAddress{}, %{
        value: attrs["email"],
        position: 1,
        description: "email when registering vutuv"
      })

    user_with_email = Ecto.Changeset.put_assoc(user, :email_addresses, [email])
    Repo.insert(user_with_email)
  end

  @doc """
  Updates a user.
  """
  @spec update_user(User.t(), map) :: {:ok, User.t()} | changeset_error
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.
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
  Confirms a user's email.
  """
  @spec confirm_user(User.t()) :: {:ok, User.t()} | changeset_error
  def confirm_user(%User{} = user) do
    user |> User.confirm_changeset() |> Repo.update()

    email_address = hd(user.email_addresses)

    email_address
    |> EmailAddress.verify_changeset()
    |> Repo.update()
  end

  @doc """
  Makes a password reset request.
  """
  @spec create_password_reset(map) :: {:ok, User.t()} | nil
  def create_password_reset(attrs) do
    with %User{} = user <- get_by(attrs) do
      user
      |> User.password_reset_changeset(DateTime.utc_now() |> DateTime.truncate(:second))
      |> Repo.update()
    end
  end

  @doc """
  Updates a user's password.
  """
  @spec update_password(User.t(), map) :: {:ok, User.t()} | changeset_error
  def update_password(%User{} = user, attrs) do
    Sessions.delete_user_sessions(user)

    user
    |> User.create_changeset(attrs)
    |> User.password_updated_changeset()
    |> Repo.update()
  end

  @doc """
  Returns the list of email_addresses.

  ## Examples

      iex> list_email_addresses()
      [%EmailAddress{}, ...]

  """
  @spec list_email_addresses() :: [EmailAddress.t()]
  def list_email_addresses do
    Repo.all(EmailAddress)
  end

  @doc """
  Gets a single email_address.

  ## Examples

      iex> get_email_address(123)
      %EmailAddress{}

      iex> get_email_address(456)
      nil

  """
  @spec get_email_address(integer) :: EmailAddress.t() | nil
  def get_email_address(id), do: Repo.get(EmailAddress, id)

  @spec list_email_address_user(integer) :: [String.t()] | nil
  def list_email_address_user(user_id) do
    query =
      from e in EmailAddress,
        select: e.value,
        where: e.user_id == ^user_id

    Repo.all(query)
  end

  @doc """
  Creates a email_address.

  ## Examples

      iex> create_email_address(%{field: value})
      {:ok, %EmailAddress{}}

      iex> create_email_address(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_email_address(map) :: {:ok, EmailAddress.t()} | changeset_error
  def create_email_address(attrs \\ %{}) do
    user_id = check_user_id(attrs["user_id"])

    last_email =
      Repo.one(
        from e in EmailAddress,
          order_by: [desc: e.position],
          where: e.user_id == ^user_id,
          limit: 1
      )

    user = get_user(user_id) |> Repo.preload(:email_addresses)

    attrs =
      if last_email == nil do
        %{attrs | "position" => 1}
      else
        %{attrs | "position" => Integer.to_string(last_email.position + 1)}
      end

    user
    |> build_assoc(:email_addresses)
    |> EmailAddress.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a email_address.

  ## Examples

      iex> update_email_address(email_address, %{field: new_value})
      {:ok, %EmailAddress{}}

      iex> update_email_address(email_address, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_email_address(EmailAddress.t(), map) :: {:ok, EmailAddress.t()} | changeset_error
  def update_email_address(%EmailAddress{} = email_address, attrs) do
    email_address
    |> EmailAddress.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a EmailAddress.

  ## Examples

      iex> delete_email_address(email_address)
      {:ok, %EmailAddress{}}

      iex> delete_email_address(email_address)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_email_address(EmailAddress.t()) :: {:ok, EmailAddress.t()} | changeset_error
  def delete_email_address(%EmailAddress{} = email_address) do
    Repo.delete(email_address)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking email_address changes.

  ## Examples

      iex> change_email_address(email_address)
      %Ecto.Changeset{source: %EmailAddress{}}

  """
  @spec change_user(EmailAddress.t()) :: Ecto.Changeset.t()
  def change_email_address(%EmailAddress{} = email_address) do
    EmailAddress.changeset(email_address, %{})
  end

  defp check_user_id(userid) do
    if is_binary(userid) do
      userid |> String.to_integer()
    else
      userid
    end
  end
end

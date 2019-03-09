defmodule Vutuv.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Vutuv.{Accounts.User, Repo, Sessions, Sessions.Session, Biographies, Biographies.Profile}

  @doc """
  Returns the list of users.
  """
  def list_users, do: Repo.all(User)

  @doc """
  Gets a single user.
  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Gets a user based on the params.

  This is used by Phauxth to get user information.
  """
  def get_by(%{"session_id" => session_id}) do
    with %Session{user_id: user_id} <- Sessions.get_session(session_id),
         do: get_user(user_id)
  end

  def get_by(%{"email" => email}) do
    Repo.get_by(User, email: email)
  end

  def get_by(%{"user_id" => user_id}), do: Repo.get(User, user_id)

  @doc """
  Creates a user.
  """
  def create_user(attrs) do
    IO.puts("=====1")
    IO.inspect(attrs)
    user = %User{}
    |> User.create_changeset(attrs)
    |> Repo.insert()

  end

  @doc """
  Updates a user.
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.
  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Confirms a user's email.
  """
  def confirm_user(%User{} = user) do
    user |> User.confirm_changeset() |> Repo.update()
  end

  @doc """
  Makes a password reset request.
  """
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
  def update_password(%User{} = user, attrs) do
    Sessions.delete_user_sessions(user)

    user
    |> User.create_changeset(attrs)
    |> User.password_reset_changeset(nil)
    |> Repo.update()
  end

  alias Vutuv.Accounts.EmailAddress

  @doc """
  Returns the list of email_addresses.

  ## Examples

      iex> list_email_addresses()
      [%EmailAddress{}, ...]

  """
  def list_email_addresses do
    Repo.all(EmailAddress)
  end

  @doc """
  Gets a single email_address.

  Raises `Ecto.NoResultsError` if the Email address does not exist.

  ## Examples

      iex> get_email_address!(123)
      %EmailAddress{}

      iex> get_email_address!(456)
      ** (Ecto.NoResultsError)

  """
  def get_email_address!(id), do: Repo.get!(EmailAddress, id)

  @doc """
  Creates a email_address.

  ## Examples

      iex> create_email_address(%{field: value})
      {:ok, %EmailAddress{}}

      iex> create_email_address(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_email_address(attrs \\ %{}) do
    %EmailAddress{}
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
  def delete_email_address(%EmailAddress{} = email_address) do
    Repo.delete(email_address)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking email_address changes.

  ## Examples

      iex> change_email_address(email_address)
      %Ecto.Changeset{source: %EmailAddress{}}

  """
  def change_email_address(%EmailAddress{} = email_address) do
    EmailAddress.changeset(email_address, %{})
  end

  alias Vutuv.Accounts.Role

  @doc """
  Returns the list of roles.

  ## Examples

      iex> list_roles()
      [%Role{}, ...]

  """
  def list_roles do
    Repo.all(Role)
  end

  @doc """
  Gets a single roles.

  Raises `Ecto.NoResultsError` if the Role does not exist.

  ## Examples

      iex> get_roles!(123)
      %Role{}

      iex> get_roles!(456)
      ** (Ecto.NoResultsError)

  """
  def get_roles!(id), do: Repo.get!(Role, id)

  @doc """
  Creates a roles.

  ## Examples

      iex> create_roles(%{field: value})
      {:ok, %Role{}}

      iex> create_roles(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_roles(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a roles.

  ## Examples

      iex> update_roles(roles, %{field: new_value})
      {:ok, %Role{}}

      iex> update_roles(roles, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_roles(%Role{} = roles, attrs) do
    roles
    |> Role.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Role.

  ## Examples

      iex> delete_roles(roles)
      {:ok, %Role{}}

      iex> delete_roles(roles)
      {:error, %Ecto.Changeset{}}

  """
  def delete_roles(%Role{} = roles) do
    Repo.delete(roles)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking roles changes.

  ## Examples

      iex> change_roles(roles)
      %Ecto.Changeset{source: %Role{}}

  """
  def change_roles(%Role{} = roles) do
    Role.changeset(roles, %{})
  end
end

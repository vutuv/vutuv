defmodule Vutuv.UserProfiles do
  @moduledoc """
  The UserProfiles context.
  """

  import Ecto
  import Ecto.Query, warn: false

  alias Vutuv.{
    Devices.EmailAddress,
    Downloads.GravatarWorker,
    Repo,
    Sessions,
    Sessions.Session,
    Tags.Tag,
    UserProfiles.User,
    UserProfiles.Address
  }

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
  Preloads a user(s) associations.
  """
  @spec with_associated_data(User.t(), list) :: User.t()
  def with_associated_data(%User{} = user, associations) do
    Repo.preload(user, associations)
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
  Returns the list of addresses.
  """
  @spec list_addresses(User.t()) :: [Address.t()]
  def list_addresses(%User{} = user) do
    Repo.all(assoc(user, :addresses))
  end

  @doc """
  Gets a single address.

  Raises `Ecto.NoResultsError` if the Address does not exist.
  """
  @spec get_address!(User.t(), integer) :: Address.t() | no_return
  def get_address!(%User{} = user, id) do
    Repo.get_by!(Address, id: id, user_id: user.id)
  end

  @doc """
  Creates a address.
  """
  @spec create_address(User.t(), map) :: {:ok, Address.t()} | changeset_error
  def create_address(%User{} = user, attrs \\ %{}) do
    user
    |> build_assoc(:addresses)
    |> Address.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a address.
  """
  @spec update_address(Address.t(), map) :: {:ok, Address.t()} | changeset_error
  def update_address(%Address{} = address, attrs) do
    address
    |> Address.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Address.
  """
  @spec delete_address(Address.t()) :: {:ok, Address.t()} | changeset_error
  def delete_address(%Address{} = address) do
    Repo.delete(address)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking address changes.
  """
  @spec change_address(Address.t()) :: Ecto.Changeset.t()
  def change_address(%Address{} = address) do
    Address.changeset(address, %{})
  end
end

defmodule Vutuv.Tags do
  @moduledoc """
  The Tags context.
  """

  import Ecto
  import Ecto.Query, warn: false

  alias Vutuv.Repo
  alias Vutuv.Tags.{Tag, UserTag, UserTagEndorsement}
  alias Vutuv.UserProfiles.User

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  @doc """
  Returns the list of tags.
  """
  @spec list_tags() :: [Tag.t()]
  def list_tags do
    Repo.all(Tag)
  end

  @doc """
  Gets a single tag. Raises error if no tag found.
  """
  @spec get_tag!(integer) :: Tag.t() | no_return
  def get_tag!(id), do: Repo.get!(Tag, id)

  @doc """
  Creates a tag or gets an existing tag.
  """
  @spec create_or_get_tag(map) :: {:ok, Tag.t()} | changeset_error
  def create_or_get_tag(attrs) do
    name = attrs["name"]

    {downcase_name, slug_value} =
      if is_binary(name) do
        {String.downcase(name), Slugger.slugify_downcase(name)}
      else
        {nil, nil}
      end

    attrs = Map.merge(attrs, %{"downcase_name" => downcase_name, "slug" => slug_value})

    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert(
      on_conflict: [set: [downcase_name: downcase_name]],
      conflict_target: :downcase_name
    )
  end

  @doc """
  Updates a tag.
  """
  @spec update_tag(Tag.t(), map) :: {:ok, Tag.t()} | changeset_error
  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Tag.
  """
  @spec delete_tag(Tag.t()) :: {:ok, Tag.t()} | changeset_error
  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.
  """
  @spec change_tag(Tag.t()) :: Ecto.Changeset.t()
  def change_tag(%Tag{} = tag) do
    Tag.changeset(tag, %{})
  end

  @doc """
  Returns the list of user_tags.
  """
  @spec list_user_tags(User.t()) :: [UserTag.t()]
  def list_user_tags(%User{} = user) do
    assoc(user, :user_tags)
    |> Repo.all()
    |> Repo.preload(:tag)
  end

  @doc """
  Gets a single user_tag. Raises error if no user_tag found.
  """
  @spec get_user_tag!(User.t(), integer) :: UserTag.t() | no_return
  def get_user_tag!(%User{} = user, id) do
    UserTag
    |> Repo.get_by!(id: id, user_id: user.id)
    |> Repo.preload(:tag)
  end

  @doc """
  Creates a user_tag.
  """
  @spec create_user_tag(User.t(), map) :: {:ok, UserTag.t()} | changeset_error
  def create_user_tag(user, attrs) do
    with {:ok, %Tag{id: tag_id}} <- create_or_get_tag(attrs) do
      user
      |> build_assoc(:user_tags)
      |> UserTag.changeset(%{tag_id: tag_id})
      |> Repo.insert()
    end
  end

  @doc """
  Deletes a user_tag.
  """
  @spec delete_user_tag(UserTag.t()) :: {:ok, UserTag.t()} | changeset_error
  def delete_user_tag(%UserTag{} = user_tag) do
    Repo.delete(user_tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_tag changes.
  """
  @spec change_tag(UserTag.t()) :: Ecto.Changeset.t()
  def change_user_tag(%UserTag{} = user_tag) do
    UserTag.changeset(user_tag, %{})
  end

  @doc """
  Gets a single user_tag_endorsement. Raises error if no user_tag_endorsement found.
  """
  @spec get_user_tag_endorsement!(User.t(), integer) :: UserTagEndorsement.t() | no_return
  def get_user_tag_endorsement!(%User{} = user, id) do
    Repo.get_by!(UserTagEndorsement, id: id, user_id: user.id)
  end

  @spec user_tag_endorsements_count(UserTag.t()) :: integer
  def user_tag_endorsements_count(%UserTag{id: user_tag_id}) do
    query = from e in UserTagEndorsement, where: e.user_tag_id == ^user_tag_id
    Repo.aggregate(query, :count, :id)
  end

  @doc """
  Creates a user_tag_endorsement.
  """
  def create_user_tag_endorsement(%User{} = user, attrs) do
    attrs = Map.put(attrs, "user_id", user.id)

    %UserTagEndorsement{}
    |> UserTagEndorsement.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a UserTagEndorsement.
  """
  @spec delete_user_tag_endorsement(UserTagEndorsement.t()) ::
          {:ok, UserTagEndorsement.t()} | changeset_error
  def delete_user_tag_endorsement(%UserTagEndorsement{} = user_tag_endorsement) do
    Repo.delete(user_tag_endorsement)
  end
end

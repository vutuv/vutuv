defmodule Vutuv.Tags do
  @moduledoc """
  The Tags context.
  """

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
  Creates a tag.
  """
  @spec create_tag(map) :: {:ok, Tag.t()} | changeset_error
  def create_tag(attrs \\ %{}) do
    name = attrs["name"]

    {downcase_name, slug_value} =
      if is_binary(name) do
        {String.downcase(name), Slugger.slugify_downcase(name)}
      else
        {nil, nil}
      end

    attrs = %{
      "name" => name,
      "downcase_name" => downcase_name,
      "description" => attrs["description"],
      "slug" => slug_value,
      "url" => attrs["url"]
    }

    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
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
  Returns number of endorsements for a user tag.
  """
  @spec user_tag_endorsements_count(Tag.t(), User.t()) :: integer
  def user_tag_endorsements_count(%Tag{id: tag_id}, %User{id: user_id}) do
    case Repo.get_by(UserTag, tag_id: tag_id, user_id: user_id) do
      %UserTag{} = user_tag ->
        query = from e in UserTagEndorsement, where: e.user_tag_id == ^user_tag.id
        Repo.aggregate(query, :count, :id)

      _ ->
        0
    end
  end

  @doc """
  Creates a user_tag_endorsement.
  """
  @spec create_user_tag_endorsement(map) :: {:ok, UserTagEndorsement.t()} | changeset_error
  def create_user_tag_endorsement(attrs \\ %{}) do
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

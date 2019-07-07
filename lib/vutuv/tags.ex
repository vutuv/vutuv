defmodule Vutuv.Tags do
  @moduledoc """
  The Tags context.
  """

  import Ecto.Query, warn: false

  alias Vutuv.Repo

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  alias Vutuv.Tags.Tag

  @doc """
  Returns the list of tags.
  """
  @spec list_tags() :: [Tag.t()]
  def list_tags do
    Repo.all(Tag)
  end

  @doc """
  Gets a single tag.
  """
  @spec get_tag(integer) :: Tag.t() | nil
  def get_tag(id), do: Repo.get(Tag, id)

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
end

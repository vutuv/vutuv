defmodule Vutuv.Generals do
  @moduledoc """
  The Generals context.
  """

  import Ecto.Query, warn: false

  alias Vutuv.Repo

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  alias Vutuv.Generals.Tag

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
    downcase_name =
      case is_binary(attrs["name"]) do
        false -> nil
        true -> String.downcase(attrs["name"])
      end

    slug_value =
      case is_binary(attrs["name"]) do
        false -> nil
        true -> Slugger.slugify_downcase(attrs["name"])
      end

    attrs = %{
      "name" => attrs["name"],
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
  ## Examples
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

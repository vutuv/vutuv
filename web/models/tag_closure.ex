defmodule Vutuv.TagClosure do
  use Vutuv.Web, :model
  import Ecto.Query
  alias Vutuv.Repo

  schema "tag_closures" do
    field :depth, :integer

    belongs_to :parent, Vutuv.Tag
    belongs_to :child, Vutuv.Tag

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:depth, :parent_id, :child_id])
    |> validate_required([:depth, :parent_id, :child_id])
    |> unique_constraint(:parent_id_child_id)
    |> validate_not_circular
  end

  defp validate_not_circular(changeset) do
    parent_id = get_field(changeset, :parent_id)
    child_id = get_field(changeset, :child_id)
    if(parent_id && child_id && parent_id != child_id) do
      IO.puts "\n\nParent: #{parent_id}, Child: #{child_id}\n\n"
      from(c in __MODULE__, where: c.parent_id == ^child_id and c.child_id == ^parent_id, limit: 1)
      |> Repo.one
      |> case do
        nil -> changeset
        _ -> add_error(changeset, :value, "This closure would cause a circular tree")
      end
    else
      changeset
    end
  end

  def add_closure(parent_id, child_id) do
    create_initial_closure(parent_id)
    create_initial_closure(child_id)
    parent_closures = Repo.all(from c in __MODULE__, where: c.child_id == ^parent_id)
    child_closures = Repo.all(from c in __MODULE__, where: c.depth > 0 and c.parent_id == ^child_id)
    Ecto.Multi.new
    |> create_parents(child_id, parent_closures)
    |> create_children(parent_id, child_closures)
    |> Repo.transaction
  end

  defp create_parents(multi, _, []), do: multi

  defp create_parents(multi, id, [%{parent_id: id, depth: depth} | tail]), do: create_parents(multi, id, tail)

  defp create_parents(multi, child_id, [%{parent_id: parent_id, depth: depth} | tail]) do
    IO.puts "\ntag_closure_#{parent_id}_#{child_id}"
    changeset = 
      %__MODULE__{}
      |>changeset(%{parent_id: parent_id, child_id: child_id, depth: depth+1})
    Ecto.Multi.insert(multi, "tag_closure_#{parent_id}_#{child_id}", changeset)
    |> create_parents(child_id, tail)
  end

  defp create_children(multi, _, []), do: multi

  defp create_children(multi, id, [%{child_id: id, depth: depth} | tail]), do: create_parents(multi, id, tail)

  defp create_children(multi, parent_id, [%{child_id: child_id, depth: depth} | tail]) do
    IO.puts "\ntag_closure_#{parent_id}_#{child_id}"
    changeset = 
      %__MODULE__{}
      |>changeset(%{parent_id: parent_id, child_id: child_id, depth: depth+1})
    Ecto.Multi.insert(multi, "tag_closure_#{parent_id}_#{child_id}", changeset)
    |> create_children(parent_id, tail)
  end

  defp create_initial_closure(id) do
    %__MODULE__{}
    |>changeset(%{parent_id: id, child_id: id, depth: 0})
    |> Repo.insert
  end

  def delete_closure(id, id), do: :error

  def delete_closure(parent_id, child_id) do
    closure = Repo.one(from c in __MODULE__, where: c.child_id == ^child_id and c.parent_id == ^parent_id)
    parent_closures = Repo.all(from c in __MODULE__, where: c.child_id == ^parent_id)
    child_closures = Repo.all(from c in __MODULE__, where: c.depth > 0 and c.parent_id == ^child_id)
    Ecto.Multi.new
    |> Ecto.Multi.delete("tag_closure", closure)
    |> delete_parents(child_id, parent_closures)
    |> delete_children(parent_id, child_closures)
    |> Repo.transaction
  end

  defp delete_parents(multi, _, []), do: multi

  defp delete_parents(multi, id, [%{parent_id: id, depth: depth} | tail]), do: create_parents(multi, id, tail)

  defp delete_parents(multi, child_id, [%{parent_id: parent_id, depth: depth} | tail]) do
    query = from(c in __MODULE__, where: c.parent_id == ^parent_id and c.child_id == ^child_id and c.depth == ^(depth+1))
    Ecto.Multi.delete_all(multi, "tag_closure_#{parent_id}_#{child_id}", query)
    |> delete_parents(child_id, tail)
  end

  defp delete_children(multi, _, []), do: multi

  defp delete_children(multi, id, [%{child_id: id, depth: depth} | tail]), do: create_parents(multi, id, tail)

  defp delete_children(multi, parent_id, [%{child_id: child_id, depth: depth} | tail]) do
    query = from(c in __MODULE__, where: c.parent_id == ^parent_id and c.child_id == ^child_id and c.depth == ^(depth+1))
    Ecto.Multi.delete_all(multi, "tag_closure_#{parent_id}_#{child_id}", query)
    |> delete_children(parent_id, tail)
  end
end

defmodule Vutuv.TagClosure do
  use Vutuv.Web, :model

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
    |> cast(params, [:depth])
    |> validate_required([:depth])
  end
end

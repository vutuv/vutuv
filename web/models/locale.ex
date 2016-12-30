defmodule Vutuv.Locale do
  use Vutuv.Web, :model
  import Ecto.Query

  schema "locales" do
    field :value, :string
    field :endonym, :string

    has_many :exonyms, Vutuv.Exonym

    timestamps()
  end
  
  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:value, :endonym])
    |> validate_required([:value, :endonym])
    |> unique_constraint(:value)
  end

  def locale_select_list do
    Vutuv.Repo.all(from l in __MODULE__, select: {l.endonym, l.id})
  end

  def locale_id(code) do
    Vutuv.Repo.one(from l in __MODULE__, where: l.value == ^code, select: l.id)
  end

  defimpl String.Chars, for: Vutuv.Locale do
    def to_string(locale), do: String.upcase "#{locale.value}"
  end

  defimpl List.Chars, for: Vutuv.Locale do
    def to_charlist(locale), do: '#{locale.value}'
  end
end

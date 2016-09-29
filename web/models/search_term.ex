defmodule Vutuv.SearchTerm do
  use Vutuv.Web, :model

  schema "search_terms" do
    field :value, :string
    field :score, :integer

    belongs_to :user, Vutuv.User
    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    changeset = 
    model
    |> cast(params, [:value, :score])
    |> downcase_value
    IO.puts "\n\n#{inspect changeset}\n\n"
    changeset
  end

  defp downcase_value(changeset) do
    # If the value has been changed, downcase it.
    update_change(changeset, :value, &String.downcase/1)
  end

  #Generates search terms from user data
  def create_search_terms(%{"first_name" => first_name, "last_name" => last_name}) do

    terms = combine_terms(first_name, last_name)

    fuzzy_terms = 
      combine_terms(Vutuv.ColognePhonetics.to_cologne(first_name), Vutuv.ColognePhonetics.to_cologne(last_name))
      ++
      combine_terms(Vutuv.Soundex.to_soundex(first_name), Vutuv.Soundex.to_soundex(last_name))

    for(term <- terms) do #generates changesets for terms
      changeset(%Vutuv.SearchTerm{}, %{value: term, score: 100})
    end
    ++
    for(term <- fuzzy_terms) do #generates changesets for fuzzy_terms with lower match score
      changeset(%Vutuv.SearchTerm{}, %{value: term, score: 80})
    end
  end

  def create_search_terms(_), do: []

  defp combine_terms(first_name, last_name) do
      [first_name,
      last_name,
      "#{first_name} #{last_name}",
      "#{last_name} #{first_name}",
      "#{first_name}, #{last_name}",
      "#{last_name}, #{first_name}"]
  end
end

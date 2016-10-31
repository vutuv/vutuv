defmodule Vutuv.Search do
	import Ecto.Query
  alias Vutuv.SearchTerm
  alias Vutuv.User
  alias Vutuv.Repo

  #Checks database for matches between search.value and search_terms
  def search(value, false) do
    value = String.downcase(value)
    cologne_fuzzy_value = phoneticize_search_value(value, :cologne)
    soundex_fuzzy_value = phoneticize_search_value(value, :soundex)
    for(term<- Repo.all(from t in SearchTerm, where: ^value == t.value or ^cologne_fuzzy_value == t.value or ^soundex_fuzzy_value == t.value)) do
      %{score: term.score, user_id: term.user_id}
    end
    |> Enum.sort(&(&1.score> &2.score)) #Sorts by score
    |> Enum.uniq_by(&(&1.user_id)) #Filters duplicates
    |> Enum.map(&(Repo.get!(User, &1.user_id))) #Maps to flat list of users
  end

  #Searches for user that matches email
  def search(value, true) do
    value = String.downcase(value)
    Repo.all(from u in User, join: e in assoc(u, :emails), where: ^value == e.value)
    |> Enum.uniq_by(&(&1.id)) #Filters duplicates
  end

  defp phoneticize_search_value(value, algorithm) do 
    for(section <- Regex.split(~r/[^a-z]+/, value, include_captures: true)) do #Split the value by non words
      if(Regex.match?(~r/^[a-z]+$/, section)) do
        case algorithm do #Phoneticize the words based on the algorithm parameter
          :cologne -> Vutuv.ColognePhonetics.to_cologne(section)
          :soundex -> Vutuv.Soundex.to_soundex(section)
        end
      else
        section #Retain the non-words
      end
    end
    |> Enum.join #Recombine the search value with phoneticized words
  end
end
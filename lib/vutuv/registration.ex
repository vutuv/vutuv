defmodule Vutuv.Registration do
  import Ecto.Query
  alias Vutuv.User
  alias Vutuv.Slug
  alias Vutuv.Repo
  alias Vutuv.SearchTerm
  alias Vutuv.ColognePhonetics
  alias Vutuv.Soundex

  def register_user(user_params, assocs \\ []) do
    slug =
      if(user_params["first_name"] != nil or user_params["last_name"] != nil) do
        struct = %User{first_name: user_params["first_name"], last_name: user_params["last_name"]}

        slug_value = generate_slug(struct)

        Slug.changeset(%Slug{}, %{value: slug_value})
      end
    search_terms = generate_search_terms(user_params)
    changeset = User.changeset(%User{}, user_params)
    |> Ecto.Changeset.put_assoc(:slugs, [slug])
    |> Ecto.Changeset.put_assoc(:search_terms, search_terms)
    |> Ecto.Changeset.put_change(:active_slug, slug.changes.value)
    changeset = 
    Enum.reduce([changeset | assocs], fn {type, params}, changeset ->
      changeset
      |>Ecto.Changeset.put_assoc(type, [params])
    end)
     Repo.insert(changeset)
  end

  #Generates search terms from user data
  defp generate_search_terms(%{"first_name" => first_name, "last_name" => last_name} = user) do
    email = user["emails"]["0"]["value"]

    terms = #if email is not nil, add to search terms
      if (email), do: [email|combine_terms(first_name, last_name)], else: combine_terms(first_name, last_name) 

    fuzzy_terms = 
      combine_terms(ColognePhonetics.to_cologne(first_name), ColognePhonetics.to_cologne(last_name))
      ++
      combine_terms(Soundex.to_soundex(first_name), Soundex.to_soundex(last_name))

    for(term <- terms) do #generates changesets for terms
      SearchTerm.changeset(%SearchTerm{}, %{value: term, score: 100})
    end
    ++
    for(term <- fuzzy_terms) do #generates changesets for fuzzy_terms with lower match score
      SearchTerm.changeset(%SearchTerm{}, %{value: term, score: 80})
    end
  end

  defp generate_search_terms(_), do: []

  defp combine_terms(first_name, last_name) do
      [first_name,
      last_name,
      "#{first_name} #{last_name}",
      "#{last_name} #{first_name}",
      "#{first_name}, #{last_name}",
      "#{last_name}, #{first_name}"]
  end

  def generate_slug(user) do
    slug_value = Slugger.slugify_downcase(user, ?.)

    f = fn val -> if val, do: val, else: "" end

    user_count = Repo.one(from u in User,
      where: u.first_name == ^f.(user.first_name)
      and u.last_name == ^f.(user.last_name),
      select: count("*"))
    
    if(user_count>0) do
      slug_value<>Integer.to_string(user_count)
    else
      slug_value
    end
  end
end
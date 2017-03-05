defmodule Vutuv.Registration do
  import Ecto.Query
  alias Vutuv.User
  alias Vutuv.Slug
  alias Vutuv.Repo
  alias Vutuv.SearchTerm
  alias Vutuv.UserTag
  alias Vutuv.Tag

  @stefan_email ~s"stefan.wintermeyer@amooma.de"

  def register_user(conn, user_params, assocs \\ []) do
    tags = user_params["easy_tags"]
    user_params
    |> slug_changeset
    |> user_changeset(conn, user_params, assocs)
    |> Repo.insert
    |> case do
      {:ok, user} ->

        user =
          user
          |> Repo.preload([user_tags: [:tag]])
        tag_list =
          tags
          |> String.split(",")
        results =
          for(tag <- tag_list) do
            capitalized_tag =
              tag
              |> String.trim
            user
            |> Ecto.build_assoc(:user_tags, %{})
            |> UserTag.changeset
            |> Tag.create_or_link_tag(%{"value" => capitalized_tag}, conn.assigns[:locale])
            |> Repo.insert
          end

        Task.start(__MODULE__, :store_gravatar, [user])
        {:ok, user}
      error ->
        error
    end
  end

  defp slug_changeset(user_params) do
    if(user_params["first_name"] != nil or user_params["last_name"] != nil) do
      struct = %User{first_name: user_params["first_name"], last_name: user_params["last_name"]}

      slug_value = Vutuv.SlugHelpers.gen_slug_unique(struct, Vutuv.Slug, :value)

      Slug.changeset(%Slug{}, %{value: slug_value})
    else
      Slug.changeset(%Slug{}, %{value: "invalid"})
      |> Ecto.Changeset.add_error(:value, "Invalid slug")
    end
  end

  defp user_changeset(slug_changeset, conn, user_params, assocs) do
    search_terms = SearchTerm.create_search_terms(user_params)
    changeset = User.changeset(%User{}, user_params)
      |> Ecto.Changeset.put_assoc(:slugs, [slug_changeset])
      |> Ecto.Changeset.put_assoc(:search_terms, search_terms)
      |> Ecto.Changeset.put_change(:active_slug, slug_changeset.changes[:value])
      |> Ecto.Changeset.put_change(:locale, conn.assigns[:locale])
    Enum.reduce([changeset | assocs], fn {type, params}, changeset ->
      changeset
      |>Ecto.Changeset.put_assoc(type, [params])
    end)
  end

  # This downloads and stores a users gravatar. It then updates
  # the user's model with the information for arc-ecto to
  # retrieve the file later. If they do not have one, it stores
  # the default gravatar avatar. It times out at 1 second.

  def store_gravatar(user) do
    case HTTPoison.get("https://www.gravatar.com/avatar/#{hd(user.emails).md5sum}?s=130&d=404", [], [timeout: 1000, recv_timeout: 1000])  do
      {:ok, %HTTPoison.Response{status_code: 404}} -> nil
      {:ok, %HTTPoison.Response{body: body, headers: headers}} ->
        content_type = find_content_type(headers)
        filename = "/#{user.active_slug}.#{String.replace(content_type,"image/", "")}"
        path = System.tmp_dir
        upload = #create the upload struct that arc-ecto will use to store the file and update the database
          %Plug.Upload{content_type: content_type,
          filename: filename,
          path: path<>filename}
        File.write(path<>filename, body) #Write the file temporarily to the disk
        user
        |> Repo.preload([:slugs, :oauth_providers, :emails])
        |> User.changeset(%{avatar: upload}) #update the user with the upload struct
        |> Repo.update
      _ -> nil
    end
  end

  defp find_content_type(headers) do
    Enum.reduce(headers, fn {k, v}, acc ->
      if (k == "Content-Type"), do: v, else: acc
    end)
  end
end

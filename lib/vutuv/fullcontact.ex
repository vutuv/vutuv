# This module collects information form the internet and
# merges them with already stored information.
#
defmodule Vutuv.Fullcontact do
  import Ecto.Query
  import Ecto
  require Vutuv.Gettext
  alias Vutuv.User
  alias Vutuv.Url
  alias Vutuv.WorkExperience
  alias Vutuv.Repo
  alias Vutuv.Gettext
  alias Vutuv.UserTag
  alias Vutuv.Tag
  alias Vutuv.Address
  alias Vutuv.FullcontactCache

  def enrich(email, user) do
    fullcontact_data = fetch_fullcontact_json(email.value)
                       |> Poison.decode!

    if fullcontact_data["likelihood"] > 0.93 do
      feedback = [] # Stores messages for the user

      feedback = add_avatar(user, fullcontact_data)
      feedback = feedback ++ add_websites(user, fullcontact_data)
      feedback = feedback ++ add_social_media_accounts(user, fullcontact_data)
      feedback = feedback ++ add_work_experiences(user, fullcontact_data)
      feedback = feedback ++ add_tags(user, fullcontact_data)
      feedback = feedback ++ [add_address(user, email, fullcontact_data)]

      feedback = Enum.filter(feedback, fn(x) -> x !== nil end)

      if feedback do
        for line <- feedback do
          IO.puts line
        end
      end
    end
  end

  def fetch_fullcontact_json(email_address) do
    email_address = String.downcase(email_address)
    cache = Repo.get_by(FullcontactCache, email_address: email_address)

    if cache do
      cache.content
    else
      headers = [{"X-FullContact-APIKey", Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:fullcontact_api_key]}]
      url = "https://api.fullcontact.com/v2/person.json?email=#{URI.encode(email_address)}"

      case HTTPoison.post(url,"",headers) do
        {:ok, %HTTPoison.Response{body: body, headers: headers, status_code: 200}} ->
          changeset =
            FullcontactCache.changeset(%FullcontactCache{email_address: email_address, content: body})
          case Repo.insert(changeset) do
            {:ok, fullcontact_cache} ->
              fullcontact_cache.content
            _ ->
              nil
          end
        _ ->
          nil
      end
    end
  end

  defp add_address(user, email, fullcontact_data) do
    # Only add if addresses is empty.
    user = user|>Repo.preload([addresses: from(u in Vutuv.Address)])

    if Enum.count(user.addresses) == 0 do
      if fullcontact_data["likelihood"] > 0.96 do
        add_country(user, fullcontact_data["demographics"]["locationDeduced"]["normalizedLocation"])
      else
        if String.contains?(email.value, ".de") do
          add_country(user, "Germany")
        end
      end
    end
  end

  defp add_country(user, country) do
    changeset =
      user
      |> build_assoc(:addresses)
      |> Address.changeset(%{country: country, description: "Privat"})

    case Repo.insert(changeset) do
      {:ok, address} ->
        "Added country: #{address.country}"
      _ ->
    end
  end

  defp add_tags(user, fullcontact_data) do
    # Only add if user_tags is empty.
    user = user|>Repo.preload([user_tags: from(u in Vutuv.UserTag)])

    if Enum.count(user.user_tags) == 0 do
      feedback = for topic <- fullcontact_data["digitalFootprint"]["topics"] do
        tag = topic["value"]
        user
        |> Ecto.build_assoc(:user_tags, %{})
        |> UserTag.changeset
        |> Tag.create_or_link_tag(%{"value" => tag}, user.locale)
        |> Repo.insert
        |> case do
          {:ok, _user_tag} ->
            "Added tag: #{tag}"
          _ ->
        end
      end
    else
      []
    end
  end

  defp add_work_experiences(user, fullcontact_data) do
    # Only add if work_experiences is empty.
    user = user|>Repo.preload([work_experiences: from(u in Vutuv.WorkExperience)])

    if Enum.count(user.work_experiences) == 0 do
      feedback = for organization <- fullcontact_data["organizations"] do
        name = organization["name"]
        title = organization["title"]
        start_date = organization["startDate"]
        end_date = organization["endDate"]

        changeset =
          user
          |> build_assoc(:work_experiences)
          |> WorkExperience.changeset(%{organization: name, title: title})

        if start_date do
          case start_date |> String.split("-") do
            [year, month] ->
              changeset =
                changeset
                |> WorkExperience.changeset(%{start_year: year, start_month: month})
            [year] ->
              changeset =
                changeset
                |> WorkExperience.changeset(%{start_year: year})
            _ ->
          end
        end

        if end_date do
          case end_date |> String.split("-") do
            [year, month] ->
              changeset =
                changeset
                |> WorkExperience.changeset(%{end_year: year, end_month: month})
            [year] ->
              changeset =
                changeset
                |> WorkExperience.changeset(%{end_year: year})
            _ ->
          end
        end

        case Repo.insert(changeset) do
          {:ok, work_experience} ->
            "#{work_experience.title} @ #{work_experience.organization} (#{work_experience.start_year}-#{work_experience.end_year})"
          _ ->
        end
      end
      feedback
    else
      []
    end
  end

  defp add_avatar(user, fullcontact_data) do
    unless user.avatar do
      if List.first(fullcontact_data["photos"]) do
        avatar_url = List.first(fullcontact_data["photos"])["url"]
        download_and_store_avatar(user, avatar_url)
        [Gettext.gettext("Added an avatar photo.")]
      else
        [nil]
      end
    else
      [nil]
    end
  end

  defp download_and_store_avatar(user, url) do
    case HTTPoison.get(url, [], [timeout: 1500, recv_timeout: 1500])  do
      {:ok, %HTTPoison.Response{body: body, headers: headers, status_code: 200}} ->
        {_, content_type} = List.keyfind(headers, "Content-Type", 0)
        file_extension = String.split(content_type, "/")
                         |> List.last
        filename = "#{user.active_slug}.#{file_extension}"
        temp_dir_path = System.tmp_dir
        temp_file = "#{temp_dir_path}/avatar-#{filename}"
                    |> String.replace("//","/")
        File.rm(temp_file)
        File.write(temp_file, body)
        upload = %Plug.Upload{content_type: content_type,
                 filename: filename,
                 path: temp_file}
        user
        |> Repo.preload([:slugs, :oauth_providers, :emails])
        |> User.changeset(%{avatar: upload}) #update the user with the upload struct
        |> Repo.update
        File.rm(temp_file)
      _ -> nil
    end
  end

  defp add_websites(user, fullcontact_data) do
    # Only add fullcontact info if no urls are there.
    user = user|>Repo.preload([urls: from(u in Vutuv.Url)])

    if Enum.count(user.urls) == 0 do
      if Enum.count(fullcontact_data["contactInfo"]["websites"]) > 0 do
         feedback = for website <- fullcontact_data["contactInfo"]["websites"] do
           feedback = []
           url = Ecto.build_assoc(user, :urls, value: website["url"])

           feedback = feedback ++ case Repo.insert(url) do
             {:ok, url} ->
               Task.start(__MODULE__, :generate_screenshot, [url])
               ["#{Gettext.gettext("Added website:")} #{url.value}"]
             _ ->
           end
         end
         feedback
      else
        [nil]
      end
    else
      [nil]
    end
  end

  defp add_social_media_accounts(user, fullcontact_data) do
    feedback = []
    feedback = feedback ++ for social_profile <- fullcontact_data["socialProfiles"] do
      feedback = []
      username = social_profile["username"]
      feedback = feedback ++ case social_profile["type"] do
        "github" ->
          add_social_media_provider(user, "GitHub", username)
        "google" ->
          add_social_media_provider(user, "Google+", username)
        "twitter" ->
          add_social_media_provider(user, "Twitter", username)
        "youtube" ->
          add_social_media_provider(user, "Youtube", username)
        "instagram" ->
          add_social_media_provider(user, "Instagram", username)
        "facebook" ->
          add_social_media_provider(user, "Facebook", username)
        _ -> nil
      end
    end
    feedback
  end

  # Gettext.put_locale(Vutuv.Gettext, user.locale)

  defp add_social_media_provider(user, provider, account) do
    # Only add if not already an existing account of this provider exists.
    user = user|>Repo.preload([social_media_accounts: from(u in Vutuv.SocialMediaAccount)])

    results = for social_media_account <- user.social_media_accounts do
      if social_media_account.provider == provider do
        true
      else
        false
      end
    end

    unless Enum.member?(results, true) do
      social_media_account = Ecto.build_assoc(user, :social_media_accounts, %{value: account, provider: provider})

      case Repo.insert(social_media_account) do
        {:ok, social_media_account} ->
          ["#{Gettext.gettext("Added")} #{social_media_account.provider} #{Gettext.gettext("account")}: #{social_media_account.value}"]
        _ ->
      end
    end
  end

  defp generate_screenshot(url) do
    Vutuv.Browserstack.generate_screenshot(url)
  end



end

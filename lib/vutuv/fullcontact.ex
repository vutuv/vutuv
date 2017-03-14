# This module collects information from FullContact and
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
  alias Vutuv.Email
  alias Vutuv.DataEnrichment

  def enrich(user) do
    # create a new session ID
    query = from d in DataEnrichment, where: d.user_id == ^user.id,
                                      order_by: :session_id,
                                      limit: 1
    last_data_enrichment = Repo.one(query)

    session_id =
      if last_data_enrichment do
        last_data_enrichment.session_id + 1
      else
        1
      end

    query = from e in Email, where: e.user_id == ^user.id
    emails = Repo.all(query)
    for email <- emails do
      enrich(email, user, session_id)
    end
  end

  def within_api_limits?() do
    api_key = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:fullcontact_api_key]
    monthly_limit = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:fullcontact_per_month_limit]
    minute_limit = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:fullcontact_per_minute_limit]

    if api_key && monthly_limit && minute_limit do
      # Count the API calls in the current month
      {:ok, minute_ago} = DateTime.to_unix(DateTime.utc_now()) - 120 |> DateTime.from_unix()
      query = from f in FullcontactCache, where: f.updated_at > ^Ecto.DateTime.from_erl({{minute_ago.year, minute_ago.month, 1}, {0, 0, 0}})
      month_api_calls = length Repo.all(query) # Yes, SQL count would be nicer.

      # The limit is per minute but let's be on the save side:
      {:ok, minute_ago} = DateTime.to_unix(DateTime.utc_now()) - 120 |> DateTime.from_unix()
      query = from f in FullcontactCache, where: f.updated_at > ^Ecto.DateTime.from_erl({{minute_ago.year, minute_ago.month, minute_ago.day}, {minute_ago.hour, minute_ago.minute, minute_ago.second}})
      minute_api_calls = length Repo.all(query) # Yes, SQL count would be nicer.

      if monthly_limit > month_api_calls && minute_limit > minute_api_calls do
        true
      else
        false
      end
    else
      false
    end
  end

  # Checks if this enrichment has been done in the past already.
  # This takes care of the situation in which a user deleted
  # an enrichment. We won't enrich the same information twice.
  #
  defp data_enrichment_exists?(user, description, value) do
    query = from d in DataEnrichment, where: d.user_id == ^user.id,
                                      where: d.description == ^description,
                                      where: d.value == ^value,
                                      limit: 1

    if Repo.one(query) do
      true
    else
      false
    end
  end

  defp store_data_enrichment(user, session_id, description, value) do
    source = "FullContact"
    changeset =
      DataEnrichment.changeset(%DataEnrichment{user_id: user.id,
                                               session_id: session_id,
                                               description: description,
                                               value: value,
                                               source: source})
    Repo.insert(changeset)
  end

  def enrich(email, user, session_id) do
    fullcontact_data = fetch_fullcontact_json(email.value)
                       |> Poison.decode!

    if fullcontact_data["likelihood"] > 0.91 do
      add_avatar(user, session_id, fullcontact_data)
      add_websites(user, session_id, fullcontact_data)
      add_social_media_accounts(user, session_id, fullcontact_data)
      add_work_experiences(user, session_id, fullcontact_data)
      add_tags(user, session_id, fullcontact_data)
      add_address(user, session_id, email, fullcontact_data)
    end
  end

  def fetch_fullcontact_json(email_address) do
    if within_api_limits?() do
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
  end

  defp add_address(user, session_id, email, fullcontact_data) do
    # Only add if addresses is empty.
    user = user
           |>Repo.preload([addresses: from(u in Vutuv.Address)])

    unless Enum.any?(user.addresses) do
      if fullcontact_data["likelihood"] > 0.96 do
        country = fullcontact_data["demographics"]["locationDeduced"]["normalizedLocation"]
        if country do
          add_country(user, session_id, country)
        end
      else
        if String.contains?(email.value, ".de") do
          add_country(user, session_id, "Germany")
        end
      end
    end
  end

  defp add_country(user, session_id, country) do
    changeset =
      user
      |> build_assoc(:addresses)
      |> Address.changeset(%{country: country, description: "Privat"})

    unless data_enrichment_exists?(user, "Added country", country) do
      case Repo.insert(changeset) do
        {:ok, _address} ->
          store_data_enrichment(user, session_id, "Added country", country)
        _ ->
      end
    end
  end

  defp add_tags(user, session_id, fullcontact_data) do
    # Only add if user_tags is empty.
    user = user
           |>Repo.preload([user_tags: from(u in Vutuv.UserTag)])

    unless Enum.any?(user.user_tags) do
      for topic <- fullcontact_data["digitalFootprint"]["topics"] do
        tag = topic["value"]
        unless data_enrichment_exists?(user, "Added tag", tag) do
          changeset =
            user
            |> Ecto.build_assoc(:user_tags, %{})
            |> UserTag.changeset
            |> Tag.create_or_link_tag(%{"value" => tag}, user.locale)

          case Repo.insert(changeset) do
            {:ok, _} ->
              store_data_enrichment(user, session_id, "Added tag", tag)
            _ ->
          end
        end
      end
    end
  end

  defp add_work_experiences(user, session_id, fullcontact_data) do
    # Only add if work_experiences is empty.
    user = user
           |>Repo.preload([work_experiences: from(u in Vutuv.WorkExperience)])

    unless Enum.any?(user.work_experiences) do
      for organization <- fullcontact_data["organizations"] do
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

        unless data_enrichment_exists?(user, "Added work experience", work_experience_to_string(changeset.data)) do
          case Repo.insert(changeset) do
            {:ok, work_experience} ->
              store_data_enrichment(user, session_id, "Added work experience", work_experience_to_string(work_experience))
            _ ->
          end
        end
      end
    end
  end

  defp work_experience_to_string(work_experience) do
    job = case {work_experience.title, work_experience.organization} do
      {nil, nil} ->
        ""
      {title, nil} ->
        work_experience.title
      {nil, organization} ->
        work_experience.organization
      _ ->
        "#{work_experience.title} @ #{work_experience.organization}"
    end

    start_string = case {work_experience.start_year, work_experience.start_month} do
      {nil, nil} ->
        ""
      {year, nil} ->
        "#{year}"
      {year, month} ->
        "#{month}/#{year}"
      _ ->
    end

    end_string = case {work_experience.end_year, work_experience.end_month} do
      {nil, nil} ->
        ""
      {year, nil} ->
        "#{year}"
      {year, month} ->
        "#{month}/#{year}"
      _ ->
    end

    case {job, start_string, end_string} do
      {"", "", ""} ->
        ""
      {job, "", ""} ->
        job
      {job, start_string, ""} ->
        "#{job} (#{start_string})"
      {job, "", end_string} ->
        "#{job} (#{end_string})"
      {job, start_string, end_string} ->
        "#{job} (#{start_string}-#{end_string})"
      _ ->
    end
  end

  defp add_avatar(user, session_id, fullcontact_data) do
    unless user.avatar do
      if List.first(fullcontact_data["photos"]) do
        avatar_url = List.first(fullcontact_data["photos"])["url"]
        download_and_store_avatar(user, avatar_url)
        store_data_enrichment(user, session_id, "Added avatar photo", avatar_url)
      end
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

  defp add_websites(user, session_id, fullcontact_data) do
    # Only add fullcontact info if no urls are there.
    user = user|>Repo.preload([urls: from(u in Vutuv.Url)])

    unless Enum.any?(user.urls) do
      for website <- fullcontact_data["contactInfo"]["websites"] do
       url = Ecto.build_assoc(user, :urls, value: website["url"])

       unless data_enrichment_exists?(user, "Added website", website["url"]) do
         case Repo.insert(url) do
           {:ok, url} ->
             Task.start(__MODULE__, :generate_screenshot, [url])
             store_data_enrichment(user, session_id, "Added website", website["url"])
           _ ->
         end
       end
      end
    end
  end

  defp add_social_media_accounts(user, session_id, fullcontact_data) do
    feedback = []
    feedback = feedback ++ for social_profile <- fullcontact_data["socialProfiles"] do
      feedback = []
      username = social_profile["username"]
      feedback = feedback ++ case social_profile["type"] do
        "github" ->
          add_social_media_provider(user, session_id, "GitHub", username)
        "google" ->
          add_social_media_provider(user, session_id, "Google+", username)
        "twitter" ->
          add_social_media_provider(user, session_id, "Twitter", username)
        "youtube" ->
          add_social_media_provider(user, session_id, "Youtube", username)
        "instagram" ->
          add_social_media_provider(user, session_id, "Instagram", username)
        "facebook" ->
          add_social_media_provider(user, session_id, "Facebook", username)
        _ -> nil
      end
    end
    feedback
  end

  defp add_social_media_provider(user, session_id, provider, account) do
    # Only add if not already an existing account of this provider exists.
    user = user
           |>Repo.preload([social_media_accounts: from(u in Vutuv.SocialMediaAccount)])

    results = for social_media_account <- user.social_media_accounts do
      if social_media_account.provider == provider do
        true
      else
        false
      end
    end

    unless Enum.member?(results, true) do
      social_media_account = Ecto.build_assoc(user, :social_media_accounts, %{value: account, provider: provider})

      unless data_enrichment_exists?(user, "Added #{social_media_account.provider} account", account) do
        case Repo.insert(social_media_account) do
          {:ok, social_media_account} ->
            store_data_enrichment(user, session_id, "Added #{social_media_account.provider} account", account)
          _ ->
        end
      end
    end
  end

  # Not a defp!
  def generate_screenshot(url) do
    Vutuv.Browserstack.generate_screenshot(url)
  end

end

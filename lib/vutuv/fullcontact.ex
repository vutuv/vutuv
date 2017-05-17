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

  @min_likelihood 0.94

  defp likelihood(fullcontact_data) do
    fullcontact_data["likelihood"] > @min_likelihood
  end

  defp new_session_id(user) do
    query = from d in DataEnrichment, where: d.user_id == ^user.id,
                                      order_by: :session_id,
                                      limit: 1
    last_data_enrichment = Repo.one(query)

    # create a new session ID
    if last_data_enrichment do
      last_data_enrichment.session_id + 1
    else
      1
    end
  end

  def emails(user) do
    query = from e in Email, where: e.user_id == ^user.id
    emails = Repo.all(query)
  end

  def enrichable_avatar(user) do
    unless user.avatar do
      fullcontact_avatars(user)
      |> List.first
    else
      nil
    end
  end

  def enrichable_websites(user) do
    # Only use fullcontact info if no urls are there.
    user = user|>Repo.preload([urls: from(u in Vutuv.Url)])

    unless Enum.any?(user.urls) do
      fullcontact_websites(user)
    end
  end

  def enrichable_social_media_accounts(user) do
    for social_media_account <- fullcontact_social_media_accounts(user) do
      provider = social_media_account |> Map.keys |> List.first
      account = social_media_account |> Map.values |> List.first
      unless has_account_at_provider?(user, provider, account) do
        social_media_account
      end
    end |> Enum.uniq |> Enum.filter(fn(x) -> x != nil end)
  end

  def enrichable_work_experiences(user) do
    user = user
           |>Repo.preload([work_experiences: from(u in Vutuv.WorkExperience)])

    unless Enum.any?(user.work_experiences) do
      fullcontact_work_experiences(user)
    end
  end

  def fullcontact_avatars(user) do
      urls = for email <- emails(user) do
        fullcontact_data = decoded_fullcontact_data(email.value)
        if fullcontact_data["photos"] && likelihood(fullcontact_data) do
          if List.first(fullcontact_data["photos"]) do
            List.first(fullcontact_data["photos"])["url"]
          end
        end
      end |> List.flatten |> Enum.uniq |> Enum.filter(fn(x) -> x != nil end)
  end

  def fullcontact_websites(user) do
    urls = for email <- emails(user) do
      fullcontact_data = decoded_fullcontact_data(email.value)
      if fullcontact_data["contactInfo"]["websites"] do
        for website <- fullcontact_data["contactInfo"]["websites"] do
          website["url"]
        end
      end
    end |> List.flatten |> Enum.uniq |> Enum.filter(fn(x) -> x != nil end)
  end

  def fullcontact_social_media_accounts(user) do
    social_media_accounts = for email <- emails(user) do
      fullcontact_data = decoded_fullcontact_data(email.value)
      for social_profile <- fullcontact_data["socialProfiles"] do
        username = social_profile["username"]
        case social_profile["type"] do
          "github" ->
            %{"GitHub" => username}
          # "google" ->
          #   %{"Google+" => username}
          "twitter" ->
            %{"Twitter" => username}
          # "youtube" ->
          #   %{"Youtube" => username}
          # "instagram" ->
          #   username = social_profile["url"]
          #              |> String.replace("https://instagram.com/","")
          #   %{"Instagram" => username}
          "facebook" ->
            username = social_profile["url"]
                       |> String.replace("https://www.facebook.com/","")
            %{"Facebook" => username}
          _ ->
            nil
        end
      end
    end |> List.flatten |> Enum.uniq |> Enum.filter(fn(x) -> x != nil end)
  end

  def fullcontact_work_experiences(user) do
    social_media_accounts = for email <- emails(user) do
      fullcontact_data = decoded_fullcontact_data(email.value)

      if fullcontact_data["organizations"] do
        for organization <- fullcontact_data["organizations"] do
          start_date = organization["startDate"]
          end_date = organization["endDate"]

          work_experience = %{
                              organization: organization["name"],
                              title: organization["title"],
                              description: nil,
                              start_month: nil,
                              start_year: nil,
                              end_month: nil,
                              end_year: nil
                             }

          start_date_map = if start_date do
            case start_date |> String.split("-") do
              [year, month] ->
                %{start_year: year, start_month: month}
              [year] ->
                %{start_year: year}
              _ ->
                %{}
            end
          else
            %{}
          end

          end_date_map = if end_date do
            case end_date |> String.split("-") do
              [year, month] ->
                %{end_year: year, end_month: month}
              [year] ->
                %{end_year: year}
              _ ->
                %{}
            end
          else
            %{}
          end

          work_experience
          |> Map.merge(start_date_map)
          |> Map.merge(end_date_map)
        end
      end
    end |> List.flatten |> Enum.uniq |> Enum.filter(fn(x) -> x != nil end)
  end

  def enrich(user) do
    session_id = new_session_id(user)

    for email <- emails(user) do
      enrich(email, user, session_id)
    end
  end

  defp enrich(email, user, session_id) do
    add_avatar(user, session_id)
    add_websites(user, session_id)
    add_social_media_accounts(user, session_id)
    add_work_experiences(user, session_id)

    # add_tags(user, session_id, fullcontact_data)
    # add_address(user, session_id, email, fullcontact_data)
  end

  defp decoded_fullcontact_data(email_address) do
    fetch_fullcontact_json(email_address)
    |> Poison.decode!
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
          {:ok, %HTTPoison.Response{body: body, headers: _headers, status_code: 200}} ->
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
      if likelihood(fullcontact_data) do
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
          nil
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
              nil
          end
        end
      end
    end
  end

  defp add_work_experiences(user, session_id) do
    for work_experience <- enrichable_work_experiences(user) do
      changeset =
        user
        |> build_assoc(:work_experiences)
        |> WorkExperience.changeset(work_experience)

      unless data_enrichment_exists?(user, "Added work experience", work_experience_to_string(changeset.data)) do
        case Repo.insert(changeset) do
          {:ok, work_experience} ->
            store_data_enrichment(user, session_id, "Added work experience", work_experience_to_string(work_experience))
          _ ->
            nil
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
        nil
    end

    end_string = case {work_experience.end_year, work_experience.end_month} do
      {nil, nil} ->
        ""
      {year, nil} ->
        "#{year}"
      {year, month} ->
        "#{month}/#{year}"
      _ ->
        nil
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
        nil
    end
  end

  defp add_avatar(user, session_id) do
    if enrichable_avatar(user) do
      avatar_url = enrichable_avatar(user)
      download_and_store_avatar(user, avatar_url)
      store_data_enrichment(user, session_id, "Added avatar photo", avatar_url)
    end

    # unless user.avatar do
    #   if List.first(fullcontact_data["photos"]) do
    #     avatar_url = List.first(fullcontact_data["photos"])["url"]
    #     download_and_store_avatar(user, avatar_url)
    #     store_data_enrichment(user, session_id, "Added avatar photo", avatar_url)
    #   end
    # end
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
      _ ->
        nil
    end
  end

  defp add_websites(user, session_id) do
    if enrichable_websites(user) do
      for website <- enrichable_websites(user) do
        url = Ecto.build_assoc(user, :urls, value: website)

        unless data_enrichment_exists?(user, "Added website", url.value) do
          case Repo.insert(url) do
            {:ok, url} ->
              Task.start(__MODULE__, :generate_screenshot, [url])
              store_data_enrichment(user, session_id, "Added website", url.value)
            _ ->
              nil
          end
        end
      end
    end
  end

  defp add_social_media_accounts(user, session_id) do
    for social_media_account <- enrichable_social_media_accounts(user) do
      provider = social_media_account |> Map.keys |> List.first
      username = social_media_account |> Map.values |> List.first
      case provider do
        "GitHub" ->
          add_social_media_provider(user, session_id, "GitHub", username)
        "Google+" ->
          add_social_media_provider(user, session_id, "Google+", username)
        "Twitter" ->
          add_social_media_provider(user, session_id, "Twitter", username)
        "Youtube" ->
          add_social_media_provider(user, session_id, "Youtube", username)
        "Instagram" ->
          add_social_media_provider(user, session_id, "Instagram", username)
        "Facebook" ->
          add_social_media_provider(user, session_id, "Facebook", username)
        _ ->
          nil
      end
    end
  end

  defp has_account_at_provider?(user, provider) do
    user = user
           |>Repo.preload([social_media_accounts: from(u in Vutuv.SocialMediaAccount)])

    for social_media_account <- user.social_media_accounts do
      if social_media_account.provider == provider do
        true
      end
    end |> Enum.member?(true)
  end

  defp has_account_at_provider?(user, provider, account) do
    user = user
           |>Repo.preload([social_media_accounts: from(u in Vutuv.SocialMediaAccount)])

    for social_media_account <- user.social_media_accounts do
      if social_media_account.provider == provider do
        if social_media_account.value == account do
          true
        end
      end
    end |> Enum.member?(true)
  end

  defp add_social_media_provider(user, session_id, provider, account) do
    # Don't add a social media account to an already existing provider.
    unless has_account_at_provider?(user, provider) do
      social_media_account = Ecto.build_assoc(user, :social_media_accounts, %{value: account, provider: provider})

      unless data_enrichment_exists?(user, "Added #{social_media_account.provider} account", account) do
        case Repo.insert(social_media_account) do
          {:ok, social_media_account} ->
            store_data_enrichment(user, session_id, "Added #{social_media_account.provider} account", account)
          _ ->
            nil
        end
      end
    end
  end

  # Not a defp!
  def generate_screenshot(url) do
    Vutuv.Browserstack.generate_screenshot(url)
  end

end

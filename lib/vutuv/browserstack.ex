defmodule Vutuv.Browserstack do
  import Ecto.Query
  alias Vutuv.Screenshot
  alias Vutuv.Url
  alias Vutuv.Repo

  def store_screenshot(url) do
    job_id = job_id(url)
    :timer.sleep(30000)
    image_url = image_url(job_id)
    image_url
  end

  def job_id(url) do
    hackney = [basic_auth: {Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:browserstack_user], Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:browserstack_password]}]
    headers = ["Content-Type": "application/json", "Accept": "Application/json; Charset=utf-8"]

    case HTTPoison.post "https://www.browserstack.com/screenshots", "{\"browsers\": [{\"os\": \"Windows\", \"os_version\": \"10\", \"browser_version\": \"50.0\", \"browser\": \"chrome\", \"orientation\": \"landscape\"}], \"url\": \"#{url.value}\"}", headers, [ hackney: hackney ] do
      {:ok, %HTTPoison.Response{status_code: 404}} -> nil
      {:ok, %HTTPoison.Response{body: body, headers: headers}} ->
        decoded_body = body |> Poison.decode!
        {:ok, job_id} = Map.fetch(decoded_body, "job_id")
        job_id
      _ -> nil
    end
  end

  def image_url(job_id) do
    hackney = [basic_auth: {Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:browserstack_user], Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:browserstack_password]}]

    case HTTPoison.get("https://www.browserstack.com/screenshots/#{job_id}.json", %{},[ hackney: hackney ]) do
      {:ok, %HTTPoison.Response{status_code: 404}} -> nil
      {:ok, %HTTPoison.Response{body: body, headers: headers}} ->
         decoded_body = body |> Poison.decode!
         {:ok, results} = Map.fetch(decoded_body, "screenshots")
         {:ok, image_url} = Map.fetch(List.first(results), "image_url")
         image_url
      _ -> nil
    end
  end

  # def store_gravatar(user) do
  #   case HTTPoison.get("https://www.gravatar.com/avatar/#{hd(user.emails).md5sum}?s=130&d=404", [], [timeout: 1000, recv_timeout: 1000])  do
  #     {:ok, %HTTPoison.Response{status_code: 404}} -> nil
  #     {:ok, %HTTPoison.Response{body: body, headers: headers}} ->
  #       content_type = find_content_type(headers)
  #       filename = "/#{user.active_slug}.#{String.replace(content_type,"image/", "")}"
  #       path = System.tmp_dir
  #       upload = #create the upload struct that arc-ecto will use to store the file and update the database
  #         %Plug.Upload{content_type: content_type,
  #         filename: filename,
  #         path: path<>filename}
  #       File.write(path<>filename, body) #Write the file temporarily to the disk
  #       user
  #       |> Repo.preload([:slugs, :oauth_providers, :emails])
  #       |> User.changeset(%{avatar: upload}) #update the user with the upload struct
  #       |> Repo.update
  #     _ -> nil
  #   end
  # end

end

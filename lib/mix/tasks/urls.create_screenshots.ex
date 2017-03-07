defmodule Mix.Tasks.Urls.CreateScreenshots do
  use Mix.Task
  import Mix.Ecto
  import Ecto.Query
  alias Vutuv.Repo
  alias Vutuv.User

  @shortdoc "Creates screenshots for all Urls."

  def run(_args) do
    Mix.Task.run "app.start", []

    ensure_started(Repo, [])
    users = Repo.all(from u in User)

    for(user <- users) do
      user =
        user
        |>Vutuv.Repo.preload(:urls)

      if Enum.count(user.urls) > 0 do
        IO.puts "#{user.first_name} #{user.last_name}"
        for url <- user.urls do
          unless url.screenshot do
            IO.puts "-> #{url.value}"
            Vutuv.Browserstack.generate_screenshot(url)
            :timer.sleep(500)
          end
        end
      end
    end
  end
end

defmodule Mix.Tasks.Avatar.CreateSymLinks do
  use Mix.Task
  import Mix.Ecto
  import Ecto.Query
  alias Vutuv.Repo
  alias Vutuv.User

  @shortdoc "Creates sym links for avatars which can be delivered by nginx without triggering Phoenix."

  def run(_args) do
    ensure_started(Repo, [])
    users = Repo.all(from u in User, where: not is_nil(u.avatar), limit: 10)

    for(user <- users) do
      timestamp = user.updated_at
      |> Ecto.DateTime.to_string
      |> String.replace(~r/[^0-9]/,"")

      nginx_path = user.active_slug
      |> String.replace(".","/")

      source_path = "/srv/vutuv/avatars/#{user.id}"
      destination_path = "/var/www/www.vutuv.de/avatars/#{nginx_path}/#{timestamp}"

      # Create the sym link
      #
      if File.exists?(source_path) && File.exists?("/var/www/www.vutuv.de/avatars/") do
        unless File.exists?(destination_path) do
          File.mkdir_p("/var/www/www.vutuv.de/avatars/#{nginx_path}/")
          File.ln_s(source_path, destination_path)
        end
      end
    end
  end
end

defmodule Mix.Tasks.HelloPhoenix.Greeting do
  use Mix.Task
  import Mix.Ecto
  import Ecto.Query
  alias Vutuv.Repo
  alias Vutuv.User

  def run(_args) do
  	Vutuv.Repo.start_link
    users = Repo.all(from u in User, where: not is_nil(u.avatar))

    for(user <- users) do
    	IO.inspect Vutuv.Avatar.user_url(user, :small) #symlink small images
    	IO.inspect Vutuv.Avatar.user_url(user, :medium) #symlink medium images
    	IO.inspect Vutuv.Avatar.user_url(user, :large) #symlink large images
		end
  end
end
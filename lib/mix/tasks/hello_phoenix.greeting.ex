defmodule Mix.Tasks.HelloPhoenix.Greeting do
  use Mix.Task
<<<<<<< HEAD
  import Mix.Ecto
  import Ecto.Query
=======
  import Mix.Ecto 
  use Ecto.Queryable
>>>>>>> Initial commit for locales.
  alias Vutuv.Repo
  alias Vutuv.User

  def run(_args) do
<<<<<<< HEAD
  	Vutuv.Repo.start_link
    users = Repo.all(from u in User, where: not is_nil(u.avatar))

    for(user <- users) do
    	IO.inspect Vutuv.Avatar.user_url(user, :small) #symlink small images
    	IO.inspect Vutuv.Avatar.user_url(user, :medium) #symlink medium images
    	IO.inspect Vutuv.Avatar.user_url(user, :large) #symlink large images
		end
=======
    users = Repo.all(from u in User, select: %User{last_name: u.last_name})
>>>>>>> Initial commit for locales.
  end
end
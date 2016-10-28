defmodule Vutuv.PageController do
  use Vutuv.Web, :controller
  alias Vutuv.User
  alias Vutuv.Email

  plug :put_layout, "no_layout.html" when action in [:index]

  def index(conn, _params) do
    user_count = Repo.one(from u in User, select: count("*"))

    changeset =
      User.changeset(%User{})
      |> Ecto.Changeset.put_assoc(:emails, [%Email{}])

    render conn, "index.html", changeset: changeset, user_count: user_count
  end
end

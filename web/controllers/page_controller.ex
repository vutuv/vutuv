defmodule Vutuv.PageController do
  use Vutuv.Web, :controller
  plug Vutuv.Plug.RequireUserLoggedOut when action in [:index]
  import Vutuv.UserHelpers
  alias Vutuv.User
  alias Vutuv.Email

  def index(conn, _params) do
    user_count = Repo.one(from u in User, select: count("*"))

    changeset =
      User.changeset(%User{})
      |> Ecto.Changeset.put_assoc(:emails, [%Email{}])

    render conn, "index.html", changeset: changeset, user_count: user_count, body_class: "stretch"
  end

  def redirect_index(conn, _params) do
    redirect conn, to: page_path(conn, :index)
  end

  def new_registration(conn, %{"user" => user_params}) do
    email = user_params["emails"]["0"]["value"]
    case Vutuv.Registration.register_user(conn, user_params) do
      {:ok, user} ->
        case Vutuv.Auth.login_by_email(conn, email) do
          {:ok, conn} ->
            conn
            |> Vutuv.Auth.logout
            |> render("new_registration.html", body_class: "stretch")
          {:error, _reason, conn} ->
            conn
            |> put_flash(:error, gettext("There was an error"))
            |> redirect(to: page_path(conn, :index))
        end
      {:error, changeset} ->
        render(conn, "index.html", changeset: changeset, body_class: "stretch")
    end
  end
end

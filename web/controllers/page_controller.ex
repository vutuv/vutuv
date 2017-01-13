defmodule Vutuv.PageController do
  use Vutuv.Web, :controller
  plug :display_pin_entry when action in [:index]
  plug Vutuv.Plug.RequireUserLoggedOut when action in [:index]
  alias Vutuv.User
  alias Vutuv.Email

  def index(conn, _params) do
    changeset =
      User.changeset(%User{})
      |> Ecto.Changeset.put_assoc(:emails, [%Email{}])
    prefetch = "/listings/most_followed_users"

    render conn, "index.html", changeset: changeset, body_class: "stretch", prefetch: prefetch
  end

  def redirect_index(conn, _params) do
    redirect conn, to: page_path(conn, :index)
  end

  def redirect_user(conn, %{"slug" => slug}) do
    conn
    |> put_status(301)
    |> redirect(to: user_path(conn, :show, slug))
  end

  def impressum(conn, _params) do
    render conn, "impressum.html", conn: conn, body_class: "stretch"
  end

  def new_registration(conn, %{"user" => user_params}) do
    email = user_params["emails"]["0"]["value"]
    case Vutuv.Registration.register_user(conn, user_params) do
      {:ok, _user} ->
        case Vutuv.Auth.login_by_email(conn, email) do
          {:ok, conn} ->
            case conn.cookies["_vutuv_fbs_temp"] do
              nil -> 
                conn
                |> render("new_registration.html", body_class: "stretch")
              _ -> 
                conn
                |> render("pin_new_registration.html", body_class: "stretch")
            end
          {:error, _reason, conn} ->
            conn
            |> redirect(to: page_path(conn, :index))
        end
      {:error, changeset} ->
        render(conn, "index.html", changeset: changeset, body_class: "stretch")
    end
  end

  def most_followed_users(conn, _params) do
    users = Repo.all(from u in User, left_join: f in assoc(u, :followers), group_by: u.id, order_by: [fragment("count(?) DESC", f.id), u.first_name, u.last_name], limit: 100)
    render conn, "most_followed_users.html", users: users
  end

  defp display_pin_entry(conn, _params) do
    case conn.cookies["_vutuv_fbs_temp"] do
      nil -> conn
      _ -> check_pin_session conn
    end
  end

  defp check_pin_session(conn) do
    Vutuv.Repo.one(from m in Vutuv.MagicLink,
        left_join: u in assoc(m, :user), 
        left_join: e in assoc(u, :emails),
        where: e.value == ^unform_pin_cookie(conn) and m.magic_link_type == ^("login"),
        select: m.magic_link_created_at)
    |> case do
      nil -> delete_resp_cookie(conn, "_vutuv_fbs_temp", max_age: 1800)
      _ ->
        conn
        |> render(Vutuv.SessionView, "pin_user_login.html", body_class: "stretch")
        |> halt
    end
  end

  defp unform_pin_cookie(%{cookies: %{"_vutuv_fbs_temp" => payload}} = conn) do
    salt = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:secret_key_base]
    Phoenix.Token.verify(conn, salt, payload)
    |> case do
      {:ok, email} -> email
      _ -> ""
    end
  end
end

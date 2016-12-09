defmodule Vutuv.Admin.SlugController do
  use Vutuv.Web, :controller
  plug :logged_in?
  plug Vutuv.Plug.AuthAdmin

  alias Vutuv.Slug

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def update(conn, %{"slug_disable"=> %{"value"=> value}}) do
    case Repo.one(from s in Slug, where: s.value==^value) do
      nil ->
        conn
        |> put_flash(:error, gettext("Slug doesn't exist."))
        |> render("index.html")
      slug->
        changeset = Ecto.Changeset.cast(slug, %{disabled: true}, [:disabled])
        case Repo.update(changeset) do
          {:ok, slug} ->
            user = Repo.get(Vutuv.User, slug.user_id)
              |>Repo.preload(:slugs)

            user_changeset = 
            case Repo.all(from s in Slug, where: s.user_id == ^slug.user_id and s.disabled == false, select: s.value) do
              [] ->
                slug_value = Vutuv.SlugHelpers.gen_slug_unique(user, Vutuv.Slug, :value)
                Ecto.Changeset.cast(user, %{active_slug: slug_value}, [:active_slug])
                |>Ecto.Changeset.put_assoc(:slugs, [Slug.changeset(%Slug{}, %{value: slug_value})], [:value])
              new -> Ecto.Changeset.cast(user, %{active_slug: hd(new)}, [:active_slug])
            end
            case Repo.update(user_changeset) do
              {:ok, _user} ->
                conn
                |> put_flash(:info, gettext("Slug disabled successfully."))
                |> redirect(to: admin_admin_path(conn, :index))
              {:error, _user_changeset} ->
                redirect(conn, to: admin_admin_path(conn, :index))
            end
          {:error, _changeset} ->
            redirect(conn, to: admin_admin_path(conn, :index))
        end
    end
  end

  defp logged_in?(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, gettext("You must be logged in to access that page"))
      |> redirect(to: page_path(conn, :index))
      |> halt()
    end
  end
end

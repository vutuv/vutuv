defmodule Vutuv.SlugController do
  use Vutuv.Web, :controller
  alias Vutuv.Slug
  import Ecto

  plug :resolve_slug

  def index(conn, _params) do
    slugs = Repo.all(assoc(conn.assigns[:user], :slugs))
    render(conn, "index.html", slugs: slugs)
  end

  def new(conn, _params) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:slugs)
      |> Slug.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"slug"=>params}) do
    case Repo.transaction(new_slug(conn.assigns[:user], params)) do
      {:ok, %{user: user, slug: _slug}} ->
        conn
        |> put_flash(:info, "Slug updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, _failure, changeset, _} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    slug = Repo.get!(assoc(conn.assigns[:user], :slugs), id)
    render(conn, "show.html", slug: slug)
  end

  def update(conn, %{"id" => id}) do
    slug = Repo.get!(assoc(conn.assigns[:user], :slugs), id)
    changeset = Ecto.Changeset.cast(conn.assigns[:current_user], %{active_slug: slug.value}, [:active_slug])
    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Slug activated successfully")
        |> redirect(to: user_slug_path(conn, :index, user))
      {:error, _changeset} ->
        redirect(conn, to: user_slug_path(conn, :index,conn.assigns[:current_user]))
    end
  end

  def resolve_slug(conn, _opts) do
    case conn.params do
      %{"user_slug" => slug} ->
        case Repo.one(from s in Slug, where: s.value == ^slug, select: s.user_id) do
          nil  -> invalid_slug(conn)
          user_id ->
            user = Repo.one(from u in Vutuv.User, where: u.id == ^user_id)
            assign(conn, :user, user)
        end
      _ -> invalid_slug(conn)
    end
  end

  defp invalid_slug(conn) do
    conn
    |> put_flash(:error, "404")
    |> redirect(to: page_path(conn, :index))
    |> halt
  end

  def new_slug(user, params) do
    slug_changeset =
      user
      |> build_assoc(:slugs)
      |> Slug.changeset(params)

    user_changeset = Ecto.Changeset.cast(user,%{"active_slug"=> params.value},[:active_slug],[])

    Ecto.Multi.new
    |>Ecto.Multi.insert(:slug, slug_changeset)
    |>Ecto.Multi.update(:user, user_changeset)
  end
end

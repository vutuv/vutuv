defmodule Vutuv.SlugController do
  use Vutuv.Web, :controller
  alias Vutuv.Slug
  import Ecto
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

  def new_slug(user, params) do
    slug_changeset =
      user
      |> build_assoc(:slugs)
      |> Slug.changeset(params)
    IO.puts("\n\n\n")
    IO.puts(inspect slug_changeset)
    IO.puts("\n\n\n")

    user_changeset = Ecto.Changeset.cast(user,%{"active_slug"=> slug_changeset.changes.value},[:active_slug],[])

    Ecto.Multi.new
    |>Ecto.Multi.insert(:slug, slug_changeset)
    |>Ecto.Multi.update(:user, user_changeset)
  end
end

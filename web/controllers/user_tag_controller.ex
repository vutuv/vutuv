defmodule Vutuv.UserTagController do
  use Vutuv.Web, :controller

  plug Vutuv.Plug.AuthUser when not action in [:index, :show]
  plug :scrub_params, "tag_param" when action in [:create]

  alias Vutuv.UserTag
  alias Vutuv.Tag

  def index(conn, _params) do
    user =
    conn.assigns[:user]
    |> Repo.preload([:user_tags])
    render(conn, "index.html", user: user, user_tags: user.user_tags)
  end

  def new(conn, _params) do
    changeset = UserTag.changeset(%UserTag{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tag_param" => tag_param}) do
    conn.assigns[:current_user]
    |> Ecto.build_assoc(:user_tags, %{})
    |> UserTag.changeset
    |> Tag.create_or_link_tag(tag_param)
    |> Repo.insert
    |> case do
      {:ok, _user_tag} ->
        conn
        |> put_flash(:info, gettext("User tag created successfully."))
        |> redirect(to: user_user_tag_path(conn, :index, conn.assigns[:user]))
      {:error, changeset} ->
        IO.puts "\n\n#{inspect changeset}\n\n"
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user_tag = Repo.get!(assoc(conn.assigns[:user], :user_tags), id)
    render(conn, "show.html", user_tag: user_tag)
  end

  def delete(conn, %{"id" => id}) do
    user_tag = Repo.get!(UserTag, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user_tag)

    conn
    |> put_flash(:info, gettext("User tag deleted successfully."))
    |> redirect(to: user_user_tag_path(conn, :index, conn.assigns[:user]))
  end
end

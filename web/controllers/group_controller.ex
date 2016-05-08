defmodule Vutuv.GroupController do
  use Vutuv.Web, :controller
  plug :assign_user

  alias Vutuv.Group

  plug :scrub_params, "group" when action in [:create, :update]

  def index(conn, _params) do
    groups = Repo.all(Group) |> Repo.preload([:user])
    render(conn, "index.html", groups: groups)
  end

  def new(conn, _params) do
    changeset = Group.changeset(%Group{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"group" => group_params}) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:groups)
      |> Group.changeset(group_params)

    case Repo.insert(changeset) do
      {:ok, _group} ->
        conn
        |> put_flash(:info, "Group created successfully.")
        |> redirect(to: user_group_path(conn, :index, conn.assigns[:user]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    group = Repo.get!(Group, id)
    render(conn, "show.html", group: group)
  end

  def edit(conn, %{"id" => id}) do
    group = Repo.get!(Group, id)
    changeset = Group.changeset(group)
    render(conn, "edit.html", group: group, changeset: changeset)
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    group = Repo.get!(Group, id)
    changeset = Group.changeset(group, group_params)

    case Repo.update(changeset) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group updated successfully.")
        |> redirect(to: user_group_path(conn, :show, conn.assigns[:user], group))
      {:error, changeset} ->
        render(conn, "edit.html", group: group, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    group = Repo.get!(Group, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(group)

    conn
    |> put_flash(:info, "Group deleted successfully.")
    |> redirect(to: user_group_path(conn, :index, conn.assigns[:user]))
  end

  defp assign_user(conn, _opts) do
    case conn.params do
      %{"user_id" => user_id} ->
        case Repo.get(Vutuv.User, user_id) do
          nil  -> invalid_user(conn)
          user -> assign(conn, :user, user)
        end
      _ -> invalid_user(conn)
    end
  end

  defp invalid_user(conn) do
    conn
    |> put_flash(:error, "Invalid user!")
    |> redirect(to: page_path(conn, :index))
    |> halt
  end
end

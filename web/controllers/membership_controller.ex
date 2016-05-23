defmodule Vutuv.MembershipController do
  use Vutuv.Web, :controller
  plug :assign_connection

  alias Vutuv.Membership

  plug :scrub_params, "membership" when action in [:create, :update]

  def index(conn, _params) do
    connection =
      Repo.get!(Vutuv.Connection, conn.assigns[:connection].id)
      |> Repo.preload([:memberships])

    render(conn, "index.html", memberships: connection.memberships)
  end

  def new(conn, _params) do
    changeset = Membership.changeset(%Membership{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"membership" => membership_params}) do
    changeset =
      conn.assigns[:connection]
      |> build_assoc(:memberships)
      |> Membership.changeset(membership_params)

    case Repo.insert(changeset) do
      {:ok, _membership} ->
        conn
        |> put_flash(:info, "Membership created successfully.")
        |> redirect(to: connection_membership_path(conn, :index, conn.assigns[:connection]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    membership = Repo.get!(Membership, id)
    render(conn, "show.html", membership: membership)
  end

  def edit(conn, %{"id" => id}) do
    membership = Repo.get!(Membership, id)
    changeset = Membership.changeset(membership)
    render(conn, "edit.html", membership: membership, changeset: changeset)
  end

  def update(conn, %{"id" => id, "membership" => membership_params}) do
    membership = Repo.get!(Membership, id)
    changeset = Membership.changeset(membership, membership_params)

    case Repo.update(changeset) do
      {:ok, membership} ->
        conn
        |> put_flash(:info, "Membership updated successfully.")
        |> redirect(to: membership_path(conn, :show, membership))
      {:error, changeset} ->
        render(conn, "edit.html", membership: membership, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    membership = Repo.get!(Membership, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(membership)

    conn
    |> put_flash(:info, "Membership deleted successfully.")
    |> redirect(to: connection_membership_path(conn, :index, conn.assigns[:connection]))
  end

  defp assign_connection(conn, _opts) do
    case conn.params do
      %{"connection_id" => connection_id} ->
        case Repo.get(Vutuv.Connection, connection_id) do
          nil  -> invalid_connection(conn)
          connection -> assign(conn, :connection, connection)
        end
      _ -> invalid_connection(conn)
    end
  end

  defp invalid_connection(conn) do
    conn
    |> put_flash(:error, "Invalid connection!")
    |> redirect(to: page_path(conn, :index))
    |> halt
  end
end

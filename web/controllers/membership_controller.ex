defmodule Vutuv.MembershipController do
  use Vutuv.Web, :controller
  plug :assign_connection

  alias Vutuv.Membership
  alias Vutuv.Connection

  plug :scrub_params, "membership" when action in [:create, :update]

  def index(conn, _params) do
    render(conn, "index.html", connection: conn.assigns[:connection])
  end

  def new(conn, _params) do
    changeset =
      conn.assigns[:connection]
      |> build_assoc(:memberships)
      |> Membership.changeset()
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
        |> put_flash(:info, gettext("Membership created successfully."))
        |> redirect(to: connection_membership_path(conn, :index, conn.assigns[:connection]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    membership = Repo.get!(Membership, id)
    render(conn, "show.html", membership: membership)
  end

  def delete(conn, %{"id" => id}) do
    membership = Repo.get!(Membership, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(membership)

    conn
    |> put_flash(:info, gettext("Membership deleted successfully."))
    |> redirect(to: connection_membership_path(conn, :index, conn.assigns[:connection]))
  end

  defp assign_connection(conn, _opts) do
    case conn.params do
      %{"connection_id" => connection_id} ->
        case Repo.get(Connection, connection_id)
             |> Repo.preload([:memberships, :groups, :follower, :followee]) do
          nil  -> invalid_connection(conn)
          connection -> assign(conn, :connection, connection)
        end
      _ -> invalid_connection(conn)
    end
  end

  defp invalid_connection(conn) do
    conn
    |> put_flash(:error, gettext("Invalid connection!"))
    |> redirect(to: page_path(conn, :index))
    |> halt
  end
end

defmodule Vutuv.EndorsementController do
  use Vutuv.Web, :controller
  plug :resolve_slug

  alias Vutuv.Endorsement

  def create(conn, %{"id" => id}) do
    changeset = Endorsement.changeset(%Endorsement{}, %{user_skill_id: id, user_id: conn.assigns[:current_user].id})
    case Repo.insert(changeset) do
      {:ok, _user_skill} ->
        conn
        |> put_flash(:info, gettext("Endorsement successful."))
        |> redirect(to: user_path(conn, :show, conn.assigns[:user]))
      {:error, _changeset} ->
        conn
        |> put_flash(:info, gettext("Endorsement unsuccessful."))
        |> redirect(to: user_path(conn, :show, conn.assigns[:user]))
    end
  end

  def delete(conn, %{"id" => id}) do
    Repo.one!(from e in Vutuv.Endorsement, where: e.user_skill_id==^id and e.user_id==^conn.assigns[:current_user].id )
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    |>Repo.delete!

    conn
    |> put_flash(:info, gettext("Unendorsed skill successfully."))
    |> redirect(to: user_path(conn, :show, conn.assigns[:user]))
  end

  def resolve_slug(conn, _opts) do
    case conn.params do
      %{"user_slug" => slug} ->
        case Repo.one(from s in Vutuv.Slug, where: s.value == ^slug, select: s.user_id) do
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
    |> put_status(:not_found)
    |> render(Vutuv.ErrorView, "404.html")
    |> halt
  end
end

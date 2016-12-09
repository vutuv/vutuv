defmodule Vutuv.EndorsementController do
  use Vutuv.Web, :controller
  plug :resolve_slug

  alias Vutuv.Endorsement

  def create(conn, _params) do
    changeset = Endorsement.changeset(%Endorsement{}, %{user_skill_id: conn.assigns[:user_skill_id], user_id: conn.assigns[:current_user_id]})
    case Repo.insert(changeset) do
      {:ok, _user_skill} ->
        conn
        |> put_flash(:info, gettext("Endorsement successful."))
        |> redirect(to: referrer_url(conn))
      {:error, _changeset} ->
        conn
        |> put_flash(:info, gettext("Endorsement unsuccessful."))
        |> redirect(to: referrer_url(conn))
    end
  end

  def delete(conn, _params) do
    Repo.one!(from e in Vutuv.Endorsement, where: e.user_skill_id==^conn.assigns[:user_skill_id] and e.user_id==^conn.assigns[:current_user_id] )
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    |>Repo.delete!

    conn
    |> put_flash(:info, gettext("Unendorsed skill successfully."))
    |> redirect(to: referrer_url(conn))
  end

  def referrer_url(conn) do
    referrer = 
      conn
      |> Plug.Conn.get_req_header("referer")
      |> hd
      |> URI.parse
      |> Map.get(:path)
    if(referrer) do
      referrer
    else
      user_path(conn, :show, conn.assigns[:user])
    end
  end

  defp resolve_slug(%{params: %{"id" => slug}} = conn, _) do
    Repo.one(from w in assoc(conn.assigns[:user], :user_skills), join: s in assoc(w, :skill), where: s.slug == ^slug, select: w.id)
    |>case do
      nil -> 
        conn
        |> put_status(404)
        |> render(Vutuv.ErrorView, "404.html")
      id -> assign(conn, :user_skill_id, id)
    end
    
  end

  defp resolve_slug(conn, _), do: conn
end

defmodule Vutuv.UserTagEndorsementController do
  use Vutuv.Web, :controller

  plug :resolve_slug
  plug :require_user_logged_in

  alias Vutuv.UserTagEndorsement

  def create(conn, _params) do
    changeset = UserTagEndorsement.changeset(%UserTagEndorsement{},
      %{user_tag_id: conn.assigns[:user_tag_id], user_id: conn.assigns[:current_user_id]})
    case Repo.insert(changeset) do
      {:ok, _user_tag_endorsement} ->
        conn
        |> put_flash(:info, gettext("Endorsement successful."))
        |> redirect(to: referrer_url(conn))
      {:error, _changeset} ->
        conn
        |> put_flash(:info, gettext("Endorsement unsuccessful."))
        |> redirect(to: referrer_url(conn))
    end
  end

  def delete(conn) do
    Repo.one!(from e in Vutuv.UserTagEndorsement, where: e.user_tag_id==^conn.assigns[:user_tag_id] and e.user_id==^conn.assigns[:current_user_id] )
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    |> Repo.delete!()

    conn
    |> put_flash(:info, gettext("Unendorsed tag successfully."))
    |> redirect(to: referrer_url(conn))
  end

  def referrer_url(conn) do
    referrer = 
      conn
      |> Plug.Conn.get_req_header("referer")
      |> hd
      |> URI.parse
      |> Map.get(:path)
    referrer || user_path(conn, :show, conn.assigns[:user])
  end

  defp resolve_slug(%{params: %{"id" => slug}} = conn, _) do
    Repo.one(from w in assoc(conn.assigns[:user], :user_tags), join: t in assoc(w, :tag), where: t.slug == ^slug, select: w.id)
    |>case do
      nil -> 
        conn
        |> put_status(404)
        |> render(Vutuv.ErrorView, "404.html")
      id -> assign(conn, :user_tag_id, id)
    end
  end

  defp resolve_slug(conn, _), do: conn

  defp require_user_logged_in(conn, _) do
    case(conn.assigns[:current_user_id]) do
      nil ->
        conn
        |> put_status(404)
        |> render(Vutuv.ErrorView, "404.html")
      id -> conn
    end
  end
end

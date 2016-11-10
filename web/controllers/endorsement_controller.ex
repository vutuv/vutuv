defmodule Vutuv.EndorsementController do
  use Vutuv.Web, :controller

  alias Vutuv.Endorsement

  def create(conn, %{"id" => id}) do
    referrer = 
      conn
      |> Plug.Conn.get_req_header("referer")
      |> hd
      |> URI.parse
      |> Map.get(:path)
    redirect_url = 
      if(referrer) do
        referrer
      else
        user_path(conn, :show, conn.assigns[:user])
      end
    changeset = Endorsement.changeset(%Endorsement{}, %{user_skill_id: id, user_id: conn.assigns[:current_user].id})
    case Repo.insert(changeset) do
      {:ok, _user_skill} ->
        conn
        |> put_flash(:info, gettext("Endorsement successful."))
        |> redirect(to: redirect_url)
      {:error, _changeset} ->
        conn
        |> put_flash(:info, gettext("Endorsement unsuccessful."))
        |> redirect(to: redirect_url)
    end
  end

  def delete(conn, %{"id" => id}) do
    referrer = 
      conn
      |> Plug.Conn.get_req_header("referer")
      |> hd
      |> URI.parse
      |> Map.get(:path)
    redirect_url = 
      if(referrer) do
        referrer
      else
        user_path(conn, :show, conn.assigns[:user])
      end
    Repo.one!(from e in Vutuv.Endorsement, where: e.user_skill_id==^id and e.user_id==^conn.assigns[:current_user].id )
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    |>Repo.delete!

    conn
    |> put_flash(:info, gettext("Unendorsed skill successfully."))
    |> redirect(to: redirect_url)
  end
end

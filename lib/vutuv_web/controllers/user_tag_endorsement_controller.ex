defmodule VutuvWeb.UserTagEndorsementController do
  use VutuvWeb, :controller

  import VutuvWeb.Authorize

  alias Vutuv.Tags

  def action(conn, _), do: auth_action_slug(conn, __MODULE__)

  def create(conn, %{"user_tag_endorsement" => params}, current_user) do
    case Tags.create_user_tag_endorsement(current_user, params) do
      {:ok, _endorsement} ->
        conn
        |> put_flash(:info, gettext("User tag endorsed successfully."))
        |> redirect(to: Routes.user_path(conn, :show, current_user))

      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_flash(:info, gettext("Unable to endorse user tag."))
        |> redirect(to: Routes.user_path(conn, :show, current_user))
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    endorsement = Tags.get_user_tag_endorsement!(current_user, id)
    Tags.delete_user_tag_endorsement(endorsement)

    conn
    |> put_flash(:info, gettext("User tag endorsement deleted successfully."))
    |> redirect(to: Routes.user_path(conn, :show, current_user))
  end
end

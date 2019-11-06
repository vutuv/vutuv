defmodule VutuvWeb.Api.UserTagEndorsementController do
  use VutuvWeb, :controller

  import VutuvWeb.Authorize

  alias Vutuv.{Tags, Tags.UserTagEndorsement}

  action_fallback VutuvWeb.Api.FallbackController

  def action(conn, _), do: auth_action_slug(conn, __MODULE__)

  def create(conn, %{"user_tag_endorsement" => user_tag_endorsement_params}, current_user) do
    with {:ok, %UserTagEndorsement{} = user_tag_endorsement} <-
           Tags.create_user_tag_endorsement(current_user, user_tag_endorsement_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.api_user_path(conn, :show, user_tag_endorsement))
      |> render("show.json", user_tag_endorsement: user_tag_endorsement)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    user_tag_endorsement = Tags.get_user_tag_endorsement!(current_user, id)

    with {:ok, %UserTagEndorsement{}} <- Tags.delete_user_tag_endorsement(user_tag_endorsement) do
      send_resp(conn, :no_content, "")
    end
  end
end

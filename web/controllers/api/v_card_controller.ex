defmodule Vutuv.Api.VCardController do
  use Vutuv.Web, :controller
  import Ecto.Query

  plug :assign_user
  plug :headers

  def get(conn, _params) do
    vcard = conn.assigns[:user]
      |> Repo.preload([:addresses, :phone_numbers,
        social_media_accounts: from(s in Vutuv.SocialMediaAccount, where: s.provider == ^"Twitter")])
      |> preload_emails(conn.assigns[:current_user])
    render(conn, "vcard.vcf", v_card: vcard)
  end

  defp preload_emails(user, requester) do
    if(Vutuv.UserHelpers.user_has_permissions?(user, requester)) do
      Repo.preload(user, [:emails])
    else
      user
    end
  end

  defp assign_user(conn, _opts) do
    conn = fetch_session(conn)
    user_id = get_session(conn, :user_id)
    user = user_id && Vutuv.Repo.get(Vutuv.User, user_id)
    conn
    |> assign(:current_user, user)
  end

  defp headers(conn, _opts) do
    filename = "#{Vutuv.UserHelpers.first_and_last(conn.assigns[:user], "_") |> String.downcase}_vcard.vcf"
    conn
    |> Plug.Conn.put_resp_header("Content-Type", "text/vcard;charset=utf-8")
    |> Plug.Conn.put_resp_header("Content-Disposition", "attachment;filename = #{filename}")
  end
end

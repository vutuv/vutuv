defmodule Vutuv.Api.VCardController do
  use Vutuv.Web, :controller
  plug :headers

  def get(conn, _params) do
    vcard = conn.assigns[:user]
      |> Repo.preload([:addresses, :phone_numbers])
      |> preload_emails(conn.assigns[:current_user])
    render(conn, "vcard.vcf", v_card: vcard)
  end

  defp preload_emails(user, requester) do
    if(Vutuv.UserHelpers.user_follows_user?(user, requester)) do
      Repo.preload(user, [:emails])
    else
      user
    end
  end

  defp headers(conn, _opts) do
    filename = "#{Vutuv.UserHelpers.first_and_last(conn.assigns[:user], "_") |> String.downcase}_vcard.vcf"
    conn
    |> Plug.Conn.put_resp_header("Content-Type", "text/vcard;charset=utf-8")
    |> Plug.Conn.put_resp_header("Content-Disposition", "attachment;filename = #{filename}")
  end
end

defmodule Vutuv.Api.VCardController do
  use Vutuv.Web, :controller
  plug :headers

  def get(conn, _params) do
    vcard = conn.assigns[:user]
      |> Repo.preload([:addresses, :phone_numbers])
      |> preload_emails(conn.assigns[:current_user])
    render(conn, "vcard.vcf", v_card: vcard)
    

    #v_cards = Repo.all(User)
    #  |>Repo.preload([:emails, :addresses,
    #                  :phone_numbers])
    #render(conn, "index.json", v_cards: v_cards)
  end

  defp preload_emails(user, requester) do
    if(Vutuv.UserHelpers.user_follows_user?(user, requester)) do
      Repo.preload(user, [:emails])
    else
      user
    end
  end

  defp headers(conn, _opts) do
    conn
    |> Plug.Conn.put_resp_header("Content-Type", "text/vcard")
    |> Plug.Conn.put_resp_header("Content-Disposition", "attachment;filename = vcard.vcf")
  end
end
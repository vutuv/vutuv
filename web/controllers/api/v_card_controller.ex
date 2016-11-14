defmodule Vutuv.Api.VCardController do
  use Vutuv.Web, :controller
  plug :headers

  def get(conn, _params) do
    vcard = conn.assigns[:user]
      |>Repo.preload([:emails, :addresses,
                      :phone_numbers])
    render(conn, "show.vcard", v_card: vcard)
    

    #v_cards = Repo.all(User)
    #  |>Repo.preload([:emails, :addresses,
    #                  :phone_numbers])
    #render(conn, "index.json", v_cards: v_cards)
  end

  defp headers(conn, _opts) do
    conn
    |> Plug.Conn.put_resp_header("Content-Type", "text/vcard")
  end
end
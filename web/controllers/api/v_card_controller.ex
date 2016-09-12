defmodule Vutuv.Api.VCardController do
  use Vutuv.Web, :controller
  plug :headers

  def get(conn, _params) do
    vcard = conn.assigns[:user]
      |>Repo.preload([:emails, :addresses,
                      :phone_numbers])
    render(conn, "show.json", v_card: vcard)
    

    #v_cards = Repo.all(User)
    #  |>Repo.preload([:emails, :addresses,
    #                  :phone_numbers])
    #render(conn, "index.json", v_cards: v_cards)
  end

  defp headers(conn, _opts) do
    file = conn.assigns[:user].active_slug<>".vcard"
    conn
    |>Plug.Conn.put_resp_header("Content-Disposition", "inline;filename=\""<>file<>"\"")
  end
end
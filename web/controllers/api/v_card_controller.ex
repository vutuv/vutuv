defmodule Vutuv.Api.VCardController do
  use Vutuv.Web, :controller

  plug :scrub_params, "v_card" when action in [:create, :update]

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
end
defmodule Vutuv.VCardController do
  use Vutuv.Web, :controller

  alias Vutuv.User

  plug :scrub_params, "v_card" when action in [:create, :update]

  def index(conn, params) do
    case params do
      %{"slug" => slug} ->
        case resolve_slug(slug) do
          {:ok, user_id} ->
            v_card = Repo.get!(User, user_id)
              |>Repo.preload([:emails, :addresses,
                              :phone_numbers])
            render(conn, "show.json", v_card: v_card)
          {:error} -> render(conn, "error.json", error: "Invalid Slug.")
        end
      _ ->
        v_cards = Repo.all(User)
          |>Repo.preload([:emails, :addresses,
                          :phone_numbers])
        render(conn, "index.json", v_cards: v_cards)
    end
  end

  def resolve_slug(slug) do
    case Repo.one(from s in Vutuv.Slug, where: s.value == ^slug) do
      nil  -> {:error}
      %{disabled: false, user_id: user_id} -> {:ok, user_id}
      _ -> {:error}
    end
  end
end
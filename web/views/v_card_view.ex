defmodule Vutuv.VCardView do
  use Vutuv.Web, :view

  def render("index.json", %{v_cards: v_cards}) do
    %{v_cards: render_many(v_cards, Vutuv.VCardView, "show.json")}
  end

  def render("show.json", %{v_card: v_card}) do
    ["v_card", render_one(v_card, Vutuv.VCardView, "v_card.json")]
  end

  def render("v_card.json", %{v_card: v_card}) do
    [
      ["version", %{}, "text","4.0"],
      ["n",       %{}, "text", [v_card.last_name, v_card.first_name, v_card.middlename, v_card.honorific_prefix, v_card.honorific_suffix]],
      ["fn",      %{}, "text", v_card.first_name<>" "<>v_card.last_name],
      ["org",     %{}, "text", ""],
      ["title",   %{}, "text", ""],
    ]
    ++
    for(t <- v_card.phone_numbers) do
      ["tel", %{type: [t.number_type, "voice"]}, "uri", t.value]
    end
    ++
    for(a <- v_card.addresses) do
      ["adr",
        %{label: inspect(a.line_1)<>"\n"<>inspect(a.line_2)<>"\n"<>inspect(a.line_3)<>"\n"<>inspect(a.line_4), type: "work", pref: ""},
        "text",
        [a.line_1, a.line_2, a.line_3, a.line_4, a.city, a.state, a.zip_code, a.country]
      ]
    end
    ++
    for(e <- v_card.emails) do
      ["email", %{}, "text", e.value]
    end
    ++
    [
      ["rev", %{}, "timestamp", "not yet implemented"]
    ]
  end

  def render("error.json", %{error: error}) do
    %{error: error}
  end
end

defmodule Vutuv.Api.VCardView do
  use Vutuv.Web, :view

  def render("show.vcard", %{v_card: v_card}) do
    render_one(v_card, Vutuv.Api.VCardView, "v_card")
  end

  def render("v_card", %{v_card: v_card}) do
    "BEGIN:VCARD\nVERSION:4.0"<>
    "\nN:"<>sanitize(v_card.last_name)<>";"<>sanitize(v_card.first_name)<>";"<>sanitize(v_card.middlename)<>";"<>sanitize(v_card.honorific_prefix)<>
    "\nFN:"<>sanitize(v_card.first_name)<>" "<>sanitize(v_card.last_name)<>
    "\nORG:"<>
    "\nTITLE:"<>
    "\nPHOTO:"<>
    "\n"<>
    Enum.reduce(v_card.phone_numbers,"",fn f, acc ->
      acc<>"TEL;TYPE="<>sanitize(f.number_type)<>":"<>sanitize(f.value)<>"\n"
    end)
    <>
    Enum.reduce(v_card.addresses,"",fn f, acc ->
      acc<>"ADR;TYPE=WORK:"<>sanitize(f.line_1)<>";"<>sanitize(f.line_2)<>";"<>sanitize(f.line_3)<>";"<>sanitize(f.line_4)<>";"<>
      sanitize(f.city)<>";"<>sanitize(f.state)<>";"<>sanitize(f.zip_code)<>";"<>sanitize(f.country)<>
      "\nLABEL;TYPE=WORK"<>sanitize(f.line_1)<>"\n"<>sanitize(f.line_2)<>"\n"<>sanitize(f.line_3)<>"\n"<>sanitize(f.line_4)<>"\n"<>
      sanitize(f.city)<>","<>sanitize(f.state)<>" "<>sanitize(f.zip_code)<>"\n"<>sanitize(f.country)<>"\n"
    end)
    <>
    vcard_emails(v_card)
    <>"REV:TIMESTAMP NOT YET IMPLEMENTED\nEND:VCARD"
  end

  defp vcard_emails(%{emails: %Ecto.Association.NotLoaded{}}), do: ""

  defp vcard_emails(%{emails: emails}) do
    Enum.reduce(emails,"", fn f, acc ->
      acc<>"EMAIL:"<>sanitize(f.value)<>"\n"
    end)
  end

  def render("error.json", %{error: error}) do
    %{error: error}
  end

  def sanitize(string), do: if(string, do: string, else: "")
end

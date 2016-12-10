defmodule Vutuv.Api.VCardView do
  use Vutuv.Web, :view
  import Vutuv.UserHelpers

  def render("show.vcf", %{v_card: v_card}) do
    render_one(v_card, Vutuv.Api.VCardView, "v_card.vcf")
  end

  def render("vcard.vcf", %{v_card: v_card}) do
    "BEGIN:VCARD\nVERSION:3.0"<>
    "\nN:"<>sanitize(v_card.last_name)<>";"<>sanitize(v_card.first_name)<>";"<>sanitize(v_card.middlename)<>";"<>sanitize(v_card.honorific_prefix)<>
    "\nFN:"<>sanitize(v_card.first_name)<>" "<>sanitize(v_card.last_name)<>
    "\nORG:#{current_organization(v_card)}"<>
    "\nTITLE:#{current_title(v_card)}"<>
    "\nPHOTO;"<>String.replace(Vutuv.Avatar.binary(v_card, :thumb), "data:image/jpeg;base64", "ENCODING=b;TYPE=JPEG:")<>
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
    <>
    vcard_twitter(v_card)
    <>"REV:#{vcard_timestamp}Z\nEND:VCARD"
  end

  def render("error.json", %{error: error}) do
    %{error: error}
  end

  defp sanitize(string), do: if(string, do: string, else: "")

  defp vcard_timestamp do
    DateTime.utc_now
    |> DateTime.to_string
    |> String.split(".")
    |> hd
    |> String.replace(~r/[-:\s]/,"")
  end

  defp vcard_emails(%{emails: %Ecto.Association.NotLoaded{}}), do: ""

  defp vcard_emails(%{emails: emails}) do
    Enum.reduce(emails,"", fn f, acc ->
      acc<>"EMAIL:"<>sanitize(f.value)<>"\n"
    end)
  end

  defp vcard_twitter(user) do
    case(user.social_media_accounts) do
      [] -> ""
      [account|_] ->"X-SOCIALPROFILE;type=twitter:http://twitter.com/#{account.value}\n"
    end
  end
end

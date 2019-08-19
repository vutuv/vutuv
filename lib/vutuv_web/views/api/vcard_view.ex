defmodule VutuvWeb.Api.VcardView do
  use VutuvWeb, :view

  @vcard_version 3.0

  def render("vcard.vcf", %{user: user}) do
    user |> generate_vcard() |> List.flatten() |> Enum.join("\n")
  end

  defp generate_vcard(user) do
    [
      "BEGIN:VCARD",
      "VERSION:#{@vcard_version}",
      "N:#{maybe_string(user.full_name)}",
      "FN:#{maybe_string(user.full_name)}",
      "ORG:",
      "TITLE:",
      # "PHOTO:#{String.replace(Vutuv.Avatar.binary(user, :thumb), "data:image/jpeg;base64", "ENCODING=b;TYPE=JPEG:")}",
      parse_email_addresses(user.email_addresses),
      parse_phone_numbers(user.phone_numbers),
      "REV:#{vcard_timestamp()}Z",
      "END:VCARD"
    ]
  end

  defp parse_email_addresses(nil), do: ""

  defp parse_email_addresses(email_addresses) do
    Enum.flat_map(email_addresses, fn email ->
      case email.is_public do
        true -> [maybe_string(email.value)]
        _ -> []
      end
    end)
  end

  defp parse_phone_numbers(nil), do: ""

  defp parse_phone_numbers(phone_numbers) do
    Enum.map(phone_numbers, fn number ->
      "TEL:TYPE=#{maybe_string(number.number_type)}:#{maybe_string(number.value)}"
    end)
  end

  defp maybe_string(nil), do: ""
  defp maybe_string(string), do: string

  defp vcard_timestamp do
    DateTime.utc_now()
    |> DateTime.to_string()
    |> String.split(".")
    |> hd
    |> String.replace(~r/[-:\s]/, "")
  end
end

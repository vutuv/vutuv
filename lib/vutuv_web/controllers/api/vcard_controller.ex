defmodule VutuvWeb.Api.VcardController do
  use VutuvWeb, :controller

  alias Vutuv.UserProfiles

  def vcard(conn, %{"user_slug" => user_slug}) do
    user =
      %{"slug" => user_slug}
      |> UserProfiles.get_user!()
      |> UserProfiles.user_with_assocs([:email_addresses, :phone_numbers])

    conn
    |> update_headers(user_slug)
    |> render("vcard.vcf", user: user)
  end

  defp update_headers(conn, user_slug) do
    filename = "#{String.replace(user_slug, ".", "_")}_vcard.vcf"

    conn
    |> put_resp_header("content-type", "text/vcard;charset=utf-8")
    |> put_resp_header("content-disposition", "attachment;filename = #{filename}")
  end
end

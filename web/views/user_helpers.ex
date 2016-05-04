defmodule Vutuv.UserHelpers do
  alias Vutuv.User

  def full_name(%User{first_name: first_name,
                      last_name: last_name,
                      honorific_prefix: honorific_prefix,
                      honorific_suffix: honorific_suffix}) do
    [honorific_prefix, first_name, last_name, honorific_suffix]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join(" ")
  end

  def gravatar_url(user) do
    case user.emails do
      [email | _tail] -> "http://www.gravatar.com/avatar/#{email.md5sum}"
      _               -> "some-default-avatar"
    end
  end
end

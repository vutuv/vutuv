defmodule Vutuv.MagicLinkHelpers do
  import Ecto.Query
  require Vutuv.Gettext
  alias Vutuv.MagicLink

  @magic_link_expire_time 3600  #in seconds

  #Generates a magic link for the user and stores it for 60 mintues
  def gen_magic_link(user, type, value \\ nil) do
    hash = gen_hash(user.id)
    pin = gen_pin
    current_time = Ecto.DateTime.from_erl :calendar.universal_time()
    case Vutuv.Repo.one(from m in MagicLink, where: m.user_id == ^user.id and m.magic_link_type == ^type) do
      nil -> Ecto.build_assoc(user, :magic_links)
      magic_link -> magic_link
    end
    |>MagicLink.changeset(%{
      magic_link: hash, magic_link_type: type, 
      value: value, magic_link_created_at: current_time,
      pin: pin, pin_created_at: current_time,
      pin_login_attempts: 0})
    |>Vutuv.Repo.insert_or_update! #With a bang because this should never fail
    {hash, pin}
  end

  #Generates a hash from "<current_time><random_integer><user_id>"
  defp gen_hash(user_id) do
    seconds_string = 
      :calendar.universal_time
      |> :calendar.datetime_to_gregorian_seconds
      |> Integer.to_string
    rand_string = 
      :rand.uniform
      |> Float.to_string
    id_string =
      user_id
      |> Integer.to_string
    :crypto.hash(:sha256, "#{seconds_string}#{rand_string}#{id_string}")
    |> Base.encode16
    |> String.downcase
  end

  defp gen_pin do
    :rand.uniform(1000000)
    |> Integer.to_string
    |> String.rjust(6,?0)
  end

  defp expire_magic_link(magic_link) do
    changeset = MagicLink.changeset(magic_link, %{magic_link_created_at: nil})
    Vutuv.Repo.update!(changeset)
  end

  defp link_expired?(%{magic_link_created_at: nil}), do: true

  defp link_expired?(%{magic_link_created_at: date_time}) do
    time_created = 
      date_time
      |> Ecto.DateTime.to_erl
      |> :calendar.datetime_to_gregorian_seconds
    now = 
      :calendar.universal_time
      |> :calendar.datetime_to_gregorian_seconds
    now - time_created > @magic_link_expire_time
  end

  defp link_expired?(_), do: true

  #returns {:ok, user} if match is found to link, returns {:error, reason} otherwise
  def check_magic_link(link, type) do
    case Vutuv.Repo.one(from m in MagicLink, where: m.magic_link==^link and m.magic_link_type == ^type) do
      nil->  {:error, Vutuv.Gettext.gettext("An error occured")}
      magic_link->
        case link_expired?(magic_link) do
          true-> 
            expire_magic_link(magic_link)
            {:error, Vutuv.Gettext.gettext("Link expired")}
          false ->
            expire_magic_link(magic_link)
            response magic_link
        end
    end
  end

  defp response(%MagicLink{value: nil, user_id: user_id}) do
    {:ok, Vutuv.Repo.get(Vutuv.User, user_id)}
  end

  defp response(%MagicLink{value: value, user_id: user_id}) do
    {:ok, value, Vutuv.Repo.get(Vutuv.User, user_id)}
  end
end
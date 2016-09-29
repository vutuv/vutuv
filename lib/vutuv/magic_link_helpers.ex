defmodule Vutuv.MagicLinkHelpers do
  import Ecto.Query

  alias Vutuv.MagicLink

  #Generates a magic link for the user and stores it for 60 mintues
  def gen_magic_link(user, type, value \\ nil) do
    link = Base.encode32(:crypto.hash(:sha256,Integer.to_string(user.id)<>Float.to_string(:rand.uniform())<>Integer.to_string(:calendar.datetime_to_gregorian_seconds(:calendar.universal_time()))))
    case Vutuv.Repo.one(from m in MagicLink, where: m.user_id == ^user.id and m.magic_link_type == ^type) do
      nil -> Ecto.build_assoc(user, :magic_links)
      magic_link -> magic_link
    end
    |>MagicLink.changeset(%{magic_link: link, magic_link_type: type, value: value, magic_link_created_at: Ecto.DateTime.from_erl(:calendar.universal_time())})
    |>Vutuv.Repo.insert_or_update! #With a bang because this should never fail
    link
  end

  defp expire_magic_link(magic_link) do
    changeset = MagicLink.changeset(magic_link, %{magic_link_created_at: nil})
    Vutuv.Repo.update!(changeset)
  end

  defp link_expired?(magic_link) do
    case magic_link.magic_link_created_at do
      nil -> true
      t->
        time = Ecto.DateTime.to_erl(t)
        :calendar.datetime_to_gregorian_seconds(:calendar.universal_time)-:calendar.datetime_to_gregorian_seconds(time)>3600
    end
  end

  #returns {:ok, user} if match is found to link, returns {:error, reason} otherwise
  def check_magic_link(link, type) do
    case Vutuv.Repo.one(from m in MagicLink, where: m.magic_link==^link and m.magic_link_type == ^type) do
      nil->  {:error, "No Match Found"}
      magic_link->
        case link_expired?(magic_link) do
          true-> 
            expire_magic_link(magic_link)
            {:error, "Link expired"}
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
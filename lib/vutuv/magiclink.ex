defmodule Vutuv.MagicLink do
	import Ecto.Query

	#Generates a magic link for the user and stores it for __ mintues
	def gen_magic_link(user) do
		link = Base.encode32(:crypto.hash(:sha256,Integer.to_string(user.id)<>Float.to_string(:rand.uniform())<>Integer.to_string(:calendar.datetime_to_gregorian_seconds(:calendar.universal_time()))))
		changeset = Ecto.Changeset.cast(user, %{magic_link: link, magic_link_created_at: Ecto.DateTime.from_erl(:calendar.universal_time())}, [], [:magic_link, :magic_link_created_at])
		Vutuv.Repo.update!(changeset) #With a bang because this should never fail
		link
	end

	#Returns User ID (user) if a match is found, otherwise returns nil.
	def check_magic_link(link) do
		Vutuv.Repo.one(from u in Vutuv.User, where: u.magic_link==^link)
	end

	def expire_magic_link(user) do
		changeset = Ecto.Changeset.cast(user, %{magic_link_created_at: nil}, [], [:magic_link_created_at])
		Vutuv.Repo.update!(changeset)
	end

	def link_expired?(user) do
		case user.magic_link_created_at do
			nil -> true
			t->
				time = Ecto.DateTime.to_erl(t)
				:calendar.datetime_to_gregorian_seconds(:calendar.universal_time)-:calendar.datetime_to_gregorian_seconds(time)>3600
		end
	end

	#returns {:ok, user} if match is found to link, returns {:error, reason} otherwise
	def login_magic_link(link) do
		case check_magic_link(link) do
			nil->	{:error, "No Match Found"}
			user-> 
				case link_expired?(user) do
					true-> 
						expire_magic_link(user)
						{:error, "Link expired"}
				false ->
					expire_magic_link(user)
					{:ok, user}
				end
		end
	end
end
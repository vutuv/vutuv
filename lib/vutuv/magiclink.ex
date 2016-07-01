defmodule Vutuv.MagicLink do
	use GenServer

	def start_link do
		GenServer.start_link(__MODULE__,%{},[name: Vutuv.MagicLink])
	end

	#Generates a magic link for the user and stores it for __ mintues
	def gen_magic_link(user) do
		:gen_server.call(Vutuv.MagicLink, {:generate, user})
	end

	#Returns User ID (user) if a match is found, otherwise returns nil.
	def check_magic_link(link) do
		:gen_server.call(Vutuv.MagicLink, {:check, link})
	end

	#returns {:ok, user} if match is found to link, returns {:error, reason} otherwise
	def login_magic_link(link) do
		case check_magic_link(link) do
			nil->	{:error, "No Match Found"}
			user-> {:ok, user}
		end
	end

	#############
	# Callbacks #
	#############

	def handle_call({:generate, user}, _from, state) do
		link = Base.encode32(:crypto.hash(:sha256,Integer.to_string(user.id)<>Float.to_string(:rand.uniform())<>Integer.to_string(:calendar.datetime_to_gregorian_seconds(:calendar.universal_time()))))
		
		{:reply,link, Map.put_new(state, link, user)}
	end

	def handle_call({:check, link}, _from, state) do
		{:reply, Map.get(state,link),state}
	end

end
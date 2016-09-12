defmodule Vutuv.Plug.PutAPIHeaders do

  def init(opts) do 
  	opts
  end

  def call(conn, _default) do
  	#put standard api headers here
  	conn
  end
end
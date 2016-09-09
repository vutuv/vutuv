defmodule Vutuv.Plug.PutAPIHeaders do

  def init(opts) do 
  	opts
  end

  def call(conn, _default) do
    Plug.Conn.put_resp_header(conn,"Content-Type", "application/vnd.api+json")
  end
end
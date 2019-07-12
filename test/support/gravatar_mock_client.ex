defmodule Vutuv.Downloads.GravatarMockClient do
  @moduledoc false

  def run({_email, user_id}) do
    {:ok,
     %{
       user_id: user_id,
       data: %Plug.Upload{
         content_type: "image/png",
         filename: "elixir_logo.png",
         path: "test/fixtures/elixir_logo.png"
       }
     }}
  end
end

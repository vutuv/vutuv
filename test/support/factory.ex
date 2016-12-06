defmodule Vutuv.Factory do
  use ExMachina.Ecto, repo: Vutuv.Repo

  def user_factory do
    %Vutuv.User{
      first_name: "first_name"
    }
  end

  def url_factory do
    %Vutuv.Url{
      value: "http://example.org/",
      description: "Test Url"
    }
  end
end

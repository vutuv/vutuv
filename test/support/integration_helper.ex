defmodule VutuvWeb.IntegrationHelper do
  @moduledoc """
  A helper for use with integration tests.
  """

  @base_url "http://localhost:4002/api/v1"

  @doc """
  Logs in the user.
  """
  def login_user(email, password \\ "reallyHard2gue$$") do
    params = %{:email => email, :password => password}
    Tesla.post!(simple_client(), "/sessions", %{session: params}).body
  end

  @doc """
  Creates an unauthenticated client, for use with Tesla.
  """
  def simple_client do
    Tesla.client([{Tesla.Middleware.BaseUrl, @base_url}, Tesla.Middleware.JSON])
  end

  @doc """
  Creates an authenticated client, for use with Tesla.
  """
  def authenticated_client(token) do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, @base_url},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"authorization", token}]}
    ])
  end
end

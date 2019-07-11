defmodule Vutuv.Downloads.GravatarClient do
  @moduledoc """
  Module to handle the downloading of gravatar images.
  """

  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://www.gravatar.com/avatar/"

  @img_size 150

  @doc """
  Downloads the gravatar image and stores it.
  """
  def run({email, user_id}) do
    hash =
      email
      |> String.trim()
      |> String.downcase()
      |> :erlang.md5()
      |> Base.encode16(case: :lower)

    "#{hash}?s=#{@img_size}&d=404"
    |> get()
    |> handle_response({email, user_id})
  end

  defp handle_response({:ok, %Tesla.Env{status: 200, headers: headers, body: body}}, {_, user_id}) do
    {_, content_type} = Enum.find(headers, fn {k, _v} -> k == "content-type" end)
    storage_dir = "#{Application.get_env(:vutuv, :storage_dir)}#{user_id}"

    case File.mkdir_p(storage_dir) do
      :ok ->
        file_extension = String.replace(content_type, "image/", "")
        filename = "original.#{file_extension}"
        path = Path.join(storage_dir, filename)
        File.write(path, body)

        {:ok,
         %{
           user_id: user_id,
           data: %Plug.Upload{content_type: content_type, filename: filename, path: path}
         }}

      _ ->
        {:error, "Unspecified error"}
    end
  end

  defp handle_response({:ok, %Tesla.Env{body: body}}, _) do
    {:error, body}
  end

  defp handle_response(_, _) do
    {:error, "Unspecified error"}
  end
end

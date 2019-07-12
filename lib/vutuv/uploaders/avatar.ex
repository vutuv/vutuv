defmodule Vutuv.Avatar do
  use Arc.Definition
  use Arc.Ecto.Definition

  @extension_whitelist ~w(.jpg .jpeg .png)
  @versions [:original, :thumb, :medium, :large]

  def transform(size, _) when size in [:thumb, :medium, :large] do
    case :os.type() do
      {:win32, _} -> win_transform(size)
      _ -> transform(size)
    end
  end

  defp transform(:thumb), do: {:convert, convert_cmd("50x50")}
  defp transform(:medium), do: {:convert, convert_cmd("130x130")}
  defp transform(:large), do: {:convert, convert_cmd("512x512")}

  defp win_transform(:thumb) do
    {:magick, fn input, output -> "convert #{input} #{convert_cmd("50x50")} #{output}" end}
  end

  defp win_transform(:medium) do
    {:magick, fn input, output -> "convert #{input} #{convert_cmd("130x130")} #{output}" end}
  end

  defp win_transform(:large) do
    {:magick, fn input, output -> "convert #{input} #{convert_cmd("512x512")} #{output}" end}
  end

  defp convert_cmd(size) do
    "-strip -gravity center -resize #{size}^ -extent #{size}"
  end

  def storage_dir(_version, {_file, scope}) do
    "#{Application.get_env(:vutuv, :storage_dir)}#{scope.id}"
  end

  def filename(version, _args), do: version

  def default_url(version, _) do
    "#{Application.get_env(:vutuv, :default_dir)}default_#{version}.png"
  end

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(@extension_whitelist, file_extension)
  end
end

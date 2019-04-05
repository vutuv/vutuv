defmodule Vutuv.Avatar do
  use Arc.Definition
  use Arc.Ecto.Definition

  @versions [:original, :thumb]
  @extension_whitelist ~w(.jpg .jpeg .png)

  def transform(:thumb, _) do
    case :os.type() do
      {:win32, _} ->
        {:magick,
         fn input, output ->
           "convert #{input} -strip -gravity center -resize 50x50^ -extent 50x50 #{output}"
         end}

      _ ->
        {:convert, "-strip -gravity center -resize 50x50^ -extent 50x50"}
    end
  end

  def storage_dir(_version, {_file, scope}) do
    "#{Application.get_env(:vutuv, :storage_dir)}#{scope.id}"
  end

  def filename(version, _) do
    version
  end

  def default_url(version, _) do
    "#{Application.get_env(:vutuv, :default_dir)}default_#{version}.png"
  end

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(@extension_whitelist, file_extension)
  end
end

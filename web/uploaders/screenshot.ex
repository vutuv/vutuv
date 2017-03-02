defmodule Vutuv.Screenshot do
  use Arc.Definition

  # Include ecto support (requires package arc_ecto installed):
  use Arc.Ecto.Definition

  # To add a thumbnail version:
  @versions [:original, :thumb]

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.jpg .png) |> Enum.member?(Path.extname(file.file_name))
  end

  # Define a thumbnail transformation:
  def transform(:thumb, _) do
    {:convert, "-strip -resize 150^x112 -gravity north -extent 150x112 -format png", :png}
  end

  # Use local storage
  def __storage, do: Arc.Storage.Local

  def storage_dir(_version, {_file, scope}) do
    "web/static/assets/images/screenshots/#{scope.id}"
  end

  # Override the persisted filenames:
  def filename(version, _) do
    version
  end

  def default_url(:thumb) do
    "https://placehold.it/200x150"
  end
end

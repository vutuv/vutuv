defmodule Vutuv.Avatar do
  use Arc.Definition

  # Include ecto support (requires package arc_ecto installed):
  use Arc.Ecto.Definition

  @versions [:original, :thumb, :medium, :large]
  @extension_whitelist ~w(.jpg .jpeg .png)
  @default_avatar ~s"data:image/svg+xml,%3Csvg%20width%3D%27200%27%20height%3D%27200%27%20xmlns%3D%27http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%27%20xmlns%3Axlink%3D%27http%3A%2F%2Fwww.w3.org%2F1999%2Fxlink%27%3E%3Cdefs%3E%3Ccircle%20id%3D%27a%27%20cx%3D%27100%27%20cy%3D%27100%27%20r%3D%27100%27%2F%3E%3C%2Fdefs%3E%3Cg%20fill%3D%27none%27%20fill-rule%3D%27evenodd%27%3E%3Cmask%20id%3D%27b%27%20fill%3D%27%23fff%27%3E%3Cuse%20xlink%3Ahref%3D%27%23a%27%2F%3E%3C%2Fmask%3E%3Cuse%20fill%3D%27%23EEE%27%20xlink%3Ahref%3D%27%23a%27%2F%3E%3Cpath%20d%3D%27M88.96%20154c-6.357-12.418-12.81-26.952-19.355-43.597C63.06%2093.76%2056.858%2075.626%2051%2056h29.437c1.247%204.844%202.714%2010.093%204.4%2015.743%201.682%205.653%203.428%2011.365%205.24%2017.143%201.808%205.772%203.615%2011.394%205.425%2016.86%201.81%205.466%203.59%2010.434%205.336%2014.904%201.618-4.47%203.365-9.438%205.234-14.905%201.87-5.465%203.71-11.087%205.518-16.86%201.807-5.777%203.554-11.49%205.237-17.142%201.682-5.65%203.15-10.9%204.395-15.743h28.71c-5.857%2019.626-12.055%2037.76-18.594%2054.403C124.8%20127.048%20118.352%20141.583%20112%20154H88.96z%27%20fill%3D%27%231A1918%27%20opacity%3D%27.1%27%20mask%3D%27url(%23b)%27%2F%3E%3C%2Fg%3E%3C%2Fsvg%3E"

  def transform(:thumb, _) do
    {:convert, "-strip -thumbnail 50x50^ -gravity center -extent 50x50"}
  end

  def transform(:medium, _) do
    {:convert, "-strip -gravity center -resize 130x130^ -extent 130x130"}
  end

  # def transform(:circle, {file, scope}) do
  #   {:convert,
  #     fn path, new_path ->
  #       [
  #         "-size", "130x130",
  #         "xc:none",
  #         "-fill", "#{path}",
  #         "-draw", "circle 65,65 65,1",
  #         new_path
  #       ]
  #     end}
  # end

  def transform(:large, _) do
    {:convert, "-strip -gravity center -resize 512x512^ -extent 512x512"}
  end

  # Use local storage
  #
  def __storage, do: Arc.Storage.Local

  def filename(version,  {_file, scope}), do: "#{scope}_#{version}"

  def storage_dir(_version, {_file, scope}) do
    "web/static/assets/images/avatars/#{scope.id}"
  end

  def user_url(user, version) do
    Vutuv.Avatar.url({user.avatar, user}, version, signed: true)
    |>String.replace("web/static/assets", "")
  end

  def webserver_static_url(user, version) do
    timestamp = user.updated_at
    |> Ecto.DateTime.to_string
    |> String.replace(~r/[^0-9]/,"")

    nginx_path = user.active_slug
    |> String.replace(".","/")

    image_file_name = Vutuv.Avatar.url({user.avatar, user}, version, signed: true)
    |> String.replace(~r/web\/static\/assets\/images\/avatars\/[0-9]+\//,"")

    "/avatars/#{nginx_path}/#{timestamp}/#{image_file_name}"
  end

  def binary(user, version) do
    Vutuv.Avatar.url({user.avatar, user}, version, signed: true)
    |> validate_file
    |> read_file
  end

  defp validate_file(nil), do: nil

  defp validate_file(path) do
    if File.exists?(path), do: path, else: nil
  end

  defp read_file(nil), do: @default_avatar

  defp read_file(path) do
    path
    |> File.read!
    |> Base.encode64
    |> add_mimetype(path)
  end

  defp add_mimetype(binary, path) do
    type = hd(tl(String.split(path,".")))
    "data:image/#{type};base64,#{binary}"
  end

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(@extension_whitelist, file_extension)
  end

  # To add a thumbnail version:
  # @versions [:original, :thumb]

  # Whitelist file extensions:
  # def validate({file, _}) do
  #   ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  # end

  # Define a thumbnail transformation:
  # def transform(:thumb, _) do
  #   {:convert, "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -format png", :png}
  # end

  # Override the persisted filenames:
  # def filename(version, _) do
  #   version
  # end

  # Override the storage directory:
  # def storage_dir(version, {file, scope}) do
  #   "uploads/user/avatars/#{scope.id}"
  # end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: Plug.MIME.path(file.file_name)]
  # end
end

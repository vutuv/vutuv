defmodule Mix.Tasks.Avatar.Optimize do
  use Mix.Task
  import Mix.Ecto
  import Ecto.Query
  alias Vutuv.Repo
  alias Vutuv.User

  @shortdoc "Optimize the file size of JPEG avatars."

  def run(_args) do
    ensure_started(Repo, [])
    users = Repo.all(from u in User, where: not is_nil(u.avatar))

    for(user <- users) do
      source_path = "/srv/vutuv/avatars/#{user.id}"

      size_name = "medium"
      width = 130
      height = 130
      for file_extension <- ["jpeg", "jpg"] do
        original_file = List.first(Path.wildcard("#{source_path}/*_original.#{file_extension}"))
        target_file = List.first(Path.wildcard("#{source_path}/*_#{size_name}.#{file_extension}"))

        if original_file do
          temp_dir = "#{source_path}/tmp"
          source_file = "#{temp_dir}/original.#{file_extension}"
          tmp_file = "#{temp_dir}/#{size_name}-#{Integer.to_string(width)}x#{Integer.to_string(height)}.#{file_extension}"
          q75_file = List.first(String.split(tmp_file, ".#{file_extension}")) <> "-q75.#{file_extension}"
          q95_file = List.first(String.split(tmp_file, ".#{file_extension}")) <> "-q95.#{file_extension}"
          optimized_file = List.first(String.split(tmp_file, ".#{file_extension}")) <> "-optimized.#{file_extension}"

          File.mkdir(temp_dir)
          File.cp(original_file, source_file)

          # Convert medium size 130x130
          #
          System.cmd "convert", [source_file, "-colorspace", "YUV", "-resize", "#{Integer.to_string(width)}x#{Integer.to_string(height)}", "-strip", tmp_file]

          # encode with guetzli
          #
          System.cmd "guetzli", ["-quality", "75", tmp_file, q75_file]

          # cut a circle of the good version and
          # put it in the q75_file
          #
          System.cmd "convert", [tmp_file, q75_file, "-fx", "hypot(#{Integer.to_string(trunc(width / 2))}-i, #{Integer.to_string(trunc(height / 2))}-j) < #{Integer.to_string(trunc(width / 2))} ? u : v", optimized_file]

          # Copy to the target location
          #
          if target_file do
            {:ok, old_file_stat} = File.stat target_file
            {:ok, new_file_stat} = File.stat optimized_file
            if new_file_stat.size < old_file_stat.size do
              File.rename(optimized_file, target_file)

              # Basic output
              #
              IO.puts source_path
              IO.puts Float.round((old_file_stat.size - new_file_stat.size) / 1024,1)
              IO.puts "#{100 - Float.round((new_file_stat.size / old_file_stat.size) * 100)} %"
              IO.puts ""
            end
          end

          # Remove tmp dir
          #
          File.rm_rf(temp_dir)
        end
      end
    end
  end
end

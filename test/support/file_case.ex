defmodule Vutuv.FileCase do
  def remove_test_files do
    File.rm_rf("#{Application.get_env(:vutuv, :storage_dir)}")
  end
end

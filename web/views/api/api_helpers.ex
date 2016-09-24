defmodule Vutuv.Api.ApiHelpers do

  def to_attributes(struct, attributes) do
    struct
    |> Map.from_struct
    |> Map.take(attributes)
    |> Enum.filter(fn {_, v} -> v != nil end) #removes nil fields
    |> Enum.into(%{})
  end
end
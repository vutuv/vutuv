defmodule Vutuv.EmailView do
  use Vutuv.Web, :view
  import Vutuv.UserHelpers

  def format_date(date, "de") do
    case date.year do
      1900 ->
        "#{date.day}.#{date.month}."
      _ ->
        "#{date.day}.#{date.month}.#{date.year}"
    end
  end

  def format_date(date, _) do
    case date.year do
      1900 ->
        "#{date.month}-#{date.day}"
      _ ->
        "#{date.month}-#{date.day}-#{date.year}"
    end
  end
end

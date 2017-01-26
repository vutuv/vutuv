defmodule Vutuv.EmailView do
  use Vutuv.Web, :view
  import Vutuv.UserHelpers

  def format_date(date, "de") do
    "#{date.day}.#{date.month}.#{date.year}"
  end

  def format_date(date, _) do
    "#{date.month}-#{date.day}-#{date.year}"
  end
end

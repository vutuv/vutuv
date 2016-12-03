defmodule Vutuv.WorkExperienceView do
  use Vutuv.Web, :view
  import Vutuv.UserHelpers

  def format_duration(start_month, start_year, end_month, end_year) do
    case {start_month, start_year, end_month, end_year} do
      {nil, nil, nil, nil} ->
        "present"
      {nil, nil, end_month, end_year} ->
        display_date(end_month, end_year)
      _ ->
        [display_date(start_month, start_year),' - ',display_date(end_month, end_year)]
    end
  end

  def display_date(month, year) do
    case {month, year} do
      {nil, nil} ->
        "present"
      {nil, year} ->
        "#{year}"
      {month, year} ->
        "#{month}/#{year}"
      _ ->
        ""
    end
  end

end

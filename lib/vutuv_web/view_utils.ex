defmodule VutuvWeb.ViewUtils do
  @moduledoc """
  Functions used by views.
  """

  import VutuvWeb.Gettext

  def beautify_date(%DateTime{year: year, month: month, day: day}) do
    "#{day} #{to_word(month)}, #{year}"
  end

  defp to_word(month) do
    Enum.at(
      [
        gettext("January"),
        gettext("February"),
        gettext("March"),
        gettext("April"),
        gettext("May"),
        gettext("June"),
        gettext("July"),
        gettext("August"),
        gettext("September"),
        gettext("October"),
        gettext("November"),
        gettext("December")
      ],
      month - 1
    )
  end
end

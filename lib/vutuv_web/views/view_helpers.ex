defmodule VutuvWeb.ViewHelpers do
  @moduledoc """
  Miscellaneous helper functions used by views.
  """

  import VutuvWeb.Gettext

  @doc """
  Arranges items in a comma-separated list.
  """
  def stringify_list(items) do
    Enum.map_join(items, ", ", fn
      %{name: name} -> name
      %{full_name: full_name} -> full_name
    end)
  end

  @doc """
  Formats the date.
  """
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

  def sort_user_tags(user_tags, limit) do
    user_tags
    |> Enum.sort(&(Enum.count(&1.user_tag_endorsements) <= Enum.count(&2.user_tag_endorsements)))
    |> Enum.take(limit)
  end
end

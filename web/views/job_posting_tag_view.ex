defmodule Vutuv.JobPostingTagView do
  use Vutuv.Web, :view
  import Vutuv.UserHelpers

  defp resolve_priority(2), do: gettext("Important")
  defp resolve_priority(1), do: gettext("Optional")
  defp resolve_priority(0), do: gettext("Other")
end

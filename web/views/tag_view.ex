defmodule Vutuv.TagView do
  use Vutuv.Web, :view
  import Vutuv.UserHelpers

  defp update_assigns(assigns) do
  	assigns
  	|> Map.put(:related_users, Vutuv.Tag.related_users(assigns[:tag], assigns[:current_user]))
  	|> Map.put(:reccomended_users, Vutuv.Tag.reccomended_users(assigns[:tag]))
  	|> Map.put(:work_string_length, 45)
  end
end

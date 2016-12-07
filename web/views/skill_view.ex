defmodule Vutuv.SkillView do
  use Vutuv.Web, :view
  import Vutuv.UserHelpers

  defp update_assigns(assigns) do
  	assigns
  	|> Map.put(:related_users, Vutuv.Skill.related_users(assigns[:skill], assigns[:current_user]))
  	|> Map.put(:reccomended_users, Vutuv.Skill.reccomended_users(assigns[:skill]))
  end
end

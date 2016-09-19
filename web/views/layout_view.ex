defmodule Vutuv.LayoutView do
  use Vutuv.Web, :view
  import Vutuv.UserHelpers

  def is_current_user_page?(conn) do
    if(conn.assigns[:user]!=nil)do
      conn.assigns[:user].id==conn.assigns[:current_user].id and conn.assigns[:user_show]
    else
      false
    end
  end

end

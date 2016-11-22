defmodule Vutuv.ErrorView do
  use Vutuv.Web, :view

  def render("404.html", _assigns) do
    "</header> <h1 style=\"text-align:center;\">#{Vutuv.Gettext.gettext("Page not found")}</h1>"
    |> Phoenix.HTML.raw
  end

  def render("403.html", _assigns) do
    "</header> <h1 style=\"text-align:center;\">#{Vutuv.Gettext.gettext("You are not allowed to view this page.")}</h1>"
    |> Phoenix.HTML.raw
  end

  def render("500.html", _assigns) do
    "</header> <h1 style=\"text-align:center;\">#{Vutuv.Gettext.gettext("Pardon us! Something went wrong. If you think this is a bug, please %{link_open}submit a bug report.", link_open: "<a href = \"https://github.com/vutuv/vutuv/issues/new\">")}</a></h1>"
    |> Phoenix.HTML.raw
  end

  def render("error.json", _assigns) do
    %{errors: "not found"}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, _assigns) do
    "</header> <h1 style=\"text-align:center;\">#{Vutuv.Gettext.gettext("Pardon us! Something went wrong. If you think this is a bug, please %{link_open}submit a bug report.", link_open: "<a href = \"https://github.com/vutuv/vutuv/issues/new\">")}</a></h1>"
    |> Phoenix.HTML.raw
  end
end

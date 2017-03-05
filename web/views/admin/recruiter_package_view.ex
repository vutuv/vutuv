defmodule Vutuv.Admin.RecruiterPackageView do
  use Vutuv.Web, :view
  import Vutuv.UserHelpers
  import Number.Currency

  defp get_currency_symbol("dollar"), do: "$"
  defp get_currency_symbol("euro"), do: "€"
  defp get_currency_symbol(_), do: nil
end

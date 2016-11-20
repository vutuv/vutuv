defmodule Vutuv.Plug.Locale do  
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    Plug.Conn.get_req_header(conn,"accept-language") #Get locales from header
    |> process_header #Split header to a list of supported locales
    |> get_supported_locale #Cross reference list with supported locales and return supported locale, otherwise return most preferred locale
    |> assign_locale(conn) #Assign locale to conn assigns, and pass to gettext. Return conn struct.
  end


  defp process_header([]), do: []

  defp process_header(header) do #Splits header on commas.
    header
    |> hd
    |> String.split(",")
  end


  defp get_supported_locale([]), do: nil

  defp get_supported_locale(locales) do #Reduces list of locales to either a supported locale or a {nil, false} tuple
    Enum.reduce([{nil, false}|locales], fn f, acc ->
      case acc do
        {_, false} ->
          locale = String.split(f,";")
          |> hd
          |> String.split("-")
          |> hd
          if locale_supported?(locale), do: {locale, true}, else: {nil, false}
        {_, true} -> acc
      end
    end)
      |> process_possible_locale(locales) #Check to see if supported locale was found
  end


  defp process_possible_locale({locale, true}, _), do: locale #If supported locale found, return it

  defp process_possible_locale(_, locales), do: get_first_locale(locales) #Else return the user's most preferred locale


  defp assign_locale(nil, conn), do: assign(conn, :locale, "en")

  defp assign_locale(locale, conn) do #Give locale data to all modules that require it
    Gettext.put_locale(Vutuv.Gettext, locale)
    assign(conn, :locale, locale)
  end

  defp get_first_locale([]), do: nil

  defp get_first_locale(locales) do #Gets the first locale provided
    locales
      |> hd
      |> String.split("-")
      |> hd
  end

  def locale_supported?(nil), do: false

  def locale_supported?(locale) do #Checks locale provided against app config for supported locales
    {:ok, config} = Application.fetch_env(:vutuv, Vutuv.Endpoint)
    supported_locales = config[:locales]
    Enum.any?(supported_locales,fn f -> String.contains?(locale,f) end)
  end
end
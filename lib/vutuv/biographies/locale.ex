defmodule Vutuv.Biographies.Locale do
  @moduledoc """
  Module to help find a user's preferred locale.
  """

  defstruct locale: "en", quality: 1.0

  @supported ["en", "en_US", "en_AU", "en_CA", "en_GB", "de", "de_DE", "de_CH"]
  @supported_map %{
    "en" => "en",
    "en-us" => "en_US",
    "en-au" => "en_AU",
    "en-ca" => "en_CA",
    "en-gb" => "en_GB",
    "de" => "de",
    "de-de" => "de_DE",
    "de-ch" => "de_CH"
  }

  @doc """
  Parses an accept-language header entry and creates structs.
  """
  def parse_al([]), do: hd(@supported)

  def parse_al([pattern]) do
    pattern
    |> String.split(",")
    |> Enum.map(&create_struct(String.split(&1, ";")))
    |> Enum.sort(&(&1.quality >= &2.quality))
    |> find_default()
  end

  defp create_struct([locale]) do
    %__MODULE__{locale: @supported_map[locale]}
  end

  defp create_struct([locale, "q=" <> quality]) do
    %__MODULE__{locale: @supported_map[locale], quality: String.to_float(quality)}
  end

  defp find_default([]), do: hd(@supported)

  defp find_default([%__MODULE__{locale: locale} | rest]) do
    if locale in @supported do
      locale
    else
      find_default(rest)
    end
  end
end

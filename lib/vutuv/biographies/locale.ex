defmodule Vutuv.Biographies.Locale do
  @moduledoc """
  Module to help find a user's preferred locale.
  """

  defstruct locale: "en", quality: 1.0

  @doc """
  Returns a map of supported locales.
  """
  def supported do
    %{
      "en" => "en",
      "en-us" => "en_US",
      "en-au" => "en_AU",
      "en-ca" => "en_CA",
      "en-gb" => "en_GB",
      "de" => "de",
      "de-de" => "de_DE",
      "de-ch" => "de_CH"
    }
  end

  @doc """
  Returns a supported locale.
  """
  def supported(locale) do
    if locale in Map.values(supported()), do: locale, else: Map.get(supported(), locale)
  end

  @doc """
  Parses an accept-language header entry and creates structs.
  """
  def parse_al([]), do: supported() |> Map.values() |> hd

  def parse_al([pattern]) do
    pattern
    |> String.split(",")
    |> Enum.map(&create_struct(String.split(&1, ";")))
    |> Enum.sort(&(&1.quality >= &2.quality))
    |> find_default()
  end

  defp create_struct([locale]) do
    %__MODULE__{locale: supported(locale)}
  end

  defp create_struct([locale, "q=" <> quality]) do
    %__MODULE__{locale: supported(locale), quality: String.to_float(quality)}
  end

  defp find_default([]), do: supported() |> Map.values() |> hd

  defp find_default([%__MODULE__{locale: locale} | rest]) do
    if locale in Map.values(supported()) do
      locale
    else
      find_default(rest)
    end
  end
end

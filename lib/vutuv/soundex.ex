defmodule Vutuv.Soundex do

  @doc """
  Soundex is an implementation of the SoundEX algorithm, designed to encode names of into a phonetic code representing
  the pronunciation of the name. For more information on the rules of the algorithm, visit the following wikipedia page: https://en.wikipedia.org/wiki/Soundex
  """

  replaces = #List of replacements for function generation
  [
    {?b, '1'}, {?f, '1'}, {?p, '1'}, {?v, '1'},
    {?c, '2'}, {?g, '2'}, {?j, '2'}, {?k, '2'}, {?q, '2'}, {?s, '2'}, {?x, '2'}, {?z, '2'},
    {?d, '3'}, {?t, '3'},
    {?l, '4'},
    {?m, '5'}, {?n, '5'},
    {?r, '6'}
  ]

  breaking_drops = #List of breaking drops for function generation
  [
    ?a, ?e, ?i, ?o, ?u, ?y
  ]

  drops = #List of non-breaking drops for function generation
  [
    ?h, ?w
  ]


  def to_soundex(""), do: ""

  def to_soundex(nil), do: nil

  def to_soundex(string) do
    String.downcase(string) #Downcase to prevent unwanted behavior
    |> normalize #Normalizes special characters
    |> to_char_list #Converts the string into a char list
    |> encode #Converts the string to representative coded numbers in a char list
    |> to_string #Converts the encoded char list back to a string
    |> String.capitalize #Capitalizes the first letter
    |> String.ljust(4, ?0) #Appends zeroes to the end of the string until it's length is 4
    |> String.split_at(4) 
    |> elem(0) #Trims the string if the length is > 4
  end

  defp encode(''), do: ''

  defp encode([head|tail]) do
    new_tail = 
      tail
      |> Enum.filter(&first_drop/1)
      |> encode_list('', head)
      |> Enum.dedup #Removes consecutive duplicates
      |> tl
      |> Enum.filter(&second_drop/1)
    [head|new_tail]
  end

  defp encode_list(tail, '', head), do: encode_list [head|tail], ''

  defp encode_list('', encoded), do: encoded

  defp encode_list([head|tail], encoded) do #Recurses the char list and applies the apropriate replacements until it has replaced each letter
    encode_list tail, encoded ++ [replace(head)]
  end

  for char <- drops do #Generates non-breaking drops
    defp first_drop(unquote(char)), do: false
  end

  defp first_drop(_), do: true

  for {char, code} <- replaces do #Generates replacements
    defp replace(unquote(char)), do: unquote(code)
  end

  defp replace(char), do: char

  for char <- breaking_drops do #Generates breaking drops
    defp second_drop(unquote(char)), do: false
  end

  defp second_drop(_), do: true

  defp normalize(string) do #replaces special characters with their a-z equivelants
    string
    |> String.normalize(:nfd)
    |> String.replace(~r/\W/u, "")
  end
end
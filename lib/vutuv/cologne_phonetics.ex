defmodule Vutuv.ColognePhonetics do

  cologne_replacements_with_rules = 
  [
    #This is the replacement list with rules included. The order is very imporant for the correct functionality of the algorithm.
    #This is because the match functions generate in the same order as the rules are defined, and match in the same order as well.
    {?p, '3', %{before: ?h}},

    {?c, '4', %{first: true, before: ?a}},
    {?c, '4', %{first: true, before: ?h}},
    {?c, '4', %{first: true, before: ?k}},
    {?c, '4', %{first: true, before: ?l}},
    {?c, '4', %{first: true, before: ?o}},
    {?c, '4', %{first: true, before: ?q}},
    {?c, '4', %{first: true, before: ?r}},
    {?c, '4', %{first: true, before: ?u}},
    {?c, '4', %{first: true, before: ?x}},

    {?c, '8', %{after: ?s}},
    {?c, '8', %{after: ?z}},

    {?c, '8', %{first: true}},

    {?c, '4', %{before: ?a}},
    {?c, '4', %{before: ?h}},
    {?c, '4', %{before: ?k}},
    {?c, '4', %{before: ?o}},
    {?c, '4', %{before: ?q}},
    {?c, '4', %{before: ?u}},
    {?c, '4', %{before: ?x}},

    {?c, '8', %{first: true}},

    {?d, '8', %{before: ?c}},
    {?d, '8', %{before: ?s}},
    {?d, '8', %{before: ?z}},
    {?t, '8', %{before: ?c}},
    {?t, '8', %{before: ?s}},
    {?t, '8', %{before: ?z}},

    {?x, '8', %{after: ?c}},
    {?x, '8', %{after: ?k}},
    {?x, '8', %{after: ?q}}
  ]

  cologne_replacements = 
  [ 
    #This is the list for basic replacements. Order does not matter here.
    {?a, '0'}, {?e, '0'}, {?i, '0'}, {?j, '0'}, {?o, '0'}, {?u, '0'}, {?y, '0'},
    {?h, ''},
    {?b, '1'}, {?p, '1'},
    {?d, '2'}, {?t, '2'},
    {?f, '3'}, {?v, '3'}, {?w, '3'},
    {?g, '4'}, {?k, '4'}, {?q, '4'},
    {?x, '48'},
    {?l, '5'},
    {?m, '6'}, {?n, '6'},
    {?r, '7'},
    {?s, '8'}, {?z, '8'}, {?c, '8'},
  ]
  

  def to_cologne(string) do #The three steps of the cologne phonetics algorithm, see https://en.wikipedia.org/wiki/Cologne_phonetics for more info.
    encode_string(string) #Converts the string to representative coded numbers in a char list
    |> Enum.dedup #Removes consecutive duplicates
    |> remove_zeroes #Removes all zeroes, ignoring the first character
    |> to_string #Converts char_list to string for return
  end

  defp encode_string(""), do: ""

  defp encode_string(string) do
    [head|tail] = String.to_char_list(string) 
    encode_string('', nil, nil, head, tail) #Initiate recursion
  end

  defp encode_string(encoded, prev, char, next, [head|tail]) do
    encoded++encode(prev, char, next) #As long as the char list is not empty, recurse
    |> encode_string(char, next, head, tail)
  end

  defp encode_string(encoded, prev, char, next, []) do
    encoded #If the char list is empty, the operation  is finished, encode the last two letters.
    ++
    encode(prev, char, next)
    ++
    encode(char, next, nil)
  end

  #This function block defines pattern matchable functions for every possible replacement.
  #This allows for ultra fast processing of the replacements.

  for {char, code, rule} <- cologne_replacements_with_rules do #This generates special rule matches
    cond do
      rule[:before] && rule[:after] -> defp encode(unquote(rule.after), unquote(char), unquote(rule.before)), do: unquote(code)
      rule[:first] && rule[:before] -> defp encode(nil, unquote(char), unquote(rule.before)), do: unquote(code)
      rule[:first] -> defp encode(nil, unquote(char), _), do: unquote(code)
      rule[:before] -> defp encode(_, unquote(char), unquote(rule.before)), do: unquote(code)
      rule[:after]-> defp encode(unquote(rule.after), unquote(char), _), do: unquote(code)
    end
  end

  for {char, code} <- cologne_replacements do #This generates simple matches
    defp encode(_, unquote(char), _), do: unquote(code)
  end

  defp encode(_,nil,_), do: '' #If the recursion is just starting, the selected character will be nil, so don't add to the encoded string.

  defp remove_zeroes([head|tail]) do
    [head|Enum.reject(tail, &(&1 == ?0))]
  end
end
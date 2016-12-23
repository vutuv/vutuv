defmodule Vutuv.Locale do
  use Vutuv.Web, :model
  import Ecto.Query

  schema "locales" do
    field :value, :string
    field :endonym, :string

    has_many :exonyms, Vutuv.Exonym

    timestamps()
  end

  @iso_codes %{"alpha2" => "English", "aa" => "Afar", "ab" => "Abkhazian", "ae" => "Avestan", "af" => "Afrikaans", "ak" => "Akan", "am" => "Amharic", "an" => "Aragonese", "ar" => "Arabic", "as" => "Assamese", "av" => "Avaric", "ay" => "Aymara", "az" => "Azerbaijani", "ba" => "Bashkir", "be" => "Belarusian", "bg" => "Bulgarian", "bh" => "Biharilanguages", "bi" => "Bislama", "bm" => "Bambara", "bn" => "Bengali", "bo" => "Tibetan", "br" => "Breton", "bs" => "Bosnian", "ca" => "Catalan;Valencian", "ce" => "Chechen", "ch" => "Chamorro", "co" => "Corsican", "cr" => "Cree", "cs" => "Czech", "cu" => "ChurchSlavic;OldSlavonic;ChurchSlavonic;OldBulgarian;OldChurchSlavonic", "cv" => "Chuvash", "cy" => "Welsh", "da" => "Danish", "de" => "German", "dv" => "Divehi;Dhivehi;Maldivian", "dz" => "Dzongkha", "ee" => "Ewe", "el" => "Greek => Modern(1453-)", "en" => "English", "eo" => "Esperanto", "es" => "Spanish;Castilian", "et" => "Estonian", "eu" => "Basque", "fa" => "Persian", "ff" => "Fulah", "fi" => "Finnish", "fj" => "Fijian", "fo" => "Faroese", "fr" => "French", "fy" => "WesternFrisian", "ga" => "Irish", "gd" => "Gaelic;ScottishGaelic", "gl" => "Galician", "gn" => "Guarani", "gu" => "Gujarati", "gv" => "Manx", "ha" => "Hausa", "he" => "Hebrew", "hi" => "Hindi", "ho" => "HiriMotu", "hr" => "Croatian", "ht" => "Haitian;HaitianCreole", "hu" => "Hungarian", "hy" => "Armenian", "hz" => "Herero", "ia" => "Interlingua(InternationalAuxiliaryLanguageAssociation)", "id" => "Indonesian", "ie" => "Interlingue;Occidental", "ig" => "Igbo", "ii" => "SichuanYi;Nuosu", "ik" => "Inupiaq", "io" => "Ido", "is" => "Icelandic", "it" => "Italian", "iu" => "Inuktitut", "ja" => "Japanese", "jv" => "Javanese", "ka" => "Georgian", "kg" => "Kongo", "ki" => "Kikuyu;Gikuyu", "kj" => "Kuanyama;Kwanyama", "kk" => "Kazakh", "kl" => "Kalaallisut;Greenlandic", "km" => "CentralKhmer", "kn" => "Kannada", "ko" => "Korean", "kr" => "Kanuri", "ks" => "Kashmiri", "ku" => "Kurdish", "kv" => "Komi", "kw" => "Cornish", "ky" => "Kirghiz;Kyrgyz", "la" => "Latin", "lb" => "Luxembourgish;Letzeburgesch", "lg" => "Ganda", "li" => "Limburgan;Limburger;Limburgish", "ln" => "Lingala", "lo" => "Lao", "lt" => "Lithuanian", "lu" => "Luba-Katanga", "lv" => "Latvian", "mg" => "Malagasy", "mh" => "Marshallese", "mi" => "Maori", "mk" => "Macedonian", "ml" => "Malayalam", "mn" => "Mongolian", "mr" => "Marathi", "ms" => "Malay", "mt" => "Maltese", "my" => "Burmese", "na" => "Nauru", "nb" => "Bokmål => Norwegian;NorwegianBokmål", "nd" => "Ndebele => North;NorthNdebele", "ne" => "Nepali", "ng" => "Ndonga", "nl" => "Dutch;Flemish", "nn" => "NorwegianNynorsk;Nynorsk => Norwegian", "no" => "Norwegian", "nr" => "Ndebele => South;SouthNdebele", "nv" => "Navajo;Navaho", "ny" => "Chichewa;Chewa;Nyanja", "oc" => "Occitan(post1500);Provençal", "oj" => "Ojibwa", "om" => "Oromo", "or" => "Oriya", "os" => "Ossetian;Ossetic", "pa" => "Panjabi;Punjabi", "pi" => "Pali", "pl" => "Polish", "ps" => "Pushto;Pashto", "pt" => "Portuguese", "qu" => "Quechua", "rm" => "Romansh", "rn" => "Rundi", "ro" => "Romanian;Moldavian;Moldovan", "ru" => "Russian", "rw" => "Kinyarwanda", "sa" => "Sanskrit", "sc" => "Sardinian", "sd" => "Sindhi", "se" => "NorthernSami", "sg" => "Sango", "si" => "Sinhala;Sinhalese", "sk" => "Slovak", "sl" => "Slovenian", "sm" => "Samoan", "sn" => "Shona", "so" => "Somali", "sq" => "Albanian", "sr" => "Serbian", "ss" => "Swati", "st" => "Sotho => Southern", "su" => "Sundanese", "sv" => "Swedish", "sw" => "Swahili", "ta" => "Tamil", "te" => "Telugu", "tg" => "Tajik", "th" => "Thai", "ti" => "Tigrinya", "tk" => "Turkmen", "tl" => "Tagalog", "tn" => "Tswana", "to" => "Tonga(TongaIslands)", "tr" => "Turkish", "ts" => "Tsonga", "tt" => "Tatar", "tw" => "Twi", "ty" => "Tahitian", "ug" => "Uighur;Uyghur", "uk" => "Ukrainian", "ur" => "Urdu", "uz" => "Uzbek", "ve" => "Venda", "vi" => "Vietnamese", "vo" => "Volapük", "wa" => "Walloon", "wo" => "Wolof", "xh" => "Xhosa", "yi" => "Yiddish", "yo" => "Yoruba", "za" => "Zhuang;Chuang", "zh" => "Chinese", "zu" => "Zulu"}
  
  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:value, :endonym])
    |> validate_required([:value, :endonym])
  end

  def locale_select_list do
    Vutuv.Repo.all(from l in __MODULE__, select: {l.endonym, l.id})
  end

  def locale_id(code) do
    Vutuv.Repo.one(from l in __MODULE__, where: l.value == ^code, select: l.id)
  end

  defimpl String.Chars, for: Vutuv.Locale do
    def to_string(locale), do: String.upcase "#{locale.value}"
  end

  defimpl List.Chars, for: Vutuv.Locale do
    def to_charlist(locale), do: '#{locale.value}'
  end
end

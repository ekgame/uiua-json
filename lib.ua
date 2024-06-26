# Experimental!

# --- Data structures ---

PrivateEnum! ↚^ ⍚($"_ ↚ $_ _\n".) :⇡⧻.⍚(⊂∩°□)°⊂
PrivateEnum!(JsonToken|ObjectOpen|ObjectClose|ArrayOpen|ArrayClose|Comma|Colon|String|Number|Boolean|Null|Eof)

Enum! ↚^ ⍚($"_ ← $_ _\n".) :⇡⧻.⍚(⊂∩°□)°⊂
Enum!(Json|ObjectValue|ArrayValue|StringValue|NumberValue|BooleanValue|NullValue)

# Thanks to JoaoFelipe3 (https://github.com/JoaoFelipe3) for the struct macro.
PrivateStruct! ↚^ ⍜°⊂⊃(
  □$"_ ↚ {_}\n":↯⊙@⊙⧻:
| ⍚$"_ ↚ °□⊡_\n":⇡⧻.⍚◇⊂¤
)
PrivateStruct!(Token|Type|Value)

Struct! ↚^ ⍜°⊂⊃(
  □$"_ ← {_}\n":↯⊙@⊙⧻:
| ⍚$"_ ← °□⊡_\n":⇡⧻.⍚◇⊂¤
)
Struct!(JsonElement|Type|Value)

# --- Utilities ---

# Hex to integer decoder by allantaylor314 
HexToDec ↚ /(+×16)-@0-×39>@`.¯⌵

Error ↚ 0⍤:0
Indent ↚ /$"_\n_"⍚(⊂▽:@ :)⊜□⊙:≠@\n,
HexDigits ↚ "0123456789abcdef"
DecToHex ↚ ⊏:HexDigits⇌°⋯↯∞_4⋯
ToUnicodeChar ↚ ⍢(⊂@0)(<4⧻) DecToHex -@\0
AsciiChars ↚ +@ ⇡ -33 128
StripLeadingWhitespace ↚ ▽\↥∵(⟨0|0|0|1⟩⊗:"\n\r ").
EmptyMap ↚ map {} {}

# Escaping/unescaping

# UTF codepoint unescape by jonathanperret
UtfCodeToChar ↚ + @\0 HexToDec

UnescapeJsonChar ↚ (
  °⊂
  ≍ @\\.
  ⍥(
    °⊂:
    ⊗:"\\/nrbtfu"
    ⊃(∘|⋅⋅⋅∘|⋅⋅∘|⋅∘)
    :⟨
      ⊂:@\\
    | ⊂:@/
    | ⊂:@\n
    | ⊂:@\r
    | ⊂:@\b
    | ⊂:@\t
    | ⊂:@\u000C
    | ⊃(∘|⋅⋅∘|⋅∘)⊂:⊙:UtfCodeToChar⊃↙↘4:⊙:
    ⟩
  )
  ⍥(:⊂⊙.:⊙:)¬≍ @\\.
  :◌
)

UnescapeJsonString ↚ (
  :""
  ⍢(UnescapeJsonChar)(>0⧻)
  ◌
)

EscapeJsonCharacter ↚ (
  "\\\n\r\b\t\u000C".
  ⊗:
  ⟨
    "\\\\"◌
  | "\\n"◌
  | "\\r"◌
  | "\\b"◌
  | "\\t"◌
  | "\\f"
  | ¬∊:AsciiChars.
    ⍥(⊂"\\u"ToUnicodeChar)
  ⟩
)

EscapeJsonString ↚ ∧(⊂:EscapeJsonCharacter):""
EscapeJsonStringWithQuotes ↚ ⊂:@"⊂@"EscapeJsonString

# --- Tokenizing ---

# Consumes defined number of characters from the input
# and appends it to a list of tokens.
# Arguments:
#   a: the number of characters to consume
#   b: the token type
#   c: the input to consume from
#   d: the token list
# Returns:
#   the unconsomed input
#   the token list with new token appended to the end
ConsumeToken ↚ :⊂:⊙: ¤Token :⊙: ⊃↙↘ ⊃(∘|⋅⋅∘|⋅∘)
ConsumeChar ↚ ConsumeToken 1
ConsumeString ↚ (
  .
  ⬚(□"") regex $ ^\x22(\\([\x22\\/bfnrt]|u[a-fA-F0-9]{4})|[^\x00-\x1F\x7F\x22]+)*\x22
  ⟨Error $"Invalid string at '_'"◌|ConsumeToken:JsonTokenString⧻°□⊢⊢⟩⧻.
)
ConsumeBoolean ↚ (
  regex "^(true|false)".
  ConsumeToken:JsonTokenBoolean⧻°□⊢⊢
)
ConsumeNull ↚ ⟨Error $"Unexpected character at '_'".|ConsumeToken 4 JsonTokenNull⟩⧻regex"^null".
ConsumeKeyword ↚ ⟨ConsumeNull|ConsumeBoolean⟩⧻regex"^(true|false)".
ConsumeNumber ↚ (
  .
  ⬚(□"") regex $ ^-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][+-]?[0-9]+)?
  ConsumeToken:JsonTokenNumber⧻°□⊢⊢
)
ConsumeSpecial ↚ ⟨ConsumeKeyword|ConsumeNumber⟩⧻regex"^[0-9]".
Consume ↚ ⟨
  ConsumeChar JsonTokenObjectOpen
| ConsumeChar JsonTokenObjectClose
| ConsumeChar JsonTokenArrayOpen
| ConsumeChar JsonTokenArrayClose
| ConsumeChar JsonTokenComma
| ConsumeChar JsonTokenColon
| ConsumeString
| ConsumeSpecial
⟩⊗⊙:⊢.:"{}[],:\""

Tokenize ↚ (
  ◌⍢(Consume StripLeadingWhitespace)(>0⧻ StripLeadingWhitespace) :[]
  ⊂: ¤Token JsonTokenEof "EOF"
)

# --- Parsing ---

AssertTokenType ↚ ⍥(
  Error $"Unexpected token \"_\"" TokenValue ⊢
) ¬∊ ⊙: TokenType ⊢. :

ParseValue ↚ |1.2 ⟨
  JsonElement JsonStringValue UnescapeJsonString ↘1↘¯1 TokenValue ⊃⊢(↘1)
| JsonElement JsonNumberValue ⋕ TokenValue ⊃⊢(↘1)
| JsonElement JsonBooleanValue ≍"true" TokenValue ⊃⊢(↘1)
| JsonElement JsonNullValue 0 ↘1
| :{}↘1
  ⍢(
    ParseValue
    :⊂:□:⊃(⋅⋅∘)(⊙∘)
    AssertTokenType [JsonTokenArrayClose JsonTokenComma]
    ⍥(↘1) ≍ JsonTokenComma TokenType ⊢.
  )(¬≍ JsonTokenArrayClose JsonElementType ⊢.)
  JsonElement JsonArrayValue :↘1
| :EmptyMap↘1
  ⍢(
    AssertTokenType [JsonTokenString]
    :UnescapeJsonString ↘1↘¯1 TokenValue ⊃⊢(↘1)
    AssertTokenType [JsonTokenColon]
    ParseValue ↘1
    ⊃(⋅⋅∘|∘|⋅⋅⋅∘|⋅∘)
    :insert □
    AssertTokenType [JsonTokenComma JsonTokenObjectClose]
    ⍥(↘1) ≍ JsonTokenComma TokenType ⊢.
  )(¬≍ JsonTokenObjectClose JsonElementType ⊢.)
  JsonElement JsonObjectValue :↘1
| Error $"Unexpected token _" ⊃⊢(↘1)
⟩ ⊗: {JsonTokenString JsonTokenNumber JsonTokenBoolean
      JsonTokenNull JsonTokenArrayOpen JsonTokenObjectOpen} TokenType ⊢.

ParseJsonString ← ⊙◌ ParseValue Tokenize

# --- Json builders ---

BuildJsonObject! ← ^! JsonElement JsonObjectValue EmptyMap
BuildJsonArray! ← ^! JsonElement JsonArrayValue {}

JsonString ← JsonElement JsonStringValue
JsonNumber ← JsonElement JsonNumberValue
JsonBoolean ← JsonElement JsonBooleanValue
JsonNull ← JsonElement JsonNullValue 0
JsonObjectEntry ← (
  ⊃(⋅⋅∘|⊙∘)
  ⍜(JsonElementValue)(insert□⊃(⋅⊙∘|∘))
)
JsonArrayEntry ← ⍜(JsonElementValue)(⊂:□:):

# --- Stringifying ---

StringifyJson ← |1 (
  ⊃(JsonElementType|JsonElementValue)°□
  ⊗:[JsonStringValue JsonNumberValue JsonBooleanValue JsonNullValue JsonArrayValue JsonObjectValue]
  ⟨
    EscapeJsonStringWithQuotes
  | °⋕
  | °□⊡≠0:{"false" "true"}
  | "null"◌
  | ⊂:@]⊂@[ /($"_,_")≡(□StringifyJson)
  | ≡(□$"_:_"⊃(EscapeJsonStringWithQuotes°□∘|StringifyJson⋅∘))°map
    ⊂:@}⊂@{ /($"_,_")
  ⟩
)

StringifyJsonPretty ← |1 (
  JsonElementType.°□
  ⊗:[JsonArrayValue JsonObjectValue]
  ⟨
    /$"_,\n_"≡(□StringifyJsonPretty) JsonElementValue
    ⊂:"\n]"⊂"[\n"Indent 2
  | °mapJsonElementValue
    ≡(□$"_: _" : StringifyJsonPretty : EscapeJsonStringWithQuotes °□)
    ⊂:"\n}"⊂"{\n"Indent 2 /$"_,\n_"
  | StringifyJson
  ⟩
)

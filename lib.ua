# Experimental!
Enum! ←^ ⍚($"_ ← $_ _\n".) :⇡⧻.⍚(⊂∩°□:):⊃↙↘1
Enum!(JsonToken|ObjectOpen|ObjectClose|ArrayOpen|ArrayClose|Comma|Colon|String|Number|Boolean|Null|Eof)
Enum!(Json|ObjectValue|ArrayValue|StringValue|NumberValue|BooleanValue|NullValue)

# Struct macro by joaozin003 from Uiua Discord
Struct! ←^ (
  ◇⟜(⍚⊂¤)°⊂
  □$"_ ← {_}\n":⊂⊃(↯:@⊙-1|↯:@∘±)⧻,
  ⍚$"_ ← °□⊡_\n":⇡⧻.:
  ⊂:
)
Struct!(Token|Type|Value)
Struct!(JsonElement|Type|Value)

Error ← 0⍤:0

# Hex to integer decoder by allantaylor314 
HexToDec ← /(+×16)-@0-×39>@`.¯⌵

# UTF codepoint unescape by jonathanperret
UtfCodeToChar ← + @\0 HexToDec

UnescapeJsonChar ← (
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

UnescapeJsonString ← (
  :""
  ⍢(UnescapeJsonChar)(>0⧻)
  ◌
)

HexDigits ← "0123456789abcdef"
DecToHex ← ⊏:HexDigits⇌°⋯↯∞_4⋯
ToUnicodeChar ← ⍢(⊂@0)(<4⧻) DecToHex -@\0
AsciiChars ← +@ ⇡ -33 128

EscapeJsonCharacter ← (
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

EscapeJsonString ← ∧(⊂:EscapeJsonCharacter):""
EscapeJsonStringWithQuotes ← ⊂:@"⊂@"EscapeJsonString

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
ConsumeToken ← :⊂:⊙: ¤Token :⊙: ⊃↙↘ ⊃(∘|⋅⋅∘|⋅∘)
ConsumeChar ← ConsumeToken 1
ConsumeString ← (
  .
  ⬚(□"") regex $ ^\x22(\\([\x22\\/bfnrt]|u[a-fA-F0-9]{4})|[^\x00-\x1F\x7F\x22]+)*\x22
  ⟨Error $"Invalid string at '_'"◌|ConsumeToken:JsonTokenString⧻°□⊢⊢⟩⧻.
)
ConsumeBoolean ← (
  regex "^(true|false)".
  ConsumeToken:JsonTokenBoolean⧻°□⊢⊢
)
ConsumeNull ← ⟨Error $"Unexpected character at '_'".|ConsumeToken 4 JsonTokenNull⟩⧻regex"^null".
ConsumeKeyword ← ⟨ConsumeNull|ConsumeBoolean⟩⧻regex"^(true|false)".
ConsumeNumber ← (
  .
  ⬚(□"") regex $ ^-?(0|[1-9][0-9]*)(\\.[0-9]+)?([eE][+-]?[0-9]+)?
  ConsumeToken:JsonTokenNumber⧻°□⊢⊢
)
ConsumeSpecial ← ⟨ConsumeKeyword|ConsumeNumber⟩⧻regex"^[0-9]".
Consume ← ⟨
  ConsumeChar JsonTokenObjectOpen
| ConsumeChar JsonTokenObjectClose
| ConsumeChar JsonTokenArrayOpen
| ConsumeChar JsonTokenArrayClose
| ConsumeChar JsonTokenComma
| ConsumeChar JsonTokenColon
| ConsumeString
| ConsumeSpecial
⟩⊗⊙:⊢.:"{}[],:\""

StripLeadingWhitespace ← ▽\↥∵(⟨0|0|0|1⟩⊗:"\n\r ").
Tokenize ← (
  ◌⍢(Consume StripLeadingWhitespace)(>0⧻) :[]
  ⊂: ¤Token JsonTokenEof "EOF"
)

AssertTokenType ← ⍥(
  Error $"Unexpected token \"_\"" TokenValue ⊢
) ¬∊ ⊙: TokenType ⊢. :

# A hack to create an empty box array that can be successfully unmapped
EmptyMap ← (
  {}
  insert ∩□ "a" "b"
  remove "a"
)

ParseValue ← |1.2 ⟨
  JsonElement JsonStringValue UnescapeJsonString ↘1↘¯1 TokenValue ⊃⊢(↘1)
| JsonElement JsonNumberValue ⋕ TokenValue ⊃⊢(↘1)
| JsonElement JsonBooleanValue ≍"true" TokenValue ⊃⊢(↘1)
| JsonElement JsonNullValue 0 ↘1
| :{}↘1
  ⍢(
    ParseValue
    :⊂:¤:⊃(⋅⋅∘)(⊙∘)
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

Parse ← ⊙◌ ParseValue Tokenize

BuildJsonObject! ← ^! JsonElement JsonObjectValue {}
BuildJsonArray! ← ^! JsonElement JsonArrayValue {}

JsonString ← JsonElement JsonStringValue
JsonNumber ← JsonElement JsonNumberValue
JsonBoolean ← JsonElement JsonBooleanValue
JsonNull ← JsonElement JsonNullValue 0
JsonObjectEntry ← (
  ⊃(⋅⋅∘|⊙∘)
  ⍜(JsonElementValue)(insert□⊃(⋅⊙∘|∘))
)
JsonArrayEntry ← ⍜(JsonElementValue)(⊂□:):

Stringify ← |1 (
  ⊃(JsonElementType|JsonElementValue)
  ⊗:[JsonStringValue JsonNumberValue JsonBooleanValue JsonNullValue JsonArrayValue JsonObjectValue]
  ⟨
    EscapeJsonStringWithQuotes
  | °⋕
  | °□⊡≠0:{"false" "true"}
  | "null"◌
  | ⊂:@]⊂@[ /($"_,_")≡(□Stringify)
  | ≡(□$"_:_"⊃(EscapeJsonStringWithQuotes°□∘|Stringify⋅∘))°map
    ⊂:@}⊂@{ /($"_,_")
  ⟩
)

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

UtfCodeToChar ← (
  >127. HexToDec
  ⍥(
    ⬚0↯ ∞_6 ⋯
    ⇌≡(⊂: [0 1])
    ⟜⧻
    ⍜⊢(⍜(↙)(↥1)¯:)
    °⋯
  )
  ⊢°utf
)

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
    | ?⊃(∘|⋅⋅∘|⋅∘)⊂:⊙:UtfCodeToChar⊃↙↘4:⊙:
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
ConsumeToken ← :λ(⊂d ¤Token b ↙ac ↘ac)
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
| :{}↘1
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

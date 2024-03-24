# Experimental!
Enum! ←^ ⍚($"_ ← $_ _\n".) :⇡⧻.⍚(⊂∩°□:):⊃↙↘1
Enum!(JsonToken|ObjectOpen|ObjectClose|ArrayOpen|ArrayClose|Comma|Colon|String|Number|Boolean|Null|Eof)
Enum!(Json|ObjectValue|ArrayValue|StringValue|NumberValue|BooleanValue|NullValue)

Error ← 0⍤:0

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
ConsumeToken ← :λ(⊂d[{b ↙ac}]↘ac)
ConsumeChar ← ConsumeToken 1

ConsumeString ← (
  .
  ⬚(□"") regex $ ^"(\\\\(["\\/bfnrt]|u[a-fA-F0-9]{4})|[^"\\\\0-\\x1F\\x7F]+)*"
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
| ConsumeChar JsonTokenArrayClose
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
  ⊂:[{JsonTokenEof ""}]
)

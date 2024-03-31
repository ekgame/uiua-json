# Experimental!

~ "lib.ua"
  ~ BuildJsonArray! JsonArrayEntry
  ~ BuildJsonObject! JsonObjectEntry
  ~ JsonBoolean JsonNull JsonNumber JsonString
  ~ ParseJsonString
  ~ StringifyJson StringifyJsonPretty

ParseJsonString $ "Hello world"
⍤ "Failed to parse string" ≍ JsonString "Hello world"

ParseJsonString $ "thing\n\r\f\b\t"
⍤ "Failed to parse complex string" ≍ JsonString "thing\n\r\u000C\b\t"

ParseJsonString $ "Hello \u00f8 world"
⍤ "Failed to parse unicode string" ≍ JsonString "Hello ø world"

ParseJsonString $ 42
⍤ "Failed to parse number" ≍ JsonNumber 42

ParseJsonString $ true
⍤ "Failed to parse boolean" ≍ JsonBoolean 1

ParseJsonString $ false
⍤ "Failed to parse boolean" ≍ JsonBoolean 0

ParseJsonString $ null
⍤ "Failed to parse null" ≍ JsonNull

ParseJsonString $ [42, true, false, null]
⍤ "Failed to parse array" ≍ BuildJsonArray!(
  JsonArrayEntry JsonNumber 42
  JsonArrayEntry JsonBoolean 1
  JsonArrayEntry JsonBoolean 0
  JsonArrayEntry JsonNull
)

ParseJsonString $ {"foo": 42, "bar": true, "baz": false, "qux": null}
⍤ "Failed to parse object" ≍ BuildJsonObject!(
  JsonObjectEntry "foo" JsonNumber 42
  JsonObjectEntry "bar" JsonBoolean 1
  JsonObjectEntry "baz" JsonBoolean 0
  JsonObjectEntry "qux" JsonNull
)

$ {
$   "foo": 42,
$   "bar": true,
$   "baz": false,
$   "qux": null,
$   "quux": {
$     "corge": 42,
$     "grault": true,
$     "garply": false,
$     "waldo": null,
$   },
$   "fred": [42, true, false, null],
$   "plugh": [
$     {"foo": 42, "bar": true, "baz": false, "qux": null},
$     {"foo": 42, "bar": true, "baz": false, "qux": null},
$   ],
$ }
ParseJsonString
⍤ "Failed to parse complex object" ≍ BuildJsonObject!(
  JsonObjectEntry "foo" JsonNumber 42
  JsonObjectEntry "bar" JsonBoolean 1
  JsonObjectEntry "baz" JsonBoolean 0
  JsonObjectEntry "qux" JsonNull
  JsonObjectEntry "quux" BuildJsonObject!(
    JsonObjectEntry "corge" JsonNumber 42
    JsonObjectEntry "grault" JsonBoolean 1
    JsonObjectEntry "garply" JsonBoolean 0
    JsonObjectEntry "waldo" JsonNull
  )
  JsonObjectEntry "fred" BuildJsonArray!(
    JsonArrayEntry JsonNumber 42
    JsonArrayEntry JsonBoolean 1
    JsonArrayEntry JsonBoolean 0
    JsonArrayEntry JsonNull
  )
  JsonObjectEntry "plugh" BuildJsonArray!(
    JsonArrayEntry BuildJsonObject!(
      JsonObjectEntry "foo" JsonNumber 42
      JsonObjectEntry "bar" JsonBoolean 1
      JsonObjectEntry "baz" JsonBoolean 0
      JsonObjectEntry "qux" JsonNull
    )
    JsonArrayEntry BuildJsonObject!(
      JsonObjectEntry "foo" JsonNumber 42
      JsonObjectEntry "bar" JsonBoolean 1
      JsonObjectEntry "baz" JsonBoolean 0
      JsonObjectEntry "qux" JsonNull
    )
  )
)

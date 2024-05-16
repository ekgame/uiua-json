# JSON encoding/decoding for Uiua

A library to parse JSON strings into a structure you can interpret in Uiua. Also includes utility functions to build JSON structures and stringify them.

## About

Uiua does not have native functions to parse, manipulate and stringify JSON, so I built this library to do just that. The implementation is fairly rigorously tested and ready for general use. If you want to build microservices in Uiua, this should prove to be indispensible.

Because Uiua does not have primitives for `true`, `false` and `null`, all primitives are wrapped in a box array with a type and a literal value. For `true`, the literal value is `1`, for `false` and `null`, the literal value is `0`. See examples for how to check for JSON value type. 

# Usage

Simplest case of JSON parsing and value retrieval.

[Test the code online](https://www.uiua.org/pad?src=0_10_0__IyBFeHBlcmltZW50YWwhCgp-ICJnaXQ6IGdpdGh1Yi5jb20vZWtnYW1lL3VpdWEtanNvbiIgfiBKc29uRWxlbWVudFZhbHVlIFBhcnNlSnNvblN0cmluZwoKJCB7CiQgICAiZm9vIjogImJhciIKJCB9CgojIFBhcnNlIHRoZSBKU09OClBhcnNlSnNvblN0cmluZwoKIyBUaGUgb2JqZWN0IHZhbHVlcyBhcmUgd3JhcHBlZCBpbiBhIHR5cGVkIGVsZW1lbnQsIHVzZSBKc29uRWxlbWVudFZhbHVlIHRvIHVud3JhcApKc29uRWxlbWVudFZhbHVlCgojIEdldCB0aGUgdmFsdWUgb2YgImZvbyIsIHdoaWNoIGlzIHdyYXBwZWQgaW4gYSB0eXBlZCBlbGVtZW50IGFuZCB1bndyYXAgaXQKSnNvbkVsZW1lbnRWYWx1ZSBnZXQgImZvbyIK)

```uiua
# Experimental!

~ "git: github.com/ekgame/uiua-json" ~ JsonElementValue ParseJsonString

$ {
$   "foo": "bar"
$ }

# Parse the JSON
ParseJsonString

# The object values are wrapped in a typed element, use JsonElementValue to unwrap
JsonElementValue

# Get the value of "foo", which is wrapped in a typed element and unwrap it
JsonElementValue get "foo" 
```

This library also includes convinient builder functions to construct complex JSON structures and get a string from them.

[Test the code online](https://www.uiua.org/pad?src=0_10_0__IyBFeHBlcmltZW50YWwhCgp-ICJnaXQ6IGdpdGh1Yi5jb20vZWtnYW1lL3VpdWEtanNvbiIKICB-IEJ1aWxkSnNvbkFycmF5ISBKc29uQXJyYXlFbnRyeQogIH4gQnVpbGRKc29uT2JqZWN0ISBKc29uT2JqZWN0RW50cnkKICB-IEpzb25Cb29sZWFuIEpzb25OdWxsIEpzb25OdW1iZXIgSnNvblN0cmluZwogIH4gU3RyaW5naWZ5SnNvblByZXR0eQoKIyBCdWlsZCB0aGUgSlNPTiBvYmplY3QuCkJ1aWxkSnNvbk9iamVjdCEoCiAgSnNvbk9iamVjdEVudHJ5ICJrZXkiIEpzb25TdHJpbmcgInZhbHVlIgogIEpzb25PYmplY3RFbnRyeSAibnVtYmVyIiBKc29uTnVtYmVyIDQyCiAgSnNvbk9iamVjdEVudHJ5ICJib29sLTEiIEpzb25Cb29sZWFuIDEKICBKc29uT2JqZWN0RW50cnkgImJvb2wtMiIgSnNvbkJvb2xlYW4gMAogIEpzb25PYmplY3RFbnRyeSAibnVsbC12YWx1ZSIgSnNvbk51bGwKICBKc29uT2JqZWN0RW50cnkgImxpc3QiIEJ1aWxkSnNvbkFycmF5ISgKICAgIEpzb25BcnJheUVudHJ5IEpzb25OdW1iZXIgMQogICAgSnNvbkFycmF5RW50cnkgSnNvbk51bWJlciAyCiAgICBKc29uQXJyYXlFbnRyeSBKc29uTnVtYmVyIDMKICApCiAgSnNvbk9iamVjdEVudHJ5ICJuZXN0ZWQiIEJ1aWxkSnNvbk9iamVjdCEoCiAgICBKc29uT2JqZWN0RW50cnkgIm5lc3RlZC1rZXkiIEpzb25TdHJpbmcgIm5lc3RlZC12YWx1ZSIKICApCikKCiMgQ29udmVydCBpdCB0byBzdHJpbmcgYW5kIHByaW50IGl0LgojIEFsdGVybmF0aXZlbHkgdXNlICJTdHJpbmdpZnlKc29uIiBpZiB5b3UgZG9uJ3QgbmVlZCBmb3JtYXR0aW5nLgomcCBTdHJpbmdpZnlKc29uUHJldHR5Cg==)

```uiua
# Experimental!

~ "git: github.com/ekgame/uiua-json"
  ~ BuildJsonArray! JsonArrayEntry
  ~ BuildJsonObject! JsonObjectEntry
  ~ JsonBoolean JsonNull JsonNumber JsonString
  ~ StringifyJsonPretty

# Build the JSON object.
BuildJsonObject!(
  JsonObjectEntry "key" JsonString "value"
  JsonObjectEntry "number" JsonNumber 42
  JsonObjectEntry "bool-1" JsonBoolean 1
  JsonObjectEntry "bool-2" JsonBoolean 0
  JsonObjectEntry "null-value" JsonNull
  JsonObjectEntry "list" BuildJsonArray!(
    JsonArrayEntry JsonNumber 1
    JsonArrayEntry JsonNumber 2
    JsonArrayEntry JsonNumber 3
  )
  JsonObjectEntry "nested" BuildJsonObject!(
    JsonObjectEntry "nested-key" JsonString "nested-value"
  )
)

# Convert it to string and print it.
# Alternatively use "StringifyJson" if you don't need formatting.
&p StringifyJsonPretty
```

You can also combine the parsing function and the pretty stringifying function to effectively format a JSON string.

[Test the code online](https://www.uiua.org/pad?src=0_10_0__IyBFeHBlcmltZW50YWwhCgp-ICJnaXQ6IGdpdGh1Yi5jb20vZWtnYW1lL3VpdWEtanNvbiIKICB-IFBhcnNlSnNvblN0cmluZwogIH4gU3RyaW5naWZ5SnNvblByZXR0eQoKJCB7InVuZm9ybWF0dGVkIjogImpzb24gc3RyaW5nIiwgInZhbHVlIjogbnVsbCwgIm51bWJlciI6IDQyfQoKJnAgU3RyaW5naWZ5SnNvblByZXR0eSBQYXJzZUpzb25TdHJpbmcK)

```uiua
# Experimental!

~ "git: github.com/ekgame/uiua-json"
  ~ ParseJsonString
  ~ StringifyJsonPretty

$ {"unformatted": "json string", "value": null, "number": 42}

# Parse the string and format it
&p StringifyJsonPretty ParseJsonString
```

You can also use "under" glyph to unwrap values, edit them and wrap them back - effectively editing the JSON.

[Test the code online](https://www.uiua.org/pad?src=0_10_0__IyBFeHBlcmltZW50YWwhCgp-ICJnaXQ6IGdpdGh1Yi5jb20vZWtnYW1lL3VpdWEtanNvbiIKICB-IEpzb25FbGVtZW50VmFsdWUKICB-IFBhcnNlSnNvblN0cmluZyBTdHJpbmdpZnlKc29uCgokIHsibGlzdCI6IFsyLCAzLCA0LCA1XX0KCiMgUGFyc2UgdGhlIHN0cmluZyBhbmQgZm9ybWF0IGl0ClBhcnNlSnNvblN0cmluZwrijZwoCiAgIyBVc2UgInVuZGVyIiB0byB1bndyYXAgdGhlIHZhbHVlcyBpbiAibGlzdCIga2V5CiAgSnNvbkVsZW1lbnRWYWx1ZSBnZXQgImxpc3QiIEpzb25FbGVtZW50VmFsdWUKfCAjIEZvciBlYWNoIHZhbHVlIGluIHRoZSBsaXN0IC0gdW53cmFwIGl0LCBzcXVhcmUgaXQKICDijZrijZwoSnNvbkVsZW1lbnRWYWx1ZXzDly4pCikKJnAgU3RyaW5naWZ5SnNvbgo=)

```uiua
# Experimental!

~ "git: github.com/ekgame/uiua-json"
  ~ JsonElementValue
  ~ ParseJsonString StringifyJson

$ {"list": [2, 3, 4, 5]}

ParseJsonString
⍜(
  # Use "under" to unwrap the values in "list" key
  # After it's done, "under" will automatically wrap it back
  JsonElementValue get "list" JsonElementValue
| # For each value (using "inventory") - unwrap it and square it
  # Then "under" will automatically wrap it back
  ⍚⍜(JsonElementValue|×.)
)
&p StringifyJson
```

If you have a wrapped value, you can check for it's type.

[Test the code online](https://www.uiua.org/pad?src=0_10_0__IyBFeHBlcmltZW50YWwhCgp-ICJnaXQ6IGdpdGh1Yi5jb20vZWtnYW1lL3VpdWEtanNvbiIKICB-IEpzb25Cb29sZWFuVmFsdWUKICB-IEpzb25FbGVtZW50VHlwZSBKc29uRWxlbWVudFZhbHVlCiAgfiBQYXJzZUpzb25TdHJpbmcgU3RyaW5naWZ5SnNvbgoKIyBQYXJzZSBhIEpzb24gdmFsdWUKUGFyc2VKc29uU3RyaW5nICQgdHJ1ZQojIEV4dHJhY3QgdGhlIGVsZW1lbnQgdHlwZQpKc29uRWxlbWVudFR5cGUKIyBDaGFjayBpZiB0aGUgdmFsdWUgaXMgYSBib29sZWFuCiMgQWx0ZXJuYXRpdmVseSBjaGFjayBhZ2FpbnN0ICJKc29uU3RyaW5nVmFsdWUiLCAiSnNvbk51bWJlclZhbHVlIiwKIyAiSnNvbk51bGxWYWx1ZSIsICJKc29uQXJyYXlWYWx1ZSIgb3IgIkpzb25PYmplY3RWYWx1ZSIuCuKJjSBKc29uQm9vbGVhblZhbHVlCg==)

```uiua
# Experimental!

~ "git: github.com/ekgame/uiua-json"
  ~ JsonBooleanValue
  ~ JsonElementType JsonElementValue
  ~ ParseJsonString StringifyJson

# Parse a Json value
ParseJsonString $ true

# Extract the element type
JsonElementType

# Check if the value is a boolean.
# Alternatively chack against "JsonStringValue", "JsonNumberValue",
# "JsonNullValue", "JsonArrayValue" or "JsonObjectValue" as needed.
≍ JsonBooleanValue
```

## Acknowledgements

- Thanks to [JoaoFelipe3](https://github.com/JoaoFelipe3) for the struct macro.
- Thanks to jonathanperret from Uiua Discord for helping to massively simplifying my overkill code to unescape UTF16 codepoints to characters.
- Thanks to allantaylor314 from Uiua Discord for their hexidecomal decoding code.
- General thanks to the [Uiua Discord server](https://discord.gg/3r9nrfYhCc) for holding my hand and Uiua tips.
---
"cruftless": major
---

Drop pattern matching approach causing parsing issues

Before, there used to be a mechanism that would allow you to have the same
element multiple times within the same template. Only if there would be an
_exact_ match with the elements attributes, it would be considered to be decoded
based on whatever the template was suggesting.

```xml
<foo>
  <bar a="1">{first}</bar>
  <bar a="2">{second}</bar>
</foo>
```

Given this template and a file like this:

```xml
<foo>
  <bar a="2">yay</bar>
</foo>
```

… the resulting data object would be this:

```json
{
  "second": "yay"
}
```

It turned out that this was actually causing parsing issues in case the XML
serializer decided to introduce namespaces on an element that didn't have a
namespace before. Since the mechanism was never in use — as far as I can tell
— I decided to drop it.

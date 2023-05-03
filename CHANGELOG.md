# Changes

## 1.0.0

### Major Changes

- 88f9ea8: Drop pattern matching approach causing parsing issues

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

## 0.5.3

- Fixing a bug that somehow reappeared.

## 0.5.2

- Add type definitions.

## 0.4.4

- Fixes an issue where container elements were getting inserted to aggressively
  in case of captures.

## 0.4.3

- Fixes a pattern matching bug causing some issues with namespaces. Note that
  this is related to an undocumented feature which might be dropped in a future
  major version.

## 0.4.2

- Fixes a bug where bindings on attributes are ignoring specific value types set on those attributes.

## 0.4.1

- Fix a number of issues with RelaxNG generation and namespaces.

## 0.4.0

- Add support for capturing an entire nodeset.
- Produce sensible RelaxNG grammars for captures.

## 0.3.5

- Fix a RelaxNG generation issue.

## 0.3.4

- Add CDATA support.

## 0.3.3

- Fixes a bug related to raw data.

## 0.3.2

- Have the ability to get the raw data, even if the fields have been annotated
  with type annotations.

## 0.3.1

- Fixes a RelaxNG generation bug caused by comment binding

## 0.3.0

- Comments used to offer a way to add more binding instructions to the template.
  That has now been replaced by the use of processing instructions.
- As a result, you can now bind comments to variables: `<!--{{foo}}-->`

## 0.2.0

- Dropped `preserveWhitespace`, contemplating xml:space
- Add the posibility to generate RelaxNG schemas from the template

## 0.1.6

- FIX: Falsy values were getting excluded from the output

## 0.1.5

- Upgrade xmldom dependency to ^0.3.0

## 0.1.4

- Added the `preserveWhitespace` option to do exactly that: preserve whitespace.

## 0.1.2

- Exposed the local name of the root element on the template.

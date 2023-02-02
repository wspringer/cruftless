# Changes

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

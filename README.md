<!--
  -- This file is auto-generated from ./README.js.md. Changes should be made there.
  -->

# README

An XML builder / parser that tries to ease the common cases, allowing you to quickly build a model from your document structure and get a builder / parser for free.

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/wspringer/cruftless/tree/master.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/wspringer/cruftless/tree/master)

[![Greenkeeper badge](https://badges.greenkeeper.io/wspringer/cruftless.svg)](https://greenkeeper.io/)

## Yet another XML binding framework?

I hate to say this, but: 'yes'. Or, perhaps: 'no'. Because Cruftless is not really an XML binding framework as you know it. It's almost more like Handlebars. But where Handlebars allows you to only _generate_ documents, Cruftless also allows you to _extract_ data from documents.

## Building XML documents

Cruftless builds a simplified metamodel of your XML document, and it's not based on a DOM API. So, if this is the XML document:

```xml
<person>
  <name>John Doe</name>
  <age>16</age>
</person>
```

Then, using the builder API, Cruftless allows you to _build_ a model of your document like this:

```javascript
const { element, attr, text } = require("cruftless")();

let el = element("person").content(
  element("name").content(text().value("John Doe")),
  element("age").content(text().value(16))
);
```

… and then to turn it back into XML, you'd use the `toXML()` operation:

```javascript
el.toXML(); // ⇨ '<person>\r\n  <name>John Doe</name>\r\n  <age>16</age>\r\n</person>'
```

… or the `toDOM()` operation instead to return a DOM representation of the document:

```javascript
el.toDOM();
```

## Binding

Now, this itself doesn't seem all that useful. Where it gets useful is when you start adding references to your document model:

```javascript
el = element("person").content(
  element("name").content(text().bind("name")),
  element("age").content(text().bind("age"))
);
```

Now, if you want to generate different versions of your XML document for different persons, you can simply pass in an object with `name` and `age` properties:

```javascript
let xml = el.toXML({ name: "John Doe", age: "16" }); // ⇨ '<person>\r\n  <name>John Doe</name>\r\n  <age>16</age>\r\n</person>'
```

But the beauty is, it also works the other way around. If you have your model with binding expressions, then you're able to _extract_ data from XML like this:

```javascript
el.fromXML(xml); // ⇨ { name: 'John Doe', age: '16' }
```

## Less tedious, please

I hope you can see how this is useful. However, I also hope you can see that this is perhaps not ideal. I mean, it's nice that you're able to build a model of XML, but in many cases, you already have the snippets of XML that you need to populate with data. So, the question is if there is an easier way to achieve the same, if you already have snippets of XML. Perhaps not surprisingly, there is:

```javascript
let template = `<person>
  <name>{{name}}</name>
  <age>{{age}}</age>
</person>`;

let { parse } = require("cruftless")();

el = parse(template);
console.log(el.toXML({ name: "Jane Doe", age: "18" }));
⇒ <person>
⇒   <name>Jane Doe</name>
⇒   <age>18</age>
⇒ </person>
```

## Additional metadata

The example above is rather simple. However, Cruftless allows you also deal with
more complex cases. And not only that, it also allows you to set additional
metadata on binding expressions, using the pipe symbol. In the template below,
we're binding `<person/>` elements inside a `<persons/>` element to a property
`persons`, and we're inserting every occurence of it into the `persons` array.
The processing instruction annotation might be feel a little awkward at first. There are
other ways to define the binding, including one that requires using attributes
of particular namespace. Check the test files for examples.

```javascript
template = parse(`<persons>
  <person><?bind persons|array?>
    <name>{{name|required}}</name>
    <age>{{age|integer|required}}</age>
  </person>
</persons>`);

// Note that because of the 'integer' modifier, integer values are
// now automatically getting transfered from and to strings.

console.log(
  template.toXML({
    persons: [
      { name: "John Doe", age: 16 },
      { name: "Jane Doe", age: 18 },
    ],
  })
);
⇒ <persons>
⇒   <person>
⇒     <name>John Doe</name>
⇒     <age>16</age>
⇒   </person>
⇒   <person>
⇒     <name>Jane Doe</name>
⇒     <age>18</age>
⇒   </person>
⇒ </persons>
```

You can add your own value types to convert from and to the string literals
included in the XML representation.

```javascript
const { element, attr, text, parse } = require("cruftless")({
  types: {
    zeroOrOne: {
      type: "boolean",
      from: (str) => str == "1",
      to: (value) => (value ? "1" : "0"),
    },
  },
});

template = parse(`<foo>{{value|zeroOrOne}})</foo>`);
console.log(template.toXML({ value: true }));
console.log(template.toXML({ value: false }));
⇒ <foo>1</foo>
⇒ <foo>0</foo>
```

The same works with attributes as well:

```javascript
template = parse(`<foo bar="{{value|zeroOrOne}}"/>`);
console.log(template.toXML({ value: true }));
console.log(template.toXML({ value: false }));
⇒ <foo bar="1"/>
⇒ <foo bar="0"/>
```

Sometimes, it's still useful to be able to access the raw field values, ignoring
the type annotations.

To get the actual data:

```javascript
// The second argument defaults to false, so might as well leave it out
console.log(template.fromXML("<foo bar='1'/>", false));
⇒ { value: true }
```

To get the raw data:

```javascript
console.log(template.fromXML("<foo bar='1'/>", true));
⇒ { value: '1' }
```

## Alternative notation

The `<!--persons|array-->` way of annotating an element is not the only way you are able to add metadata. Another way to add metadata to elements is by using one of the reserved attributes prefixed with `c-`.

```javascript
template = parse(`<persons>
  <person c-bind="persons|array">
    <name>{{name|required}}</name>
    <age>{{age|integer|required}}</age>
  </person>
</persons>`);

console.log(
  template.toXML({
    persons: [
      { name: "John Doe", age: 16 },
      { name: "Jane Doe", age: 18 },
    ],
  })
);
⇒ <persons>
⇒   <person>
⇒     <name>John Doe</name>
⇒     <age>16</age>
⇒   </person>
⇒   <person>
⇒     <name>Jane Doe</name>
⇒     <age>18</age>
⇒   </person>
⇒ </persons>
```

If you hate the magic `c-` prefixed attributes, then you can also a slightly
less readable but admittedly more correct XML namespace:

```javascript
template = parse(`<persons>
  <person xmlns:c="https://github.com/wspringer/cruftless" c:bind="persons|array">
    <name>{{name|required}}</name>
    <age>{{age|integer|required}}</age>
  </person>
</persons>`);

console.log(
  template.toXML({
    persons: [
      { name: "John Doe", age: 16 },
      { name: "Jane Doe", age: 18 },
    ],
  })
);
⇒ <persons>
⇒   <person>
⇒     <name>John Doe</name>
⇒     <age>16</age>
⇒   </person>
⇒   <person>
⇒     <name>Jane Doe</name>
⇒     <age>18</age>
⇒   </person>
⇒ </persons>
```

## Conditionals

There may be times when you want to exclude entire sections of an XML structure
if a particular condition is met. Cruftless has some basic support for that,
albeit limited. You can set conditions on elements, using the `c-if` attribute.
In that case, the element will only be included in case the expression of the
`c-if` attribute is evaluating to something else than `undefined` or `null`.

```javascript
template = parse(`<foo><bar c-if="a">text</bar></foo>`);

template.toXML({}); // ⇨ '<foo/>'
template.toXML({ a: null }); // ⇨ '<foo/>'
template.toXML({ a: void 0 }); // ⇨ '<foo/>'
template.toXML({ a: 3 }); // ⇨ '<foo>\r\n  <bar>text</bar>\r\n</foo>'
```

If your template contains variable references, and the data structure you are
passing in does not contain these references, then — instead of generating the
value `undefined`, Cruftless will drop the entire element. In fact, if a deeply
nested element contains references to variable, and that variable is not
defined, then it will not only drop _that_ element, but all elements that
included that element referring to a non-existing variable.

```javascript
template = parse(`<level1>
  <level2 b="{{b}}">
    <level3>{{a}}</level3>
  </level2>
</level1>`);

console.log(template.toXML({ b: 2 }));
⇒ <level1>
⇒   <level2 b="2"/>
⇒ </level1>
```

```javascript
console.log(template.toXML({ b: 2, a: 3 }));
⇒ <level1>
⇒   <level2 b="2">
⇒     <level3>3</level3>
⇒   </level2>
⇒ </level1>
```

```javascript
console.log(template.toXML({ a: 3 }));
⇒ <level1>
⇒   <level2>
⇒     <level3>3</level3>
⇒   </level2>
⇒ </level1>
```

## CDATA

Your XML documents might contain CDATA sections. Cruftless will treat those like
ordinary text nodes. That is, if you have an element that has a text node bound
to a variable, then it will resolve those values regardless of the fact if the
incoming XML document has a text node or a CDATA node.

```javascript
template = parse(`<person>{{name}}</person>`);
console.log(template.fromXML(`<person>Alice</person>`));
⇒ { name: 'Alice' }
```

```javascript
console.log(template.fromXML(`<person><![CDATA[Alice]]></person>`));
⇒ { name: 'Alice' }
```

However, if you would _produce_ XML, then — by default — it will always produce
a text node:

```javascript
console.log(template.toXML({ name: "Alice" }));
⇒ <person>Alice</person>
```

That is, unless you specifiy a `cdata` option in your binding:

```javascript
template = parse(`<person>{{name|cdata}}</person>`);
console.log(template.toXML({ name: "Alice" }));
⇒ <person>
⇒   <![CDATA[Alice]]>
⇒ </person>
```

## JSON-ish Schema (incomplete, subject to change)

Since Cruftless has all of the metadata of your XML document and how it binds to
your data structures at its disposal, it also allows you to generate a 'schema'
of the data structure it expects.

```javascript
let schema = template.descriptor();
console.log(JSON.stringify(schema, null, 2));
⇒ {
⇒   "type": "object",
⇒   "keys": {
⇒     "name": {
⇒       "type": "string"
⇒     }
⇒   }
⇒ }
```

The schema will include additional metadata you attached to expressions:

```javascript
template = parse(`<person>
  <name>{{name|sample:Wilfred}}</name>
  <age>{{age|integer|sample:45}}</age>
</person>`);

schema = template.descriptor();
console.log(JSON.stringify(schema, null, 2));
⇒ {
⇒   "type": "object",
⇒   "keys": {
⇒     "name": {
⇒       "type": "string",
⇒       "sample": "Wilfred"
⇒     },
⇒     "age": {
⇒       "type": "integer",
⇒       "sample": 45
⇒     }
⇒   }
⇒ }
```

## RelaxNG Schema

Since Cruftless captures the structure of the XML document, it's also able to
generate an XML Schema representation of the document structure. Only, it's not
relying on XML Schema. It's using RelaxNG instead. If you never heard of
RelaxNG before: think of it as a more readable better version of XML Schema,
without the craziness.

So based on the template above, this would give you the RelaxNG schema:

```javascript
const { relaxng } = require("cruftless")();

console.log(relaxng(template));
⇒ <grammar datatypeLibrary="http://www.w3.org/2001/XMLSchema-datatypes" xmlns="http://relaxng.org/ns/structure/1.0">
⇒   <start>
⇒     <element name="person">
⇒       <optional>
⇒         <element name="name">
⇒           <data type="string"/>
⇒         </element>
⇒       </optional>
⇒       <optional>
⇒         <element name="age">
⇒           <data type="integer"/>
⇒         </element>
⇒       </optional>
⇒     </element>
⇒   </start>
⇒ </grammar>
```

## Support for xsi:type

XML Schema introduced a kind of polymorphism that many schema designers are a
bit too eager to embrace. Supporting that in Cruftless is not trivial, so
although some level of support exists, be advised it's very limited. Also, be
aware that whatever support for RelaxNG we have, it completely falls apart when
using `xsi:type`.

This is how you use it: suppose that you have a set of students and teachers,
but for students you need a different content model than for teachers. Then you
could model that using `xsi:type`.

```javascript
template = parse(
  `
<people xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <person xsi:type="Student" c-bind="people|array" nickName="{{name}}" grade="{{grade}}" />
  <person xsi:type="Teacher" c-bind="people|array" name="{{name}}" subject="{{subject}}" />
</people>
`.trim()
);

console.log(
  template.fromXML(
    `
<people xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <person xsi:type="Student" nickName="Jesse" grade="D" />
  <person xsi:type="Student" nickName="Badger" grade="C" />
  <person xsi:type="Teacher" name="Walther" subject="chemistry" />
</people>
`.trim()
  )
);
⇒ {
⇒   people: [
⇒     { name: 'Jesse', grade: 'D', kind: 'Student' },
⇒     { name: 'Badger', grade: 'C', kind: 'Student' },
⇒     { name: 'Walther', subject: 'chemistry', kind: 'Teacher' }
⇒   ]
⇒ }
```

In the above case, the `xsi:type` attribute determines the content model of the
data getting parsed. It will pass the value to the `kind` property of the data
extracted. Reversely, it will use the `kind` property to determine how to render
the data as XML.

Now, `xsi:type` values are assumed to `QName`s. That means that there might be a
prefix in the name that resolves to a namespace. The documents that you _parse_
might use different namespace prefixes than the binding template. In order to
avoid issues with that, Cruftless accepts a `prefixes` option specifically for
normalization of the prefixes. So, if your template refers to a type with an
`ns1:` prefix, and the document you are passing is using the `ns0:` prefix, then
you can make sure the types in the documents you are parsing are rewritten to
`ns1`, by the namespace of `ns1` in the configuration options of your Cruftless
instance. (See <https://github.com/wspringer/cruftless/blob/60-xsitype-should-always-be-interpreted-as-a-qname/test/model/xsi-type-test.coffee#L84>.)

**NOTE:** There are [various
issues](https://github.com/wspringer/cruftless/issues/50) with the way RelaxNG
schemas are generated. Consider this to be work in progress.

## Nodeset Capture

There are situations where it makes very little sense to have one template
dictating the structure of the entire document. Typically, in those cases, you
want to slowly peel the entire structure about, starting with the outer envelope
/ container, and then slowly work your way in.

In order to support that, Cruftless offers a solution to capture parts of the
DOM tree as is and store it in a variable to be processed further downstream.
The syntax is not all that different than the bind syntax and might be
harmonized at some point.

This is how you use it:

```javascript
template = parse(`<foo><?capture nodes?></foo>`);
const { nodes } = template.fromXML(`<foo><bar/><bar/></foo>`);
console.log(nodes.length);
console.log(nodes[0].tagName);
⇒ 2
⇒ bar
```

## Rudimentary xinclude support

With cruftless, it often makes sense to break a larger template apart into
smaller ones that can be referenced in various locations. To that end, we're
relying on basic xinclude implementation.

```javascript
resolve = (href) => {
  return ["<bla/>", resolve];
};
template = parse(
  `<foo xmlns:xi="http://www.w3.org/2001/XInclude"><xi:include href="bla.xml"/></foo>`,
  resolve
);
console.log(template.toXML({}));
⇒ <foo>
⇒   <bla/>
⇒ </foo>
```

Note that the resolve function is expected to resolve the href within a context
and then return both the XML _and_ a new resolve function that is capable fo
resolving hrefs from within the context of the resolved file. In this case,
we're not really doing that. In fact, this resolver will **always** return the
same snippet of XML, but it doesn't require a lot of imagination to figure out
how to turn this resolver into something sensible.

If you are not passing the resolve function, then it will simply leave the
xinclude unharmed.

----
Markdown generated from [./README.js.md](./README.js.md) by [![RunMD Logo](http://i.imgur.com/h0FVyzU.png)](https://github.com/broofa/runmd)
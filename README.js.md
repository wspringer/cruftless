```javascript --hide
require('coffeescript/register');
const format = require('xml-formatter');
runmd.onRequire = function(path) {
  if (path === 'cruftless') {
    return './readme.cruftless.coffee';
  }
}
```

# README

An XML builder / parser that tries to ease the common cases, allowing you to quickly build a model from your document structure and get a builder / parser for free.

[![CircleCI](https://circleci.com/gh/wspringer/cruftless.svg?style=svg&circle-token=310415870909bda5fde99f144c9c06cf979abfa9)](https://circleci.com/gh/wspringer/cruftless)

[![Greenkeeper badge](https://badges.greenkeeper.io/wspringer/cruftless.svg)](https://greenkeeper.io/)


## Yet another XML binding framework?

I hate to say this, but: 'yes'. Or, perhaps: 'no'. Because Cruftless is not really an XML binding framework as you know it. It's almost more like Handlebars. But where Handlebars allows you to only *generate* documents, Cruftless also allows you to *extract* data from documents.

## Building XML documents

Cruftless builds a simplified metamodel of your XML document, and it's not based on a DOM API. So, if this is the XML document:

```xml
<person>
  <name>John Doe</name>
  <age>16</age>
</person>
```

Then, using the builder API, Cruftless allows you to *build* a model of your document like this:

```javascript --run simple
const { element, attr, text } = require('cruftless')();

let el = element('person').content(
  element('name').content(
    text().value('John Doe')
  ),
  element('age').content(
    text().value(16)
  )
);
```

… and then to turn it back into XML, you'd use the `toXML()` operation:

```javascript --run simple
el.toXML(); // RESULT
```

… or the `toDOM()` operation instead to return a DOM representation of the document:

```javascript --run simple
el.toDOM();
```

## Binding

Now, this itself doesn't seem all that useful. Where it gets useful is when you start adding references to your document model:

```javascript --run simple
el = element('person').content(
  element('name').content(
    text().bind('name')
  ),
  element('age').content(
    text().bind('age')
  )
);
```

Now, if you want to generate different versions of your XML document for different persons, you can simply pass in an object with `name` and `age` properties:

```javascript --run simple
let xml = el.toXML({ name: 'John Doe', age: '16'}); // RESULT
```

But the beauty is, it also works the other way around. If you have your model with binding expressions, then you're able to *extract* data from XML like this:

```javascript --run simple
el.fromXML(xml); // RESULT
```

## Less tedious, please

I hope you can see how this is useful. However, I also hope you can see that this is perhaps not ideal. I mean, it's nice that you're able to build a model of XML, but in many cases, you already have the snippets of XML that you need to populate with data. So, the question is if there is an easier way to achieve the same, if you already have snippets of XML. Perhaps not surprisingly, there is:

```javascript --run simple
let template = `<person>
  <name>{{name}}</name>
  <age>{{age}}</age>
</person>`

let { parse } = require('cruftless')();

el = parse(template)
console.log(el.toXML({ name: 'Jane Doe', age: '18' }));
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

```javascript --run simple
template = parse(`<persons>
  <person><?bind persons|array?>
    <name>{{name|required}}</name>
    <age>{{age|integer|required}}</age>
  </person>
</persons>`);

// Note that because of the 'integer' modifier, integer values are
// now automatically getting transfered from and to strings.

console.log(template.toXML({ persons: [
  { name: 'John Doe', age: 16 },
  { name: 'Jane Doe', age: 18 }
]}));
```

You can add your own value types to convert from and to the string literals
included in the XML representation.

```javascript --run simple-2
const { element, attr, text, parse } = require('cruftless')({
  types: {
    zeroOrOne: {
      type: 'boolean',
      from: str => str == '1',
      to: value => value ? '1' : '0'
    }
  }
});

template = parse(`<foo>{{value|zeroOrOne}})</foo>`);
console.log(template.toXML({ value: true }));
console.log(template.toXML({ value: false }));
```

Sometimes, it's still useful to be able to access the raw field values, ignoring
the type annotations.

To get the actual data:

```javascript --run simple-2
// The second argument defaults to false, so might as well leave it out
console.log(template.fromXML('<foo>1</foo>', false));
```

To get the raw data:

```javascript --run simple-2
console.log(template.fromXML('<foo>1</foo>', true));
```


## Alternative notation

The `<!--persons|array-->` way of annotating an element is not the only way you are able to add metadata. Another way to add metadata to elements is by using one of the reserved attributes prefixed with `c-`.

```javascript --run simple-2
template = parse(`<persons>
  <person c-bind="persons|array">
    <name>{{name|required}}</name>
    <age>{{age|integer|required}}</age>
  </person>
</persons>`);

console.log(template.toXML({ persons: [
  { name: 'John Doe', age: 16 },
  { name: 'Jane Doe', age: 18 }
]}));
```

If you hate the magic `c-` prefixed attributes, then you can also a slightly
less readable but admittedly more correct XML namespace:

```javascript --run simple-2
template = parse(`<persons>
  <person xmlns:c="https://github.com/wspringer/cruftless" c:bind="persons|array">
    <name>{{name|required}}</name>
    <age>{{age|integer|required}}</age>
  </person>
</persons>`);

console.log(template.toXML({ persons: [
  { name: 'John Doe', age: 16 },
  { name: 'Jane Doe', age: 18 }
]}));
```

## Conditionals

There may be times when you want to exclude entire sections of an XML structure
if a particular condition is met. Cruftless has some basic support for that,
albeit limited. You can set conditions on elements, using the `c-if` attribute.
In that case, the element will only be included in case the expression of the
`c-if` attribute is evaluating to something else than `undefined` or `null`.

```javascript --run simple-2
template = parse(`<foo><bar c-if="a">text</bar></foo>`);

template.toXML({}); // RESULT
template.toXML({ a: null }); // RESULT
template.toXML({ a: void 0 }); // RESULT
template.toXML({ a: 3 }); // RESULT
```

If your template contains variable references, and the data structure you are
passing in does not contain these references, then — instead of generating the
value `undefined`, Cruftless will drop the entire element. In fact, if a deeply
nested element contains references to variable, and that variable is not
defined, then it will not only drop *that* element, but all elements that
included that element referring to a non-existing variable.

```javascript --run simple-2
template = parse(`<level1>
  <level2 b="{{b}}">
    <level3>{{a}}</level3>
  </level2>
</level1>`);

console.log(template.toXML({ b: 2 }));
```

```javascript --run simple-2
console.log(template.toXML({ b: 2, a: 3 }));
```

```javascript --run simple-2
console.log(template.toXML({ a: 3 }));
```

## CDATA

Your XML documents might contain CDATA sections. Cruftless will treat those like
ordinary text nodes. That is, if you have an element that has a text node bound
to a variable, then it will resolve those values regardless of the fact if the
incoming XML document has a text node or a CDATA node.

```javascript --run simple-2
template = parse(`<person>{{name}}</person>`);
console.log(template.fromXML(`<person>Alice</person>`));
```

```javascript --run simple-2
console.log(template.fromXML(`<person><![CDATA[Alice]]></person>`));
```

However, if you would *produce* XML, then — by default — it will always produce
a text node:

```javascript --run simple-2
console.log(template.toXML({ name: 'Alice' }));
```

That is, unless you specifiy a `cdata` option in your binding:

```javascript --run simple-2
template = parse(`<person>{{name|cdata}}</person>`);
console.log(template.toXML({ name: 'Alice' }));
```


## JSON-ish Schema (incomplete, subject to change)

Since Cruftless has all of the metadata of your XML document and how it binds to
your data structures at its disposal, it also allows you to generate a 'schema'
of the data structure it expects.

```javascript --run simple-2
let schema = template.descriptor();
console.log(JSON.stringify(schema, null, 2));
```

The schema will include additional metadata you attached to expressions:

```javascript --run simple-2
template = parse(`<person>
  <name>{{name|sample:Wilfred}}</name>
  <age>{{age|integer|sample:45}}</age>
</person>`);

schema = template.descriptor();
console.log(JSON.stringify(schema, null, 2));
```

## RelaxNG Schema

Since Cruftless captures the structure of the XML document, it's also able to
generate an XML Schema representation of the document structure. Only, it's not
relying on XML Schema. It's using RelaxNG instead. If you never heard of
RelaxNG before: think of it as a more readable better version of XML Schema,
without the craziness.

So based on the template above, this would give you the RelaxNG schema:

```javascript --run simple-2
const { relaxng } = require('cruftless')();

console.log(relaxng(template));
```


<!--
  -- This file is auto-generated from ./README.js.md. Changes should be made there.
  -->

# README

An XML builder / parser that tries to ease the common cases, allowing you to quickly build a model from your document structure and get a builder / parser for free. 

[![CircleCI](https://circleci.com/gh/wspringer/cruftless.svg?style=svg&circle-token=310415870909bda5fde99f144c9c06cf979abfa9)](https://circleci.com/gh/wspringer/cruftless)


## Yet another XML binding framework?

I hate to say this, but: 'yes'. Or, perhaps: 'no'. Because Cruftless is not really an XML binding framework as you know it. It's almost more like Handlebars. But where Handlebars allows you to only *generate* documents, Cruftless also allows you to *parse* documents. 

## Building XML documents

Cruftless builds a simplified metamodel of your XML document, and it's not based on a DOM API. So, if this is the XML document:

```xml
<person>
  <name>John Doe</name>
  <age>16</age>
</person>
```

Then, using the builder API, Cruftless allows you to *build* a model of your document like this:

```javascript
const { element, attr, text } = require('cruftless');

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

```javascript
el.toXML(); // ⇨ '<person><name>John Doe</name><age>16</age></person>'

```

… or the `toDOM()` operation instead to return a DOM representation of the document:

```javascript
el.toDOM(); 

```

## Binding

Now, this itself doesn't seem all that useful. Where it gets useful is when you start adding references to your document model:

```javascript
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

```javascript
let xml = el.toXML({ name: 'John Doe', age: '16'}); // ⇨ '<person><name>John Doe</name><age>16</age></person>'

```

But the beauty is, it also works the other way around. If you have your model with binding expressions, then you're able to *extract* data from XML like this:

```javascript
el.fromXML(xml); // ⇨ { name: 'John Doe', age: '16' }

```

## Less tedious, please

I hope you can see how this is useful. However, I also hope you can see that this is perhaps not ideal. I mean, it's nice that you're able to build a model of XML, but in many cases, you already have the snippets of XML that you need to populate with data. So, the question is if there is an easier way to achieve the same, if you already have snippets of XML. Perhaps not surprisingly, there is:

```javascript
let template = `<person>
  <name>{{name}}</name>
  <age>{{age}}</age>
</person>`

const { parse } = require('cruftless');

el = parse(template)
console.log(el.toXML({ name: 'Jane Doe', age: '18' }));

⇒ <person>
⇒   <name>Jane Doe</name>
⇒   <age>18</age>
⇒ </person>
```

## Additional metadata

The example above is rather simple. However, Cruftless allows you also deal with more complex cases. And not only that, it also allows you to set additional metadata on binding expressions, using the pipe symbol. In the template below, we're binding `<person/>` elements inside a `<persons/>` element to a property `persons`, and we're inserting every occurence of it into the `persons` array. The `<!--…-->` annotation might be feel a little awkward at first. There are other ways to define the binding, including one that requires using attributes of particular namespace. Check the test files for examples.

```javascript
template = parse(`<persons>
  <person><!--persons|array-->
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

⇒ <persons>
⇒   <person>
⇒     <name>John Doe</name>
⇒     <age>16</age>
⇒   </person><person>
⇒     <name>Jane Doe</name>
⇒     <age>18</age>
⇒   </person>
⇒ </persons>
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

console.log(template.toXML({ persons: [
  { name: 'John Doe', age: 16 },
  { name: 'Jane Doe', age: 18 }
]}));

⇒ <persons>
⇒   <person>
⇒     <name>John Doe</name>
⇒     <age>16</age>
⇒   </person><person>
⇒     <name>Jane Doe</name>
⇒     <age>18</age>
⇒   </person>
⇒ </persons>
```

## Conditionals

There may be times when you want to exclude entire sections of an XML structure if a particular condition is met. Cruftless has some basic support for that, albeit limited. You can set conditions on elements, using the `c-if` attribute. In that case, the element will only be included in case the expression of the `c-if` attribute is evaluating to something else than `undefined` or `null`.

```javascript
template = parse(`<foo><bar c-if="a">{{a}}</bar></foo>`);

template.toXML({}); // ⇨ '<foo/>'
template.toXML({ a: 3 }); // ⇨ '<foo><bar>3</bar></foo>'

```

## Schema (incomplete, subject to change)

Since Cruftless has all of the metadata of your XML document and how it binds to your data structures at its disposal, it also allows you to generate a 'schema' of the data structure it expects. 
  
```javascript
let schema = template.describe();
console.log(JSON.stringify(schema, null, 2));

⇒ {
⇒   "type": "object",
⇒   "keys": {
⇒     "a": {
⇒       "type": "string"
⇒     }
⇒   }
⇒ }
```  




----
Markdown generated from [./README.js.md](README.js.md) by [![RunMD Logo](http://i.imgur.com/h0FVyzU.png)](https://github.com/broofa/runmd)
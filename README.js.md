```javascript --hide
require('coffeescript/register');
runmd.onRequire = function(path) {
  if (path === 'cruftless') {
    return './src/index.coffee';
  }
}
```

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

```javascript --run simple
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

const { parse } = require('cruftless');

el = parse(template)
console.log(el.toXML({ name: 'Jane Doe', age: '18' }));
```

## Additional metadata

The example above is rather simple. However, Cruftless allows you also deal with more complex cases. And not only that, it also allows you to set additional metadata on binding expressions, using the pipe symbol.

```javascript --run simple
template = `<persons>
  <person c-bind="persons|array">
    <name>{{name|required}}</name>
    <age>{{age|integer|required}}</age>
  </person>
</persons>`;

// Note that because of the 'integer' modifier, integer values are 
// now automatically getting transfered from and to strings.

console.log(parse(template).toXML({ persons: [
  { name: 'John Doe', age: 16 },
  { name: 'Jane Doe', age: 18 }
]}));
```
  
  




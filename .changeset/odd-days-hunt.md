---
"cruftless": minor
---

Support for a simpler way to map arrays of non-object values.

Instead of binding as `array`, we're binding as values. With `array`, every encounter of the element results in a new _object_ getting added to the array. With `values`, we're not adding any values yet. However, if inside, we encounter something that is bound to `value`, it will be added to the array as simple value.

Perhaps this example makes it easier to grasp:

```javascript
const template = parse(
  `<foo><bar c-bind="numbers|values">{{value|integer}}</bar></foo>`
);
const data = template.fromXML(`<foo><bar>1</bar><bar>2</bar></foo>`);
// { numbers: [ 1, 2 ] }
```

Instead of this:

```javascript
const template = parse(
  `<foo><bar c-bind="numbers|array">{{value|integer}}</bar></foo>`
);
const data = template.fromXML(`<foo><bar>1</bar><bar>2</bar></foo>`);
// { numbers: [ { value: 1 }, { value: 2 } ] }
```

Note that we currently consider this feature to be unstable. You _can_ use it, but be advised that the notation might change in the future.

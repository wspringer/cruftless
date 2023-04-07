declare module "cruftless" {
  export type CruftlessTypes = Record<string, CruftlessType<any>>;

  /**
   * For primitives, you can register type definitions that are able to convert
   * between the encoded representation and the data representation used in the
   * data model.
   */
  export interface CruftlessType<T> {
    /**
     * How the type is referenced in your template.
     */
    type: string;
    /**
     * How the type converted from its encoded representation to in memory representation.
     */
    from: (str: string) => T;
    /**
     * How it's converted from the in-memory representation to its XML representation.
     */
    to: (value: T) => string;
    /**
     * A snippet of RelaxNG describing the type.
     */
    relaxng: (...args: any[]) => Template<unknown>;
  }
  export interface CruftlessOpts {
    types: CruftlessTypes;
  }

  export interface Cruftless {
    parse: ParseFn;
    element: ElementFn;
    attr: AttrFn;
    relaxng: RelaxNGFn;
    text: TextFn;
  }

  export interface Template<T> {
    toXML: (...args: any[]) => string;
    fromXML: (xml: string, raw?: boolean) => T;
    toDOM: (...args: any[]) => Document;
    fromDOM: (dom: Document, raw?: boolean) => T;
    name: () => string;
  }

  export type ParseFn = <T>(xml: string, resolve?: ResolveFn) => Template<T>;
  export type ElementFn = (name: string) => Element;
  export type AttrFn = (name: string) => Attr;
  export type RelaxNGFn = <T>(template: Template<T>, ...args: any[]) => string;
  export type TextFn = () => Text;
  export type ResolveFn = (href: string) => [string, ResolveFn];

  export type Element = any;
  export type Attr = any;
  export type Text = any;

  function cruftless(opts: CruftlessOpts): Cruftless;

  export default cruftless;
}

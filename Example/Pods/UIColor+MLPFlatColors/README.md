UIColor+MLPFlatColors
================

> Although the _UIColor_ class comes with built in convenience methods for producing standard colors, most of these colors are too bright and gaudy for any real use other than prototyping. So, here's a category for _UIColor_ that adds 20 new colors that developers may actually want to use in a real app, based off the current trend of flat UI color schemes. It's called _UIColor+MLPFlatColors_. 

![Screenshot](/colorsDemo.png "Screenshot")


About
---------
_UIColor+MLPFlatColors_ is a category for _UIColor_ that adds 20 new class methods that produce colors designed for flat interface designs. It also adds some methods for choosing a random color out of these 20 new colors, and a macro for converting hex values to an RGB color. 

Usage
---------
Add the _UIColor+MLPFlatColors_ header and implementation file to your project. (.h & .m)

After doing that, you'll be able to produce flat colors by calling the class methods defined in the _MLPFlatColors_ category. Each flat color method is prefixed with the word "flat" for easy recognition in Xcode's code complete.

You can also produce random flat colors with these methods:

`+ (UIColor *)randomFlatColor;`
`+ (UIColor *)randomFlatLightColor;`
`+ (UIColor *)randomFlatDarkColor;`

License
--------
_UIColor+MLPFlatColors_ uses the MIT License:

>Copyright (c) 2013, Mainloop LLC

>Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

>The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

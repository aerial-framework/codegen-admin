/*
This library (com.betabong.xml.e4x) is licenced under the MIT License

Copyright (c) 2008 Severin Klaus, www.betabong.com | blog.betabong.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

package com.betabong.xml.e4x
{
	public class E4X
	{

		static protected var patterns : Object = {};
		
		static public function evaluate( source : * , expression : String ) : XMLList {
			var selector : E4XSelectorPath;
			
			if(source is XML || source is String)
				source = new XMLList(source);
			
			if ( !Boolean( selector = patterns[ expression ] ) ) {
				patterns[ expression ] = selector = new E4XSelectorPath( expression );
			}
			return selector.select( source );
		}
		
		

	}
}
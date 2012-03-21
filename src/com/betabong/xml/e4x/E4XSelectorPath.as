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
	import com.betabong.xml.e4x.compare.E4XEquals;
	
	public class E4XSelectorPath
	{
		private var path : Array;
		private var _expression : String;
		
		public function E4XSelectorPath( expression : String = null)
		{
			this.expression = expression;
		}
		
		
		public function select( source : XMLList ) : XMLList {
			var result : XMLList = source;
			for each ( var elem : IE4XSelectorElement in path ) {
				result = elem.select( result );
			}
			return result;
		}
		
		public function set expression( value : String ) : void {
			if ( value != _expression ) {
				_expression = value;
				path = parse( _expression );
			}
		}
		
		public function get expression() : String {
			return _expression;
		}
		
		protected function parse( expression : String ) : Array {
			if ( !Boolean( expression ) ) {
				return null;
			}
			
			var s : String = expression;
			
			// the following is from E4XParser (that's why is so nicely documented ;)
			
			//Handle any quoted strings after the @ by removing the quotes and brackets, not needed now
			s = s.replace(quotedAttrib, "$1$2" );

			//Handle any quoted strings inside of brackets and replace with a .
			s = s.replace(quotedBrackets, ".$1" );
			
			//Remove the remaining brackets and replace with a .
			s = s.replace(brackets, ".$1" );

			//We replace the descendant character with double underscores
			s = s.replace( descendant, ".__" );

			
			expression = s;

			var result : Array = [];
			var items : Array = getItems( expression );
			var elem : IE4XSelectorElement;
			var firstChar : String, lastChar : String;
			var pos : int , num : Number;
			
			for each ( var item : String in items ) {
				firstChar = item.charAt(0);
				lastChar = item.charAt( item.length - 1 );
				if ( firstChar == '@' ) {
					item = item.substr(1);
					result.push( new E4XAttributeElement( item ) );
				}
				else
				if ( firstChar == '(' && lastChar == ')' ) {
					item = item.substr( 1 , item.length - 2 );
					result.push( new E4XCompareElement( item ) );
				}
				else
				if ( ( pos = item.indexOf( '(' ) ) >= 0 && lastChar == ')' ) {
					var functionName : String = item.substring( 0 , pos );
					var parameter : String = item.substring( pos + 1 , item.length - 1 );
					result.push( new E4XFunctionElement( functionName , parameter ) );
				} else
				if ( item.indexOf('__') == 0 ) {
					result.push( new E4XDescendantElement( item.substr(2) ) );
				} 
				else 
				if ( !isNaN( num = Number( item ) ) ) {
					result.push( new E4XPositionElement( num ) );
				}
				else
				{
					result.push( new E4XChildElement( item ) );
				}
			}
			return result;
		}
		
		protected function getItems( expression : String ) : Array {
			return E4XUtil.splitIgnoringBrackets( expression , '.' , '(' , ')' );
		}




		// the following is from E4XParser
		static public var quotedAttrib:RegExp = /(@)\["*(\w+)"*\]/g;
		static public var quotedBrackets:RegExp = /\["*(\w+)"*\]/g;
		static public var brackets:RegExp = /\[(.+)\]/g;
		static public var descendant:RegExp = /\.\./g;
		static public var dotsInPredicate:RegExp = /(\([^\)]+)(\.)([^\)\.]+\))/g;
	}
}
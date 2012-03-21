package com.betabong.xml.e4x
{
	import flash.utils.Dictionary;
	
	public class E4XFunctionElement implements IE4XSelectorElement
	{
		protected var functionMap : Object;
		protected var selectFunction : Function;
		protected var functionName : String;
		protected var functionValue : E4XValue;
		protected var expression : String; // just for debugging
		
		public function E4XFunctionElement( name : String , parameter : String )
		{
			functionName = name;
			functionValue = new E4XValue( parameter );
			expression = functionName + '(' + parameter + ')';
			
			if ( functionMap == null ) {
				functionMap = {
					attribute: attribute ,
					attributes: attributes ,
					average: average ,
					child: child ,
					children: children ,
					childIndex: childIndex ,
					comments: comments ,
					descendants: descendants ,
					elements: elements ,
					format: format ,
					length: f_length ,
					localName: localName ,
					name: f_name ,
					nodeKind: nodeKind ,
					parent: parent ,
					processingInstructions: processingInstructions ,
					sum: sum ,
					text: f_text ,
					toLowerCase: toLowerCase ,
					toString: f_toString ,
					toUpperCase: toUpperCase ,
					toXMLString: toXMLString
				};
			}
			
			selectFunction = functionMap[ functionName ];
			if ( selectFunction == null ) {
				selectFunction = unknown;
			}
		}

		public function select(input:XMLList):XMLList
		{
			var result : * = selectFunction( input );
			return result is XMLList ? result : XMLList( result );
		}
		
		
		// standard functions on XMLList:
		
		protected function descendants( input : XMLList ) : XMLList {
			var value : String = functionValue.evaluate(input);
			return value 
				? input.descendants( String(value) ) 
				: input.descendants();
		}
		
		protected function children( input : XMLList ) : XMLList {
			return input.children();
		}
		
		protected function child( input : XMLList ) : XMLList {
			return input.child( String( functionValue.evaluate(input) ) );
		}
		
		protected function attributes( input : XMLList ) : XMLList {
			return input.attributes();
		}
		
		protected function attribute( input : XMLList ) : XMLList {
			return input.attribute( String( functionValue.evaluate(input) ) );
		}
		
		protected function comments( input : XMLList ) : XMLList {
			return input.comments();
		}
		
		protected function elements( input : XMLList ) : int {
			var value : String = functionValue.evaluate(input);
			return value 
				? input.elements( String(value) ) 
				: input.elements();
		}

		protected function processingInstructions( input : XMLList ) : XMLList {
			var value : String = functionValue.evaluate(input);
			return value 
				? input.processingInstructions( String(value) ) 
				: input.processingInstructions();
		}
		
		protected function f_text( input : XMLList ) : XMLList {
			return input.text();
		}

		protected function f_toString( input : XMLList ) : XML {
			return XML("<![CDATA" + "[" + input.toString() + "]" + "]>");
		}

		protected function toXMLString( input : XMLList ) : XML {
			return XML("<![CDATA" + "[" + input.toXMLString() + "]" + "]>");
		}

		protected function unknown( input : XMLList ) : void {
			return;
		}
		
		protected function f_length( input : XMLList ) : int {
			return input.length();
		}

		
		// the following functions are not strictly xmllist functions
		// so we collect them by ourself, and normalize them too
		
		protected function childIndex( input : XMLList ) : XMLList {
			var list : XMLList = <></>;
			for each ( var node : XML in input ) {
				list += XMLList( node.childIndex() );
			}
			return list;
		}

		protected function f_name( input : XMLList ) : XMLList {
			return normalizeLoop( input , xml_name );
		}
		protected function xml_name( input : XML ) : String {
			return input.name();
		}
		
		protected function localName( input : XMLList ) : XMLList {
			return normalizeLoop( input , xml_localName );
		}
		protected function xml_localName( input : XML ) : String {
			return input.localName();
		}
		
		protected function nodeKind( input : XMLList ) : XMLList {
			return normalizeLoop( input , xml_nodeKind );
		}
		protected function xml_nodeKind( input : XML ) : String {
			return input.nodeKind();
		}
		
		protected function parent( input : XMLList ) : XMLList {
			// parent is only valid for children with same parent - so we do our own parent normalizing
			return normalizeLoop( input , xml_parent );
		}
		protected function xml_parent( input : XML ) : XML {
			return input.parent();
		}
		
		
		// now for some proprietary functions - most people will ignore.. :)
		
		protected function toUpperCase( input : XMLList ) : XMLList {
			return valueList( input , value_toUpperCase );
		}
		protected function value_toUpperCase( input : XML ) : String {
			return String( input ).toUpperCase();
		}
		protected function toLowerCase( input : XMLList ) : XMLList {
			return valueList( input , value_toLowerCase );
		}
		protected function value_toLowerCase( input : XML ) : String {
			return String( input ).toLowerCase();
		}
		protected function sum( input : XMLList ) : Number {
			var number : Number;
			var result : Number = 0;
			for each ( var node : XML in input ) {
				number = Number( node );
				if ( !isNaN(number) ) {
					result += number;
				}
			}
			return result;
		}
		
		protected function average( input : XMLList ) : Number {
			return sum( input ) / input.length();
		}

		// this one is a bit special - needed for a project
		protected function format( input : XMLList ) : XMLList {
			return valueList( input , value_format );
		}
		protected function value_format( input : XML ) : String {
			var type : String = functionValue.evaluate( null ); // we go for string values only
			switch ( type ) {
				case 'currency':
				default:
					var number : Number = Number( input );
					if ( isNaN( number ) ) {
						return '0';
					} else {
						var rounded : Number = Math.floor( number );
						var digits : Number = number - rounded;
						var digits_string : String = String( Math.round( digits * 100 ) );
						while ( digits_string.length < 2 ) digits_string += '0';
						return rounded + ( digits > 0 ? '.' + digits_string : '' );
					}
					break;
			}
			return '';
		}

		
		// normalizing
		
		private function normalizeLoop( input : XMLList , filter : Function ) : XMLList {
			var objects : Dictionary = new Dictionary();
			var object : XML , node : XML;
			for each ( node in input ) {
				object = filter( node );
				if ( object ) {
					objects[ object ] = object;
				}
			}
			var list : XMLList = <></>;
			for each ( object in objects ) {
				list += object;
			}
			return list;
		}

		// create value list
		
		private function valueList( input : XMLList , process : Function ) : XMLList {
			var list : XMLList = <></>;
			var result : String;
			for each ( var node : XML in input ) {
				result = String( process(node) );
				list += XML( result );
			}
			return list;
		}
		
	}
}
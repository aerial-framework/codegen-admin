package com.betabong.xml.e4x
{
	public class E4XValue implements IE4XSelectorElement
	{
		static protected const STRING_TYPE : int = 0;
		static protected const NUMBER_TYPE : int = 1;
		static protected const SELECTOR_TYPE : int = 2;
		static protected const NULL_TYPE : int = -1;
		
		protected var valueNumber : Number;
		protected var valueString : String;
		protected var valueSelector : E4XSelectorPath;
		protected var type : int;
		protected var expression : String;
		
		public function E4XValue( expression : String )
		{
				parseValue( expression );
		}

		public function select(input:XMLList):XMLList
		{
			return XMLList( evaluate( input ) );
		}
		
		public function evaluate( input: XMLList ) : * {
			switch ( type ) {
				case STRING_TYPE:
					return valueString;
					break
				case NUMBER_TYPE:
					return valueNumber;
					break;
				case SELECTOR_TYPE:
					return valueSelector.select( input );
					break;
			}
			return null;
		}
		
		private function parseValue( value : String ) : void {
			expression = value;
			value = trim( value );
			if ( !Boolean( value ) ) {
				type = NULL_TYPE;
			} else
			if ( value.charAt(0) == '"' || value.charAt(0) == "'" ) {
				valueString = value.substr( 1 , value.length - 2 );
				type = STRING_TYPE;
				
			} else {
				var number : Number = Number( value );
				if ( !isNaN( number ) ) {
					valueNumber = number;
					type = NUMBER_TYPE;
				} else {
					valueSelector = new E4XSelectorPath( value );
					type = SELECTOR_TYPE;
				}
			}
		}
		
	    private function trim(str:String):String
	    {
	        if (str == null) return '';
	        
	        var startIndex:int = 0;
	        while ( str.charAt(startIndex) == ' ' )
	            ++startIndex;
	
	        var endIndex:int = str.length - 1;
	        while ( str.charAt(endIndex) == ' ' )
	            --endIndex;
	
	        if (endIndex >= startIndex)
	            return str.slice(startIndex, endIndex + 1);
	        else
	            return "";
	    }

	}
}
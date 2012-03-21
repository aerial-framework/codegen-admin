package com.betabong.xml.e4x
{
	import com.betabong.xml.e4x.compare.*;
	
	public class E4XCompareElement implements IE4XSelectorElement
	{
		private var comparision : IE4XComparision;
		
		public function E4XCompareElement( expression : String )
		{
			var check : String = E4XUtil.ignoreBrackets( expression , '(' , ')' );
			
			if ( check.indexOf('==') >= 1 ) {
				comparision = new E4XEquals( expression );
			}
			else
			if ( check.indexOf('!=') >= 1 ) {
				comparision = new E4XNotEqual( expression );
			}
			else
			if ( check.indexOf('>=') >= 1 ) {
				comparision = new E4XLargerEqual( expression );
			}
			else
			if ( check.indexOf('<=') >= 1 ) {
				comparision = new E4XSmallerEqual( expression );
			}
			else
			if ( check.indexOf('>') >= 1 ) {
				comparision = new E4XLargerThan( expression );
			}
			else
			if ( check.indexOf('<') >= 1 ) {
				comparision = new E4XSmallerThan( expression );
			}
		}

		public function select(input:XMLList):XMLList
		{
			var result : XMLList = <></>;
			for each ( var node : XML in input ) {
				if ( comparision.evaluate( XMLList( node ) ) ) {
					result += node;
				}
			}
			return result;
		}
		
	}
}
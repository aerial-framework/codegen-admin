package com.betabong.xml.e4x.compare
{
	public class E4XLargerEqual extends E4XAbstractComparision
	{
		function E4XLargerEqual( expression : String ) {
			super( expression );
		}
		
		override protected function evaluateValues(value1:*, value2:*):Boolean {
			return value1 >= value2;
		}
		
		override protected function get delimiter():String {
			return '>=';
		}

	}
}
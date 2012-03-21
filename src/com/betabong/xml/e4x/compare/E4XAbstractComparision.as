
package com.betabong.xml.e4x.compare
{
	import com.betabong.xml.e4x.E4XSelectorPath;
	import com.betabong.xml.e4x.E4XUtil;
	import com.betabong.xml.e4x.E4XValue;
	
	
	internal class E4XAbstractComparision implements IE4XComparision
	{
		protected var left : E4XValue;
		protected var right : E4XValue;
		
		public function E4XAbstractComparision( expression : String )
		{
			parse( expression );
		}
		
		public function evaluate(input:XMLList):Boolean
		{
			// left and right can be of type String, Number or E4XSelectorPath
			// if the latter is the case, we have to evaluate it
			return evaluateValues( left.evaluate(input) , right.evaluate(input) );
		}
		
		private function parse( expression : String ) : void {
			var split : Array = E4XUtil.splitIgnoringBrackets( expression , delimiter , '(' , ')' );
			var leftExpression : String = split[0];
			var rightExpression : String = split[1];
			left = new E4XValue( leftExpression );
			right = new E4XValue( rightExpression );
		}



		// sub classes have to overwrite these:
		
		
		protected function get delimiter() : String {
			return null;
		}
		protected function set delimiter( value : String ) : void {}

		protected function evaluateValues( value1 : * , value2 : * ) : Boolean {
			return false;
		}
		
	}
}
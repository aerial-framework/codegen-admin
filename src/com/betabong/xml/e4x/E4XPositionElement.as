package com.betabong.xml.e4x
{
	public class E4XPositionElement implements IE4XSelectorElement
	{
		private var position : Number;
		
		public function E4XPositionElement( position : Number )
		{
			this.position = position;
		}

		public function select(input:XMLList):XMLList
		{
			return isNaN( position) ? <></> : XMLList( input[ int(position) ] );
		}
		
	}
}
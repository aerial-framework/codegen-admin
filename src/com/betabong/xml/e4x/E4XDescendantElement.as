package com.betabong.xml.e4x
{
	public class E4XDescendantElement implements IE4XSelectorElement
	{
		private var nodeName : String;
		
		public function E4XDescendantElement( name : String = null )
		{
			nodeName = name;
		}

		public function select(input:XMLList):XMLList
		{
			return nodeName == null ? input.descendants() : input.descendants( nodeName );
		}
		
	}
}
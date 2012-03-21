package com.betabong.xml.e4x
{
	public class E4XChildElement implements IE4XSelectorElement
	{
		public var nodeName : String;
		
		public function E4XChildElement( name : String )
		{
			nodeName = name;
		}

		public function select(input:XMLList):XMLList
		{
			return nodeName == null ? input.elements() : input.elements( nodeName );
		}
		
	}
}
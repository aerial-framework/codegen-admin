package com.betabong.xml.e4x
{
	public class E4XAttributeElement implements IE4XSelectorElement
	{
		public var attributeName : String;
		
		public function E4XAttributeElement( name : String )
		{
			attributeName = name;
		}

		public function select(input:XMLList):XMLList
		{
			return input.attribute( attributeName );
		}
		
	}
}
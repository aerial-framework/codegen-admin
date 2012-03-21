package com.betabong.xml.e4x
{
	
	public class E4XUtil
	{
		static public function splitIgnoringBrackets( expression : String , delimiter : String = '.' , leftBracket : String = '(' , rightBracket : String = ')' ) : Array {
			var result : Array = [];
			var posDelimiter : int;
			var posBracketLeft : int;
			var posBracketRight : int;
			var bracketLevel : int;
			var bracketCursor : int;
			var cursor : int = 0;
			var valueCursor : int = 0;
			var len : int = expression.length;
			var delimiterLength : int = delimiter.length;
			while ( cursor < len ) {
				posDelimiter = expression.indexOf( delimiter , cursor );
				posBracketLeft = expression.indexOf( leftBracket , cursor );
				if ( posDelimiter == -1 ) {
					 // no point found: schwuppdiwupp
					cursor = len;
				} else
				if ( posDelimiter < posBracketLeft || posBracketLeft == -1 ) {
					// we found delimiter - let's split
					result.push( expression.substring( valueCursor , posDelimiter ) );
					valueCursor = cursor = posDelimiter + delimiterLength;
				} else
				{
					// so we found a left bracket - let's move on until it's closed
					bracketLevel = 1;
					bracketCursor = posBracketLeft + 1;
					while ( bracketLevel > 0 ) {
						posBracketLeft = expression.indexOf( leftBracket , bracketCursor );
						posBracketRight = expression.indexOf( rightBracket , bracketCursor );
						if ( posBracketRight == -1 ) {
							// neither closing nor opening bracket found - both are -1
							throw new Error( 'E4X Paring: missing closing bracket' );
						}
						if ( posBracketLeft < posBracketRight && posBracketLeft != -1 ) {
							bracketLevel++;
							bracketCursor = posBracketLeft + 1;
						} else {
							bracketLevel--;
							bracketCursor = posBracketRight + 1;
						}
					}
					cursor = bracketCursor;
				}
			}
			if ( valueCursor < len ) {
				// add last item if available
				result.push( expression.substr( valueCursor ) );
			}
			return result;
			
		}

		static public function ignoreBrackets( expression : String , leftBracket : String = '(' , rightBracket : String = ')' ) : String {
			var result : String = '';
			var posBracketLeft : int;
			var posBracketRight : int;
			var bracketLevel : int;
			var bracketCursor : int;
			var cursor : int = 0;
			var len : int = expression.length;
			while ( cursor < len ) {
				posBracketLeft = expression.indexOf( leftBracket , cursor );
				if ( posBracketLeft == -1 ) {
					break;
				}
				result += ( expression.substring( cursor , posBracketLeft ) );
				
				// so we found a left bracket - let's move on until it's closed
				bracketLevel = 1;
				bracketCursor = posBracketLeft + 1;
				while ( bracketLevel > 0 ) {
					posBracketLeft = expression.indexOf( leftBracket , bracketCursor );
					posBracketRight = expression.indexOf( rightBracket , bracketCursor );
					if ( posBracketRight == -1 ) {
						// neither closing nor opening bracket found - both are -1
						throw new Error( 'E4X Paring: missing closing bracket' );
					}
					if ( posBracketLeft < posBracketRight && posBracketLeft != -1 ) {
						bracketLevel++;
						bracketCursor = posBracketLeft + 1;
					} else {
						bracketLevel--;
						bracketCursor = posBracketRight + 1;
					}
				}
				cursor = bracketCursor;
			}
			if ( cursor < len ) {
				// add last item if available
				result += ( expression.substr( cursor ) );
			}
			return result;
			
		}
	}
}
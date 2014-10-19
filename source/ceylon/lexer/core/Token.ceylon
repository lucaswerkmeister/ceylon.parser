"A single token, that is,
 a fragment of code with a certain [[type]].
 
 For most token types, the [[type]] determines the [[text]];
 only the following token types can have varying text:
 - identifiers:
     - [[lidentifier]]
     - [[uidentifier]]
 - literals:
     - [[decimalLiteral]]
     - [[hexLiteral]]
     - [[binaryLiteral]]
     - [[floatLiteral]]
     - [[stringLiteral]]
     - [[verbatimStringLiteral]]
     - [[stringStart]]
     - [[stringMid]]
     - [[stringEnd]]
 - ignored:
     - [[whitespace]]
     - [[lineComment]]
     - [[multiComment]]"
shared class Token(type, text) {
    shared TokenType type;
    shared String text;
    
    shared actual String string {
        Boolean verbatimQuoteText;
        if (type == lidentifier || type == uidentifier) {
            verbatimQuoteText = text.startsWith("\\");
        } else { // TODO literal tokens
            verbatimQuoteText = false;
        }
        value quotes = verbatimQuoteText
                then "\"\"\""
                else "\"";
        return "Token(``type``, ``quotes````text````quotes``)";
    }
    
    shared actual Boolean equals(Object that) {
        if (is Token that) {
            return type == that.type &&
                    text == that.text;
        } else {
            return false;
        }
    }
    
    shared actual Integer hash
            => 31 * (type.hash + 31 * text.hash);
}

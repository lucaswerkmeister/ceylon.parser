shared abstract class TokenType(string)
        of IgnoredType | IdentifierType | LiteralType {
    shared actual String string;
}

"An ignored token that’s not visible to the parser."
shared abstract class IgnoredType(String string)
        of whitespace | lineComment | multiComment
        extends TokenType(string) {}

"Whitespace."
shared object whitespace extends IgnoredType("whitespace") {}

"A single-line comment, for example:
 
     // comment
     #!/usr/bin/ceylon"
shared object lineComment extends IgnoredType("lineComment") {}

"A multi-line comment, for example:
 
     /*
      * comment
      */
     
     /* doesn’t actually have to be multi-line */
     
     /* can /* be */ nested */"
shared object multiComment extends IgnoredType("multiComment") {}

"""An identifier (with optional prefix), for example:
   
       Anything
       \iSOUTH"""
shared abstract class IdentifierType(String string)
        of lidentifier | uidentifier
        extends TokenType(string) {}

"""An initial lowercase identifier (with optional prefix), for example:
   
       null
       \iSOUTH"""
shared object lidentifier extends IdentifierType("lidentifier") {}

"""An initial uppercase identifier (with optional prefix), for example:
   
       Object
       \Iklass"""
shared object uidentifier extends IdentifierType("uidentifier") {}

"A literal value token."
shared abstract class LiteralType(String string)
        of StringLiteralType | characterLiteral | NumericLiteralType
        extends TokenType(string) {}

shared abstract class StringLiteralType(String string)
        of stringLiteral | verbatimStringLiteral | stringStart | stringMid | stringEnd
        extends LiteralType(string) {}

"""A regular string literal, for example:
   
       "Hello, World!"
       "The Ceylon mascot is Trompon the \{ELEPHANT}.""""
shared object stringLiteral extends StringLiteralType("stringLiteral") {}

"A verbatim string literal without escape sequences, for example:
 
     \"\"\"He said, \"Hello, World!\"\"\"\""
shared object verbatimStringLiteral extends StringLiteralType("verbatimStringLiteral") {}

"""A string literal that occurs at the beginning of a string template,
   i. e. ends with two backticks instead of a quote, for example:
   
       "Hello, ``"""
shared object stringStart extends StringLiteralType("stringStart") {}

"""A string literal that occurs in the middle of a string template,
   i. e. begins and ends with two backticks instead of a quote, for example:
   
       ``, and welcome to ``"""
shared object stringMid extends StringLiteralType("stringMid") {}

"""A string literal that occurs at the end of a string template,
   i. e. begins with two backticks instead of a quote, for example:
   
       ``!""""
shared object stringEnd extends StringLiteralType("stringEnd") {}

"A character literal, for example:
 
     'c'
     '\\{LATIN SMALL LETTER C}'"
shared object characterLiteral extends LiteralType("characterLiteral") {}

"A numeric literal."
shared abstract class NumericLiteralType(String string)
// TODO case types
        extends LiteralType(string) {}

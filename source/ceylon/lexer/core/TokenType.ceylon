shared abstract class TokenType(string)
        of IgnoredType | IdentifierType | LiteralType | KeywordType {
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
        of IntegerLiteralType | floatLiteral
        extends LiteralType(string) {}

"An integer literal."
shared abstract class IntegerLiteralType(String string)
        of decimalLiteral | hexLiteral | binaryLiteral
        extends NumericLiteralType(string) {}

"A decimal integer literal, with an optional magnitude, for example:
 
     10_000
     10k"
shared object decimalLiteral extends IntegerLiteralType("decimalLiteral") {}

"A hexadecimal integer literal, for example:
 
     #10_FFFF"
shared object hexLiteral extends IntegerLiteralType("hexLiteral") {}

"A binary integer literal, for example:
 
     $101010"
shared object binaryLiteral extends IntegerLiteralType("binaryLiteral") {}

"A floating point literal, for example:
 
     1.5
     10u
     6.022E23"
shared object floatLiteral extends NumericLiteralType("floatLiteral") {}

"A keyword."
shared abstract class KeywordType(String string)
        of assemblyKw | moduleKw | packageKw | importKw | aliasKw | classKw |
        interfaceKw | objectKw | givenKw | valueKw | assignKw | voidKw |
        functionKw | newKw | ofKw | extendsKw | satisfiesKw | abstractsKw |
        inKw | outKw | returnKw | breakKw | continueKw | throwKw | assertKw |
        dynamicKw | ifKw | elseKw | switchKw | caseKw | forKw | whileKw |
        tryKw | catchKw | finallyKw | thenKw | letKw |
        thisKw | outerKw | superKw | isKw | existsKw | nonemptyKw
        extends TokenType(string) {}

"The ‘`assembly`’ keyword."
shared object assemblyKw extends KeywordType("assemblyKw") {}

"The ‘`module`’ keyword."
shared object moduleKw extends KeywordType("moduleKw") {}

"The ‘`package`’ keyword."
shared object packageKw extends KeywordType("packageKw") {}

"The ‘`import`’ keyword."
shared object importKw extends KeywordType("importKw") {}

"The ‘`alias`’ keyword."
shared object aliasKw extends KeywordType("aliasKw") {}

"The ‘`class`’ keyword."
shared object classKw extends KeywordType("classKw") {}

"The ‘`interface`’ keyword."
shared object interfaceKw extends KeywordType("interfaceKw") {}

"The ‘`object`’ keyword."
shared object objectKw extends KeywordType("objectKw") {}

"The ‘`given`’ keyword."
shared object givenKw extends KeywordType("givenKw") {}

"The ‘`value`’ keyword."
shared object valueKw extends KeywordType("valueKw") {}

"The ‘`assign`’ keyword."
shared object assignKw extends KeywordType("assignKw") {}

"The ‘`void`’ keyword."
shared object voidKw extends KeywordType("voidKw") {}

"The ‘`function`’ keyword."
shared object functionKw extends KeywordType("functionKw") {}

"The ‘`new`’ keyword."
shared object newKw extends KeywordType("newKw") {}

"The ‘`of`’ keyword."
shared object ofKw extends KeywordType("ofKw") {}

"The ‘`extends`’ keyword."
shared object extendsKw extends KeywordType("extendsKw") {}

"The ‘`satisfies`’ keyword."
shared object satisfiesKw extends KeywordType("satisfiesKw") {}

"The ‘`abstracts`’ keyword."
shared object abstractsKw extends KeywordType("abstractsKw") {}

"The ‘`in`’ keyword."
shared object inKw extends KeywordType("inKw") {}

"The ‘`out`’ keyword."
shared object outKw extends KeywordType("outKw") {}

"The ‘`return`’ keyword."
shared object returnKw extends KeywordType("returnKw") {}

"The ‘`break`’ keyword."
shared object breakKw extends KeywordType("breakKw") {}

"The ‘`continue`’ keyword."
shared object continueKw extends KeywordType("continueKw") {}

"The ‘`throw`’ keyword."
shared object throwKw extends KeywordType("throwKw") {}

"The ‘`assert`’ keyword."
shared object assertKw extends KeywordType("assertKw") {}

"The ‘`dynamic`’ keyword."
shared object dynamicKw extends KeywordType("dynamicKw") {}

"The ‘`if`’ keyword."
shared object ifKw extends KeywordType("ifKw") {}

"The ‘`else`’ keyword."
shared object elseKw extends KeywordType("elseKw") {}

"The ‘`switch`’ keyword."
shared object switchKw extends KeywordType("switchKw") {}

"The ‘`case`’ keyword."
shared object caseKw extends KeywordType("caseKw") {}

"The ‘`for`’ keyword."
shared object forKw extends KeywordType("forKw") {}

"The ‘`while`’ keyword."
shared object whileKw extends KeywordType("whileKw") {}

"The ‘`try`’ keyword."
shared object tryKw extends KeywordType("tryKw") {}

"The ‘`catch`’ keyword."
shared object catchKw extends KeywordType("catchKw") {}

"The ‘`finally`’ keyword."
shared object finallyKw extends KeywordType("finallyKw") {}

"The ‘`then`’ keyword."
shared object thenKw extends KeywordType("thenKw") {}

"The ‘`let`’ keyword."
shared object letKw extends KeywordType("letKw") {}

"The ‘`this`’ keyword."
shared object thisKw extends KeywordType("thisKw") {}

"The ‘`outer`’ keyword."
shared object outerKw extends KeywordType("outerKw") {}

"The ‘`super`’ keyword."
shared object superKw extends KeywordType("superKw") {}

"The ‘`is`’ keyword."
shared object isKw extends KeywordType("isKw") {}

"The ‘`exists`’ keyword."
shared object existsKw extends KeywordType("existsKw") {}

"The ‘`nonempty`’ keyword."
shared object nonemptyKw extends KeywordType("nonemptyKw") {}

shared abstract class TokenType(string)
        of IgnoredType | IdentifierType {
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

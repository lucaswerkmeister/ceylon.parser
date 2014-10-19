shared abstract class TokenType(string) {
    shared actual String string;
}

"Whitespace."
shared object whitespace extends TokenType("whitespace") {}

"A single-line comment, for example:
 
     // comment
     #!/usr/bin/ceylon"
shared object lineComment extends TokenType("lineComment") {}

"A multi-line comment, for example:
 
     /*
      * comment
      */
     
     /* doesn’t actually have to be multi-line */
     
     /* can /* be */ nested */"
shared object multiComment extends TokenType("multiComment") {}

"""An initial lowercase identifier (with optional prefix), for example:
   
       null
       \iSOUTH"""
shared object lidentifier extends TokenType("lidentifier") {}

"""An initial uppercase identifier (with optional prefix), for example:
   
       Object
       \Iklass"""
shared object uidentifier extends TokenType("uidentifier") {}

"A lexer for the Ceylon programming language.
 
 # Usage
 
 [[String]] → [[TokenStream]]:
 
     TokenStream tokens
             = TokenSourceStream( // adds lookahead and seeking capabilities to the stream
         CeylonLexer( // does the lexing
             StringCharacterStream( // yields characters from the string
                 string)));
 
 [[String]] → [[TokenStream]], filtering whitespace and comments:
 
     TokenStream tokens
             = TokenSourceStream( // adds lookahead and seeking capabilities to the stream
         NonIgnoredTokenSource( // filters out ignored tokens (whitespace, comments)
             CeylonLexer( // does the lexing
                 StringCharacterStream( // yields characters from the string
                     string))));"
module ceylon.lexer.core "1.1.0" {
    import ceylon.collection "1.1.0";
}

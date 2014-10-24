"A stream of tokens."
shared interface TokenSource
        satisfies Iterator<Token> {
    
    "Returns the next token, or [[null]]
     if there are no more tokens.
     
     (There is no `EOF` token.)"
    shared formal Token? nextToken();
    
    shared actual Token|Finished next()
            => nextToken() else finished;
}

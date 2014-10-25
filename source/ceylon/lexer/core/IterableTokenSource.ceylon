"A [[TokenSource]] that draws its tokens
 from a regular [[stream|tokens]]."
shared class IterableTokenSource({Token*} tokens)
        satisfies TokenSource {
    
    Iterator<Token> it = tokens.iterator();
    
    shared actual Token? nextToken() {
        value next = it.next();
        switch (next)
        case (is Token) { return next; }
        case (finished) { return null; }
    }
}

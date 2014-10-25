"A [[TokenSource]] that filters the tokens from another [[source]]
 according to a given [[selecting]] function."
shared class FilteringTokenSource(source, selecting)
        satisfies TokenSource {
    
    "The underlying [[TokenSource]]."
    TokenSource source;
    "The selection function;
     return [[true]] if the given [[token]] should yielded,
     [[false]] if it should be filtered."
    Boolean selecting(
        "The next token from the underlying [[source]]."
        Token token);
    
    shared actual Token? nextToken() {
        if (exists next = source.nextToken()) {
            variable Token t = next;
            while (!selecting(t)) {
                if (exists n = source.nextToken()) {
                    t = n;
                } else {
                    return null;
                }
            }
            return t;
        } else {
            return null;
        }
    }
}

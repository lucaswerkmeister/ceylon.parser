"A [[TokenSource]] that filters all [[ignored|IgnoredType]] tokens
 from an underlying [[source]].
 
 This is equivalent to a
 
     FilteringTokenSource(source, (token) => !t.type is IgnoredType)
 
 but implemented directly because of performance concerns."
shared class NonIgnoredTokenSource(source)
        satisfies TokenSource {
    
    "The underlying [[TokenSource]]."
    TokenSource source;
    
    shared actual Token? nextToken() {
        if (exists next = source.nextToken()) {
            variable Token t = next;
            while (t.type is IgnoredType) {
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

"An [[Iterable]] wrapper around a [[TokenSource]].
 
 Since a [[TokenSource]] offers no way to reset itself,
 only one [[iterator]] may be obtained.
 This class is thus intended for one-time use only,
 like this:
 
     for (token in TokenSourceIterable(CeylonLexer(characters)) {
         process.write(token.text);
     }
 
 It can also be used to obtain a [[sequence]] of all tokens
 that a [[source]] yields."
shared class TokenSourceIterable(TokenSource source)
        satisfies {Token*} {
    variable TokenSource? src = source;
    
    "Returns the [[source]] on the first call,
     then throws an [[AssertionError]] on subsequent calls."
    throws (`class AssertionError`, "When called more than once.")
    shared actual Iterator<Token> iterator() {
        if (exists s = src) {
            src = null; // prevent re-evaluation
            return s;
        } else {
            throw AssertionError("May not be iterated several times!");
        }
    }
}

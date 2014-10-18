"""A stream of characters with arbitrary lookahead.
   
   Typical usage can look like this:
   
       if (cs.peek(1) == 't',
           cs.peek(2) == 'r',
           cs.peek(3) == 'y'
           !isIdentifierPart(cs.peek(4))) {
           
           cs.consume("try".size);
           // ...
       }
   
   The class [[CharacterSourceStream]] may be used
   to turn a [[CharacterSource]] (no lookahead)
   into a [[CharacterStream]] (arbitrary lookahead)."""
shared interface CharacterStream
        satisfies CharacterSource {
    
    "Peek [[n]] characters ahead, where `n` must be at least 0.
     
     If there are not enough characters in the stream,
     the character `PRIVATE USE 1` (U+0091) is returned instead."
    shared formal Character peek(Integer n = 0);
    
    "Consume [[count]] characters."
    shared formal void consume(Integer count = 1);
    
    shared actual default Character nextCharacter() {
        value ret = peek();
        consume();
        return ret;
    }
}

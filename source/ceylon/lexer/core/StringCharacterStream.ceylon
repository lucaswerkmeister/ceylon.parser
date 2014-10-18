"A [[CharacterStream]] that reads its characters from a [[string]]."
shared class StringCharacterStream(shared actual String string)
        satisfies CharacterStream {
    
    value characters = string.sequence(); // navigation is expensive because of surrogates, do it only once
    variable value index = 0;
    
    shared actual Character peek(Integer n) {
        "Cannot peek backwards"
        assert (n >= 0);
        return characters.getFromFirst(n + index) else '\{PRIVATE USE ONE}';
    }
    
    shared actual void consume(Integer count) {
        "Count must be positive"
        assert (count > 0);
        index += count;
    }
}

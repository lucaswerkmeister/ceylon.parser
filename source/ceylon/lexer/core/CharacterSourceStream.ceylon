import ceylon.collection {
    LinkedList
}

"A [[CharacterStream]] that gets its characters
 from an underlying [[CharacterSource]]."
shared class CharacterSourceStream(CharacterSource source)
        satisfies CharacterStream {
    
    value characters = LinkedList<Character>();
    
    void fill(Integer count) {
        while (count > characters.size) {
            characters.add(source.nextCharacter());
        }
    }
    
    shared actual Character peek(Integer n) {
        fill(n + 1);
        assert (exists ret = characters[n]);
        return ret;
    }
    
    shared actual void consume(Integer count) {
        characters.deleteMeasure(0, count);
    }
}

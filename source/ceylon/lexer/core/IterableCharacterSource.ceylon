"A [[CharacterSource]] that draws its characters
 from a regular [[stream|characters]]."
shared class IterableCharacterSource({Character*} characters)
        satisfies CharacterSource {
    
    Iterator<Character> it = characters.iterator();
    
    shared actual Character nextCharacter() {
        value next = it.next();
        switch (next)
        case (is Character) { return next; }
        case (finished) { return '\{PRIVATE USE ONE}'; }
    }
}

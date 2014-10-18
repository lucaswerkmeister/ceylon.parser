import ceylon.lexer.core {
    CharacterSource,
    IterableCharacterSource
}

"Tests [[IterableCharacterSource]]."
shared class IterableCharacterSourceTest()
        satisfies CharacterSourceTest {
    shared actual CharacterSource create({Character*} content) => IterableCharacterSource(content);
}

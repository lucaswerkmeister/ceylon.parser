import ceylon.lexer.core {
    CharacterSourceStream,
    CharacterStream,
    IterableCharacterSource
}

"Tests [[CharacterSourceStream]]."
shared class CharacterSourceStreamTest()
        satisfies CharacterStreamTest {
    shared actual CharacterStream create({Character*} content) => CharacterSourceStream(IterableCharacterSource(content));
}

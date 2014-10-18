import ceylon.lexer.core {
    CharacterStream,
    StringCharacterStream
}

"Tests [[StringCharacterStream]]."
shared class StringCharacterStreamTest()
        satisfies CharacterStreamTest {
    shared actual CharacterStream create({Character*} content) => StringCharacterStream(String(content));
}

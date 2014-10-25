import ceylon.lexer.core {
    IterableTokenSource,
    Token,
    TokenSourceStream,
    TokenStream
}

"Tests [[TokenSourceStream]]."
shared class TokenSourceStreamTest()
        satisfies TokenStreamTest {
    shared actual TokenStream create({Token*} content) => TokenSourceStream(IterableTokenSource(content));
}

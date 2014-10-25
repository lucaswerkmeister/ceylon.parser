import ceylon.lexer.core {
    IterableTokenSource,
    Token,
    TokenSourceIterable,
    elseKw,
    whitespace
}
import ceylon.test {
    test,
    assertEquals
}

"Tests [[IterableTokenSource]]."
test
shared void testIterableTokenSource() {
    value tokens = [Token(whitespace, "     "), Token(elseKw, "else")];
    assertEquals {
        actual = TokenSourceIterable(IterableTokenSource(tokens)).sequence();
        expected = tokens;
    };
}

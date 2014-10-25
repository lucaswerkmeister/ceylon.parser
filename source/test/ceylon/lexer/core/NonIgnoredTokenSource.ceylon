import ceylon.test {
    test,
    assertEquals
}
import ceylon.lexer.core {
    CeylonLexer,
    NonIgnoredTokenSource,
    StringCharacterStream,
    Token,
    TokenSourceIterable,
    elseKw,
    lbrace,
    lid=lidentifier,
    lparen,
    memberOp,
    rbrace,
    rparen,
    semicolon,
    stringEnd,
    stringLiteral,
    stringStart,
    voidKw
}

test
shared void testNonIgnoredTokenSource()
        => assertEquals {
    actual = TokenSourceIterable(NonIgnoredTokenSource(CeylonLexer(StringCharacterStream(
                    """shared void run() {
                           print("Hello, `` process.arguments.first else "World" ``!");
                       }
                       """)))).sequence();
    expected = [
        lid->"shared", voidKw->"void", lid->"run", lparen->"(", rparen->")", lbrace->"{",
        lid->"print", lparen->"(", stringStart->"\"Hello, \`\`", lid->"process", memberOp->".", lid->"arguments", memberOp->".", lid->"first", elseKw->"else", stringLiteral->"\"World\"", stringEnd->"\`\`!\"", rparen->")", semicolon->";",
        rbrace->"}"
    ].collect((typeText) => Token(typeText.key, typeText.item));
    message = "Whitespace filter";
};

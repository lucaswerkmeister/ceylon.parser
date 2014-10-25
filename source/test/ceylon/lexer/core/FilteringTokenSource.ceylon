import ceylon.test {
    test,
    assertEquals
}
import ceylon.lexer.core {
    CeylonLexer,
    FilteringTokenSource,
    StringCharacterStream,
    Token,
    TokenSourceIterable,
    IgnoredType,
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
    uidentifier,
    voidKw
}

shared class FilteringTokenSourceTest() {
    
    test
    shared void trueFilter()
            => assertEquals {
        actual = TokenSourceIterable(FilteringTokenSource(CeylonLexer(StringCharacterStream("Fubar")), (token) => true)).sequence();
        expected = [Token(uidentifier, "Fubar")];
        message = "No filter";
    };
    
    test
    shared void falseFilter()
            => assertEquals {
        actual = TokenSourceIterable(FilteringTokenSource(CeylonLexer(StringCharacterStream("Fubar")), (token) => false)).sequence();
        expected = [];
        message = "Full filter";
    };
    
    test
    shared void wsFilter()
            => assertEquals {
        actual = TokenSourceIterable(FilteringTokenSource(CeylonLexer(StringCharacterStream(
                        """shared void run() {
                               print("Hello, `` process.arguments.first else "World" ``!");
                           }
                           """)),
                (token) => !token.type is IgnoredType)).sequence();
        expected = [
            lid->"shared", voidKw->"void", lid->"run", lparen->"(", rparen->")", lbrace->"{",
            lid->"print", lparen->"(", stringStart->"\"Hello, \`\`", lid->"process", memberOp->".", lid->"arguments", memberOp->".", lid->"first", elseKw->"else", stringLiteral->"\"World\"", stringEnd->"\`\`!\"", rparen->")", semicolon->";",
            rbrace->"}"
        ].collect((typeText) => Token(typeText.key, typeText.item));
        message = "Whitespace filter";
    };
}

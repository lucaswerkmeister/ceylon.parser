import ceylon.test {
    test,
    assertEquals,
    assertThatException
}
import ceylon.lexer.core {
    CeylonLexer,
    StringCharacterStream,
    Token,
    TokenSource,
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
    voidKw,
    ws=whitespace
}

shared class TokenSourceIterableTest() {
    
    test
    shared void iterator() {
        object source satisfies TokenSource {
            shared actual Token? nextToken() => null;
        }
        value it = TokenSourceIterable(source);
        assertEquals {
            actual = it.iterator();
            expected = source;
            message = "First iteration";
        };
        assertThatException(it.iterator)
            .hasType(`AssertionError`)
            .hasNoCause();
    }
    
    test
    shared void sequence() {
        value it = TokenSourceIterable(CeylonLexer(StringCharacterStream(
                    """shared void run() {
                           print("Hello, `` process.arguments.first else "World" ``!");
                       }""")));
        value sp = ws->" ";
        assertEquals {
            actual = it.sequence();
            expected = [
                lid->"shared", sp, voidKw->"void", sp, lid->"run", lparen->"(", rparen->")", sp, lbrace->"{", ws->"\n    ",
                lid->"print", lparen->"(", stringStart->"\"Hello, \`\`", sp, lid->"process", memberOp->".", lid->"arguments", memberOp->".", lid->"first", sp, elseKw->"else", sp, stringLiteral->"\"World\"", sp, stringEnd->"\`\`!\"", rparen->")", semicolon->";", ws->"\n",
                rbrace->"}"
            ].collect((typeText) => Token(typeText.key, typeText.item));
        };
    }
}

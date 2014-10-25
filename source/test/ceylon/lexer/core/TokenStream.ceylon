import ceylon.lexer.core {
    CeylonLexer,
    StringCharacterStream,
    Token,
    TokenSourceIterable,
    TokenStream
}
import ceylon.test {
    test,
    assertEquals
}

"Tests a [[TokenStream]]."
shared interface TokenStreamTest {
    
    "Creates a [[TokenStream]] that will yield
     exactly the tokens from [[content]]."
    shared formal TokenStream create({Token*} content);
    
    "Tests full lookahead in a nonempty [[TokenStream]]."
    test
    shared void fullLookahead() {
        value tokens = TokenSourceIterable(CeylonLexer(StringCharacterStream("shared class C() {}"))).sequence();
        value stream = create(tokens);
        for (index->token in tokens.indexed) {
            assertEquals {
                actual = stream.peek(index);
                expected = token;
                message = "Peek token";
            };
        }
        assertEquals {
            actual = stream.peek(tokens.size);
            expected = null;
            message = "No more tokens expected";
        };
    }
    
    "Tests partial lookahead in a nonempty [[TokenStream]]."
    test
    shared void partialLookahead() {
        value tokens = TokenSourceIterable(CeylonLexer(StringCharacterStream("shared class C() {}"))).sequence();
        value stream = create(tokens);
        for (i in 0:5) {
            assert (exists c = tokens[i]);
            assertEquals {
                actual = stream.peek(i);
                expected = c;
                message = "Peek token";
            };
        }
        stream.consume(5);
        for (i in 0 : tokens.size - 5) {
            assert (exists token = tokens[5 + i]);
            assertEquals {
                actual = stream.peek(i);
                expected = token;
                message = "Peek token after partial consume";
            };
        }
        stream.consume(tokens.size - 5);
        assertEquals {
            actual = stream.peek();
            expected = null;
            message = "No more tokens expected";
        };
    }
    
    "Tests rewinding a [[TokenStream]] once."
    test
    shared void singleSeek() {
        value tokens = TokenSourceIterable(CeylonLexer(StringCharacterStream("shared class C() {}"))).sequence();
        value stream = create(tokens);
        try (marker = stream.Marker()) {
            for (token in tokens) {
                assertEquals {
                    actual = stream.nextToken();
                    expected = token;
                    message = "Take token";
                };
            }
            assertEquals {
                actual = stream.nextToken();
                expected = null;
                message = "No more tokens expected";
            };
            stream.seek(marker.index);
        }
        for (token in tokens) {
            assertEquals {
                actual = stream.nextToken();
                expected = token;
                message = "Take token after rewind";
            };
        }
        assertEquals {
            actual = stream.nextToken();
            expected = null;
            message = "No more tokens expected";
        };
    }
    
    "Tests multiple nested markers and seeks in a [[TokenStream]]."
    test
    shared void nestedSeeks() {
        value tokens = TokenSourceIterable(CeylonLexer(StringCharacterStream("shared class C() {}"))).sequence();
        value stream = create(tokens);
        try (marker = stream.Marker()) {
            for (i in 0:5) {
                assert (exists c = tokens[i]);
                assertEquals {
                    actual = stream.nextToken();
                    expected = c;
                    message = "Take token";
                };
            }
            try (marker2 = stream.Marker()) {
                for (i in 0 : tokens.size - 5) {
                    assert (exists token = tokens[5 + i]);
                    assertEquals {
                        actual = stream.nextToken();
                        expected = token;
                        message = "Take token";
                    };
                }
                assertEquals {
                    actual = stream.nextToken();
                    expected = null;
                    message = "No more tokens expected";
                };
                stream.seek(marker2.index);
            }
            for (i in 0 : tokens.size - 5) {
                assert (exists token = tokens[5 + i]);
                assertEquals {
                    actual = stream.nextToken();
                    expected = token;
                    message = "Take token after inner seek";
                };
            }
            assertEquals {
                actual = stream.nextToken();
                expected = null;
                message = "No more tokens expected";
            };
            stream.seek(marker.index);
        }
        for (i in 0:5) {
            assert (exists c = tokens[i]);
            assertEquals {
                actual = stream.nextToken();
                expected = c;
                message = "Take token";
            };
        }
        for (i in 0 : tokens.size - 5) {
            assert (exists token = tokens[5 + i]);
            assertEquals {
                actual = stream.nextToken();
                expected = token;
                message = "Take token after outer seek";
            };
        }
        assertEquals {
            actual = stream.nextToken();
            expected = null;
            message = "No more tokens expected";
        };
    }
}

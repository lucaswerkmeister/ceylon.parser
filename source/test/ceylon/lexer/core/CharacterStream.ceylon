import ceylon.lexer.core {
    CharacterStream
}
import ceylon.test {
    test,
    assertEquals
}

"Tests a [[CharacterStream]]."
shared interface CharacterStreamTest
        satisfies CharacterSourceTest {
    
    "Creates a [[CharacterStream]] that will yield
     exactly the characters from [[content]]."
    shared actual formal CharacterStream create({Character*} content);
    
    "Tests full lookahead in a nonempty [[CharacterStream]]."
    test
    shared void fullLookahead() {
        value s = "Hello, World!";
        value cs = create(s);
        for (i in 0:s.size) {
            assert (exists c = s[i]);
            assertEquals {
                actual = cs.peek(i);
                expected = c;
                message = "Lookahead ordinary character";
            };
        }
        assertEquals {
            actual = cs.peek(s.size);
            expected = '\{PRIVATE USE ONE}';
            message = "Lookahead termination character";
        };
        cs.consume(s.size);
        assertEquals {
            actual = cs.peek();
            expected = '\{PRIVATE USE ONE}';
            message = "Termination character after consume";
        };
    }
    
    "Tests partial lookahead in a nonempty [[CharacterStream]]."
    test
    shared void partialLookahead() {
        value s = "Hello, World!";
        value cs = create(s);
        for (i in 0:5) {
            assert (exists c = s[i]);
            assertEquals {
                actual = cs.peek(i);
                expected = c;
                message = "Lookahead ordinary character";
            };
        }
        cs.consume(5);
        for (i in 0 : s.size - 5) {
            assert (exists c = s[5 + i]);
            assertEquals {
                actual = cs.peek(i);
                expected = c;
                message = "Lookahead ordinary character after partial consume";
            };
        }
        cs.consume(s.size - 5);
        assertEquals {
            actual = cs.peek();
            expected = '\{PRIVATE USE ONE}';
            message = "Termination character after consume";
        };
    }
}

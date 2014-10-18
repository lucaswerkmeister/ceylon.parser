import ceylon.lexer.core {
    CharacterSource
}
import ceylon.test {
    test,
    assertEquals
}

"Tests a [[CharacterSource]]."
shared interface CharacterSourceTest {
    
    "Creates a [[CharacterSource]] that will yield
     exactly the characters from [[content]]."
    shared formal CharacterSource create({Character*} content);
    
    "Tests a nonempty [[CharacterSource]]."
    test
    shared void helloWorld() {
        value s = "Hello, World!";
        value cs = create(s);
        for (c in s) {
            assertEquals {
                actual = cs.nextCharacter();
                expected = c;
                message = "Regular character";
            };
        }
        assertEquals {
            actual = cs.nextCharacter();
            expected = '\{PRIVATE USE ONE}';
            message = "Termination character";
        };
    }
    
    "Tests an empty [[CharacterSource]]."
    test
    shared void empty() {
        assertEquals {
            actual = create("").nextCharacter();
            expected = '\{PRIVATE USE ONE}';
            message = "Termination character";
        };
    }
    
    "Tests a [[CharacterSource]] containing characters that are
     not from the Basic Multilingual Plane
     (i. e., don’t fit in a single Java `char`)."
    test
    shared void nonBMP() {
        value s = "\{ELEPHANT}
                   \{MILKY WAY}
                   \{PINEAPPLE}
                   \{WINKING FACE}
                   \{LYDIAN TRIANGULAR MARK}
                   \{IMPERIAL ARAMAIC LETTER RESH}
                   \{ALCHEMICAL SYMBOL FOR GOLD}";
        value cs = create(s);
        for (c in s) {
            assertEquals {
                actual = cs.nextCharacter();
                expected = c;
                message = "Regular character";
            };
        }
        assertEquals {
            actual = cs.nextCharacter();
            expected = '\{PRIVATE USE ONE}';
            message = "Termination character";
        };
    }
}

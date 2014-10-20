"""A Lexer for the Ceylon programming language,
   turning a stream of [[characters]] into a stream of tokens.
   
   ### A note on character and string literals
   
   This lexer deviates *slightly* from the behavior
   of the official Ceylon compiler in that escape sequences
   for character and string literals may not contain quotes.
   For example, the Ceylon compiler will parse these as single literals:
   
       '\{FICTITIOUS CHARACTER WITH ' IN NAME}'
       "String containing \{FICTITIOUS CHARACTER WITH " IN NAME}"
   
   because its grammar has separate rules for these escape sequences
   and doesn’t exit them until encountering the closing brace;
   this lexer simply terminates the literal
   on the first matching unescaped quote.
   
   This is okay because the [Ceylon 1.1 language specification][Ceylon1.1],
   2.4.2 “Character literals”,
   defines these escape sequences like this:
   
   > ~~~antlr
   > EscapeSequence: "\" (SingleCharacterEscape | "{" CharacterCode "}")
   > ~~~
   > ~~~antlr
   > CharacterCode: "#" ( HexDigit{4} | HexDigit{8} ) | UnicodeCharacterName
   > ~~~
   > 
   > Legal Unicode character names are defined by the Unicode specification.
   
   And per the [Unicode 7.0.0 specification][Unicode7],
   4.8 “Name”, a Unicode character name
   may contain only a certain set of characters,
   which does not include quotes.
   
   Therefore, any program that is lexed differently because of this deviation
   cannot be a legal one.
   
   ### A note on numeric literals
   
   This lexer is slightly more permissive than the grammar from the
   [Ceylon 1.1 language specification][Ceylon1.1] concerning numeric literals;
   it does not enforce
   
   - nonemptiness of exponents (i. e., `1.5E` and `1.5E+` are lexed as legal
     float literals), and
   - correct grouping of underscores (i. e., `1_000_00.0000_0` is lexed as
     a legal float literal).
   
   If desired, they need to be checked at a later stage of compilation.
   
   [Ceylon1.1]: http://ceylon-lang.org/documentation/1.1/spec/
   [Unicode7]: http://www.unicode.org/versions/Unicode7.0.0/"""
shared class CeylonLexer(CharacterStream characters) {
    
    value terminator = '\{PRIVATE USE ONE}';
    
    "Returns the next token, or [[null]] if the [[character stream|characters]]
     is depleted.
     
     (There is no `EOF` token.)"
    shared Token? nextToken() {
        while (characters.peek() != terminator) {
            variable Character next;
            switch (next = characters.peek())
            case ('/') {
                // start of comment?
                switch (characters.peek(1))
                case ('/') {
                    // line comment
                    characters.consume(2);
                    StringBuilder text = StringBuilder();
                    text.append("//");
                    while ((next = characters.peek()) != '\n' && next != terminator) {
                        characters.consume();
                        text.appendCharacter(next);
                    }
                    return token(lineComment, text.string);
                }
                case ('*') {
                    // multi comment
                    characters.consume(2);
                    StringBuilder text = StringBuilder();
                    text.append("/*");
                    variable Integer level = 1;
                    while (level != 0) {
                        next = characters.peek();
                        if (next == '/' && characters.peek(1) == '*') {
                            level++;
                            text.append("/*");
                            characters.consume(2);
                            continue;
                        } else if (next == '*' && characters.peek(1) == '/') {
                            level--;
                            text.append("*/");
                            characters.consume(2);
                            continue;
                        } else if (next == terminator) {
                            // TODO unterminated multi comment – error?
                            return token(multiComment, text.string);
                        } else {
                            text.appendCharacter(next);
                            characters.consume();
                        }
                    }
                    return token(multiComment, text.string);
                }
                else {
                    // TODO division operator
                }
            }
            case ('#') {
                if ((next = characters.peek(1)) == '!') {
                    #! line comment
                    characters.consume(2);
                    StringBuilder text = StringBuilder();
                    text.append("#!");
                    while ((next = characters.peek()) != '\n' && next != terminator) {
                        characters.consume();
                        text.appendCharacter(next);
                    }
                    return token(lineComment, text.string);
                } else {
                    // hex literal
                    characters.consume(1);
                    StringBuilder text = StringBuilder();
                    text.appendCharacter('#');
                    while ((next = characters.peek()) == '_'
                                || '0' <= next <= '9'
                                || 'A' <= next <= 'F'
                                || 'a' <= next <= 'f') {
                        characters.consume();
                        text.appendCharacter(next);
                    }
                    return token(hexLiteral, text.string);
                }
            }
            case ('$') {
                // binary literal
                characters.consume(1);
                StringBuilder text = StringBuilder();
                text.appendCharacter('$');
                while ((next = characters.peek()) == '0'
                            || next == '1'
                            || next == '_') {
                    characters.consume();
                    text.appendCharacter(next);
                }
                return token(binaryLiteral, text.string);
            }
            case ('\\') {
                switch (next = characters.peek(1))
                case ('i') {
                    // forced lowercase identifier
                    characters.consume(2);
                    StringBuilder text = StringBuilder();
                    text.append("\\i");
                    while (isIdentifierPart(next = characters.peek())) {
                        text.appendCharacter(next);
                        characters.consume();
                    }
                    return token(lidentifier, text.string);
                }
                case ('I') {
                    // forced uppercase identifier
                    characters.consume(2);
                    StringBuilder text = StringBuilder();
                    text.append("\\I");
                    while (isIdentifierPart(next = characters.peek())) {
                        text.appendCharacter(next);
                        characters.consume();
                    }
                    return token(uidentifier, text.string);
                }
                else {
                    // TODO error
                }
            }
            case ('"') {
                if (characters.peek(1) == '"' && characters.peek(2) == '"') {
                    // verbatim string literal
                    characters.consume(3);
                    StringBuilder text = StringBuilder();
                    text.append("\"\"\"");
                    while ((next = characters.peek()) != '"'
                                || characters.peek(1) != '"'
                                || characters.peek(2) != '"') {
                        if (next == terminator) { break; }
                        text.appendCharacter(next);
                        characters.consume();
                    }
                    if (next == terminator) {
                        // TODO error
                    } else {
                        // next three characters are """
                        if (characters.peek(3) == '"') {
                            // """""""" is a verbatim string containing two quotes
                            text.appendCharacter('"');
                            characters.consume();
                            if (characters.peek(3) == '"') {
                                text.appendCharacter('"');
                                characters.consume();
                            }
                        }
                        characters.consume(3);
                        text.append("\"\"\"");
                        return token(verbatimStringLiteral, text.string);
                    }
                } else {
                    // string literal or string start
                    characters.consume();
                    StringBuilder text = StringBuilder();
                    text.appendCharacter('"');
                    while ((next = characters.peek()) != '"'
                                && (next != '`' || characters.peek(1) != '`')) {
                        if (next == terminator) { break; }
                        text.appendCharacter(next);
                        characters.consume();
                        if (next == '\\') {
                            text.appendCharacter(characters.peek());
                            characters.consume();
                        }
                    }
                    if (next == terminator) {
                        // TODO error
                    } else {
                        if (next == '"') {
                            text.appendCharacter('"');
                            characters.consume();
                            return token(stringLiteral, text.string);
                        } else {
                            text.append("\`\`");
                            characters.consume(2);
                            return token(stringStart, text.string);
                        }
                    }
                }
            }
            case ('`') {
                if (characters.peek(1) == '`') {
                    // string mid or string end
                    characters.consume(2);
                    StringBuilder text = StringBuilder();
                    text.append("\`\`");
                    while ((next = characters.peek()) != '"'
                                && (next != '`' || characters.peek(1) != '`')) {
                        if (next == terminator) { break; }
                        text.appendCharacter(next);
                        characters.consume();
                        if (next == '\\') {
                            text.appendCharacter(characters.peek());
                            characters.consume();
                        }
                    }
                    if (next == terminator) {
                        // TODO error
                    } else {
                        if (next == '"') {
                            text.appendCharacter('"');
                            characters.consume();
                            return token(stringEnd, text.string);
                        } else {
                            text.append("\`\`");
                            characters.consume(2);
                            return token(stringMid, text.string);
                        }
                    }
                } else {
                    // TODO backtick
                }
            }
            case ('\'') {
                // character literal
                characters.consume();
                StringBuilder text = StringBuilder();
                text.appendCharacter('\'');
                while ((next = characters.peek()) != '\'') {
                    if (next == terminator) { break; }
                    text.appendCharacter(next);
                    characters.consume();
                    if (next == '\\') {
                        text.appendCharacter(characters.peek());
                        characters.consume();
                    }
                }
                if (next == terminator) {
                    // TODO error
                } else {
                    text.appendCharacter('\'');
                    characters.consume();
                    return token(characterLiteral, text.string);
                }
            }
            case ('0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9') {
                // numeric literal, we don’t know yet which kind
                characters.consume();
                StringBuilder text = StringBuilder();
                text.appendCharacter(next);
                while ('0' <= (next = characters.peek()) <= '9'
                            || next == '_') {
                    text.appendCharacter(next);
                    characters.consume();
                }
                switch (next = characters.peek())
                case ('.') {
                    // could be a float literal or a qualified expression
                    if ('0' <= characters.peek(1) <= '9'
                                || next == '_') {
                        // float literal
                        text.appendCharacter('.');
                        characters.consume();
                        while ('0' <= (next = characters.peek()) <= '9'
                                    || next == '_') {
                            text.appendCharacter(next);
                            characters.consume();
                        }
                        // might also have an exponent or magnitude
                        switch (next = characters.peek())
                        case ('E' | 'e') {
                            // exponent
                            text.appendCharacter(next);
                            characters.consume();
                            if ((next = characters.peek()) == '-'
                                        || next == '+') {
                                text.appendCharacter(next);
                                characters.consume();
                            }
                            while ('0' <= (next = characters.peek()) <= '9'
                                        || next == '_') {
                                text.appendCharacter(next);
                                characters.consume();
                            }
                            return token(floatLiteral, text.string);
                        }
                        case ('k' | 'M' | 'G' | 'T' | 'P' | 'm' | 'u' | 'n' | 'p' | 'f') {
                            // magnitude, we don’t care if it’s a regular or fractional one
                            text.appendCharacter(next);
                            characters.consume();
                            return token(floatLiteral, text.string);
                        }
                        else {
                            // belongs to the next token
                            return token(floatLiteral, text.string);
                        }
                    } else {
                        // qualified expression, don’t consume the member operator!
                        return token(decimalLiteral, text.string);
                    }
                }
                case ('k' | 'M' | 'G' | 'T' | 'P') {
                    // regular magnitude
                    text.appendCharacter(next);
                    characters.consume();
                    return token(decimalLiteral, text.string);
                }
                case ('m' | 'u' | 'n' | 'p' | 'f') {
                    // fractional magnitude, shortcut float literal
                    text.appendCharacter(next);
                    characters.consume();
                    return token(floatLiteral, text.string);
                }
                else {
                    // belongs to the next token
                    return token(decimalLiteral, text.string);
                }
            }
            else {
                if (isIdentifierStart(next)) {
                    characters.consume();
                    StringBuilder text = StringBuilder();
                    text.appendCharacter(next);
                    Boolean lowercase = next.lowercase;
                    while (isIdentifierPart(next = characters.peek())) {
                        text.appendCharacter(next);
                        characters.consume();
                    }
                    return token(lowercase then lidentifier else uidentifier, text.string);
                } else {
                    if (next.whitespace) {
                        characters.consume();
                        StringBuilder text = StringBuilder();
                        text.appendCharacter(next);
                        while ((next = characters.peek()).whitespace) {
                            text.appendCharacter(next);
                            characters.consume();
                        }
                        return token(whitespace, text.string);
                    } else {
                        // TODO error
                    }
                }
            }
        }
        return null;
    }
    
    Token token(TokenType type, String text)
            => Token(type, text); // TODO count token index?
    
    Boolean isIdentifierStart(Character character)
            => character.letter || character == '_';
    
    Boolean isIdentifierPart(Character character)
            => character.letter || character.digit || character == '_';
}

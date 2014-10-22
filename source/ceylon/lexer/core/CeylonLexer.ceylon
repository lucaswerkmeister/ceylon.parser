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
                case ('=') {
                    // TODO /=
                }
                else {
                    return charToken(quotientOp, '/');
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
                    return charToken(backtick, '`');
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
            case ('a') {
                if (characters.peek(1) == 'l'
                            && characters.peek(2) == 'i'
                            && characters.peek(3) == 'a'
                            && characters.peek(4) == 's'
                            && !isIdentifierPart(characters.peek(5))) {
                    characters.consume(5);
                    return token(aliasKw, "alias");
                } else if (characters.peek(1) == 's'
                            && characters.peek(2) == 's') {
                    if (characters.peek(3) == 'e') {
                        if (characters.peek(4) == 'm'
                                    && characters.peek(5) == 'b'
                                    && characters.peek(6) == 'l'
                                    && characters.peek(7) == 'y'
                                    && !isIdentifierPart(characters.peek(8))) {
                            characters.consume(8);
                            return token(assemblyKw, "assembly");
                        } else if (characters.peek(4) == 'r'
                                    && characters.peek(5) == 't'
                                    && !isIdentifierPart(characters.peek(6))) {
                            characters.consume(6);
                            return token(assertKw, "assert");
                        } else {
                            return identifier(next);
                        }
                    } else if (characters.peek(3) == 'i'
                                && characters.peek(4) == 'g'
                                && characters.peek(5) == 'n'
                                && !isIdentifierPart(characters.peek(6))) {
                        characters.consume(6);
                        return token(assignKw, "assign");
                    } else {
                        return identifier(next);
                    }
                } else if (characters.peek(1) == 'b'
                            && characters.peek(2) == 's'
                            && characters.peek(3) == 't'
                            && characters.peek(4) == 'r'
                            && characters.peek(5) == 'a'
                            && characters.peek(6) == 'c'
                            && characters.peek(7) == 't'
                            && characters.peek(8) == 's'
                            && !isIdentifierPart(characters.peek(9))) {
                    characters.consume(9);
                    return token(abstractsKw, "abstracts");
                } else {
                    return identifier(next);
                }
            }
            case ('b') {
                if (characters.peek(1) == 'r'
                            && characters.peek(2) == 'e'
                            && characters.peek(3) == 'a'
                            && characters.peek(4) == 'k'
                            && !isIdentifierPart(characters.peek(5))) {
                    characters.consume(5);
                    return token(breakKw, "break");
                } else {
                    return identifier(next);
                }
            }
            case ('c') {
                if (characters.peek(1) == 'l'
                            && characters.peek(2) == 'a'
                            && characters.peek(3) == 's'
                            && characters.peek(4) == 's'
                            && !isIdentifierPart(characters.peek(5))) {
                    characters.consume(5);
                    return token(classKw, "class");
                } else if (characters.peek(1) == 'o'
                            && characters.peek(2) == 'n'
                            && characters.peek(3) == 't'
                            && characters.peek(4) == 'i'
                            && characters.peek(5) == 'n'
                            && characters.peek(6) == 'u'
                            && characters.peek(7) == 'e'
                            && !isIdentifierPart(characters.peek(8))) {
                    characters.consume(8);
                    return token(continueKw, "continue");
                } else if (characters.peek(1) == 'a') {
                    if (characters.peek(2) == 's'
                                && characters.peek(3) == 'e'
                                && !isIdentifierPart(characters.peek(4))) {
                        characters.consume(4);
                        return token(caseKw, "case");
                    } else if (characters.peek(2) == 't'
                                && characters.peek(3) == 'c'
                                && characters.peek(4) == 'h'
                                && !isIdentifierPart(characters.peek(5))) {
                        characters.consume(5);
                        return token(catchKw, "catch");
                    } else {
                        return identifier(next);
                    }
                } else {
                    return identifier(next);
                }
            }
            case ('d') {
                if (characters.peek(1) == 'y'
                            && characters.peek(2) == 'n'
                            && characters.peek(3) == 'a'
                            && characters.peek(4) == 'm'
                            && characters.peek(5) == 'i'
                            && characters.peek(6) == 'c'
                            && !isIdentifierPart(characters.peek(7))) {
                    characters.consume(7);
                    return token(dynamicKw, "dynamic");
                } else {
                    return identifier(next);
                }
            }
            case ('e') {
                if (characters.peek(1) == 'x') {
                    if (characters.peek(2) == 't'
                                && characters.peek(3) == 'e'
                                && characters.peek(4) == 'n'
                                && characters.peek(5) == 'd'
                                && characters.peek(6) == 's'
                                && !isIdentifierPart(characters.peek(7))) {
                        characters.consume(7);
                        return token(extendsKw, "extends");
                    } else if (characters.peek(2) == 'i'
                                && characters.peek(3) == 's'
                                && characters.peek(4) == 't'
                                && characters.peek(5) == 's'
                                && !isIdentifierPart(characters.peek(6))) {
                        characters.consume(6);
                        return token(existsKw, "exists");
                    } else {
                        return identifier(next);
                    }
                } else if (characters.peek(1) == 'l'
                            && characters.peek(2) == 's'
                            && characters.peek(3) == 'e'
                            && !isIdentifierPart(characters.peek(4))) {
                    characters.consume(4);
                    return token(elseKw, "else");
                } else {
                    return identifier(next);
                }
            }
            case ('f') {
                if (characters.peek(1) == 'u'
                            && characters.peek(2) == 'n'
                            && characters.peek(3) == 'c'
                            && characters.peek(4) == 't'
                            && characters.peek(5) == 'i'
                            && characters.peek(6) == 'o'
                            && characters.peek(7) == 'n'
                            && !isIdentifierPart(characters.peek(8))) {
                    characters.consume(8);
                    return token(functionKw, "function");
                } else if (characters.peek(1) == 'o'
                            && characters.peek(2) == 'r'
                            && !isIdentifierPart(characters.peek(3))) {
                    characters.consume(3);
                    return token(forKw, "for");
                } else if (characters.peek(1) == 'i'
                            && characters.peek(2) == 'n'
                            && characters.peek(3) == 'a'
                            && characters.peek(4) == 'l'
                            && characters.peek(5) == 'l'
                            && characters.peek(6) == 'y'
                            && !isIdentifierPart(characters.peek(7))) {
                    characters.consume(7);
                    return token(finallyKw, "finally");
                } else {
                    return identifier(next);
                }
            }
            case ('g') {
                if (characters.peek(1) == 'i'
                            && characters.peek(2) == 'v'
                            && characters.peek(3) == 'e'
                            && characters.peek(4) == 'n'
                            && !isIdentifierPart(characters.peek(5))) {
                    characters.consume(5);
                    return token(givenKw, "given");
                } else {
                    return identifier(next);
                }
            }
            case ('i') {
                if (characters.peek(1) == 'f'
                            && !isIdentifierPart(characters.peek(2))) {
                    characters.consume(2);
                    return token(ifKw, "if");
                } else if (characters.peek(1) == 's'
                            && !isIdentifierPart(characters.peek(2))) {
                    characters.consume(2);
                    return token(isKw, "is");
                } else if (characters.peek(1) == 'm'
                            && characters.peek(2) == 'p'
                            && characters.peek(3) == 'o'
                            && characters.peek(4) == 'r'
                            && characters.peek(5) == 't'
                            && !isIdentifierPart(characters.peek(6))) {
                    characters.consume(6);
                    return token(importKw, "import");
                } else if (characters.peek(1) == 'n') {
                    if (characters.peek(2) == 't'
                                && characters.peek(3) == 'e'
                                && characters.peek(4) == 'r'
                                && characters.peek(5) == 'f'
                                && characters.peek(6) == 'a'
                                && characters.peek(7) == 'c'
                                && characters.peek(8) == 'e'
                                && !isIdentifierPart(characters.peek(9))) {
                        characters.consume(9);
                        return token(interfaceKw, "interface");
                    } else if (!isIdentifierPart(characters.peek(2))) {
                        characters.consume(2);
                        return token(inKw, "in");
                    } else {
                        return identifier(next);
                    }
                } else {
                    return identifier(next);
                }
            }
            case ('m') {
                if (characters.peek(1) == 'o'
                            && characters.peek(2) == 'd'
                            && characters.peek(3) == 'u'
                            && characters.peek(4) == 'l'
                            && characters.peek(5) == 'e'
                            && !isIdentifierPart(characters.peek(6))) {
                    characters.consume(6);
                    return token(moduleKw, "module");
                } else {
                    return identifier(next);
                }
            }
            case ('n') {
                if (characters.peek(1) == 'e'
                            && characters.peek(2) == 'w'
                            && !isIdentifierPart(characters.peek(3))) {
                    characters.consume(3);
                    return token(newKw, "new");
                } else if (characters.peek(1) == 'o'
                            && characters.peek(2) == 'n'
                            && characters.peek(3) == 'e'
                            && characters.peek(4) == 'm'
                            && characters.peek(5) == 'p'
                            && characters.peek(6) == 't'
                            && characters.peek(7) == 'y'
                            && !isIdentifierPart(characters.peek(8))) {
                    characters.consume(8);
                    return token(nonemptyKw, "nonempty");
                } else {
                    return identifier(next);
                }
            }
            case ('l') {
                if (characters.peek(1) == 'e'
                            && characters.peek(2) == 't'
                            && !isIdentifierPart(characters.peek(3))) {
                    characters.consume(3);
                    return token(letKw, "let");
                } else {
                    return identifier(next);
                }
            }
            case ('o') {
                if (characters.peek(1) == 'b'
                            && characters.peek(2) == 'j'
                            && characters.peek(3) == 'e'
                            && characters.peek(4) == 'c'
                            && characters.peek(5) == 't'
                            && !isIdentifierPart(characters.peek(6))) {
                    characters.consume(6);
                    return token(objectKw, "object");
                } else if (characters.peek(1) == 'f'
                            && !isIdentifierPart(characters.peek(2))) {
                    characters.consume(2);
                    return token(ofKw, "of");
                } else if (characters.peek(1) == 'u'
                            && characters.peek(2) == 't') {
                    if (!isIdentifierPart(characters.peek(3))) {
                        characters.consume(3);
                        return token(outKw, "out");
                    } else if (characters.peek(3) == 'e'
                                && characters.peek(4) == 'r'
                                && !isIdentifierPart(characters.peek(5))) {
                        characters.consume(5);
                        return token(outerKw, "outer");
                    } else {
                        return identifier(next);
                    }
                } else {
                    return identifier(next);
                }
            }
            case ('p') {
                if (characters.peek(1) == 'a'
                            && characters.peek(2) == 'c'
                            && characters.peek(3) == 'k'
                            && characters.peek(4) == 'a'
                            && characters.peek(5) == 'g'
                            && characters.peek(6) == 'e'
                            && !isIdentifierPart(characters.peek(7))) {
                    characters.consume(7);
                    return token(packageKw, "package");
                } else {
                    return identifier(next);
                }
            }
            case ('r') {
                if (characters.peek(1) == 'e'
                            && characters.peek(2) == 't'
                            && characters.peek(3) == 'u'
                            && characters.peek(4) == 'r'
                            && characters.peek(5) == 'n'
                            && !isIdentifierPart(characters.peek(6))) {
                    characters.consume(6);
                    return token(returnKw, "return");
                } else {
                    return identifier(next);
                }
            }
            case ('s') {
                if (characters.peek(1) == 'a'
                            && characters.peek(2) == 't'
                            && characters.peek(3) == 'i'
                            && characters.peek(4) == 's'
                            && characters.peek(5) == 'f'
                            && characters.peek(6) == 'i'
                            && characters.peek(7) == 'e'
                            && characters.peek(8) == 's'
                            && !isIdentifierPart(characters.peek(9))) {
                    characters.consume(9);
                    return token(satisfiesKw, "satisfies");
                } else if (characters.peek(1) == 'w'
                            && characters.peek(2) == 'i'
                            && characters.peek(3) == 't'
                            && characters.peek(4) == 'c'
                            && characters.peek(5) == 'h'
                            && !isIdentifierPart(characters.peek(6))) {
                    characters.consume(6);
                    return token(switchKw, "switch");
                } else if (characters.peek(1) == 'u'
                            && characters.peek(2) == 'p'
                            && characters.peek(3) == 'e'
                            && characters.peek(4) == 'r'
                            && !isIdentifierPart(characters.peek(5))) {
                    characters.consume(5);
                    return token(superKw, "super");
                } else {
                    return identifier(next);
                }
            }
            case ('t') {
                if (characters.peek(1) == 'h') {
                    if (characters.peek(2) == 'r'
                                && characters.peek(3) == 'o'
                                && characters.peek(4) == 'w'
                                && !isIdentifierPart(characters.peek(5))) {
                        characters.consume(5);
                        return token(throwKw, "throw");
                    } else if (characters.peek(2) == 'e'
                                && characters.peek(3) == 'n'
                                && !isIdentifierPart(characters.peek(4))) {
                        characters.consume(4);
                        return token(thenKw, "then");
                    } else if (characters.peek(2) == 'i'
                                && characters.peek(3) == 's'
                                && !isIdentifierPart(characters.peek(4))) {
                        characters.consume(4);
                        return token(thisKw, "this");
                    } else {
                        return identifier(next);
                    }
                } else if (characters.peek(1) == 'r'
                            && characters.peek(2) == 'y'
                            && !isIdentifierPart(characters.peek(3))) {
                    characters.consume(3);
                    return token(tryKw, "try");
                } else {
                    return identifier(next);
                }
            }
            case ('v') {
                if (characters.peek(1) == 'a'
                            && characters.peek(2) == 'l'
                            && characters.peek(3) == 'u'
                            && characters.peek(4) == 'e'
                            && !isIdentifierPart(characters.peek(5))) {
                    characters.consume(5);
                    return token(valueKw, "value");
                } else if (characters.peek(1) == 'o'
                            && characters.peek(2) == 'i'
                            && characters.peek(3) == 'd'
                            && !isIdentifierPart(characters.peek(4))) {
                    characters.consume(4);
                    return token(voidKw, "void");
                } else {
                    return identifier(next);
                }
            }
            case ('w') {
                if (characters.peek(1) == 'h'
                            && characters.peek(2) == 'i'
                            && characters.peek(3) == 'l'
                            && characters.peek(4) == 'e'
                            && !isIdentifierPart(characters.peek(5))) {
                    characters.consume(5);
                    return token(whileKw, "while");
                } else {
                    return identifier(next);
                }
            }
            case (',') { return charToken(comma, ','); }
            case (';') { return charToken(semicolon, ';'); }
            case ('{') { return charToken(lbrace, '{'); }
            case ('}') { return charToken(rbrace, '}'); }
            case ('(') { return charToken(lparen, '('); }
            case (')') { return charToken(rparen, ')'); }
            case ('[') { return charToken(lbracket, '['); }
            case (']') { return charToken(rbracket, ']'); }
            case (':') { return charToken(measureOp, ':'); }
            case ('.') {
                if (characters.peek(1) == '.') {
                    if (characters.peek(2) == '.') {
                        characters.consume(3);
                        return token(ellipsis, "...");
                    } else {
                        characters.consume(2);
                        return token(spanOp, "..");
                    }
                } else {
                    return charToken(memberOp, '.');
                }
            }
            case ('?') {
                if (characters.peek(1) == '.') {
                    characters.consume(2);
                    return token(safeMemberOp, "?.");
                } else {
                    return charToken(questionMark, '?');
                }
            }
            case ('*') {
                switch (characters.peek(1))
                case ('.') {
                    characters.consume(2);
                    return token(spreadMemberOp, "*.");
                }
                case ('=') {
                    // TODO *=
                }
                case ('*') {
                    characters.consume(2);
                    return token(scaleOp, "**");
                }
                else {
                    return charToken(productOp, '*');
                }
            }
            case ('=') {
                switch (characters.peek(1))
                case ('>') {
                    characters.consume(2);
                    return token(compute, "=>");
                }
                case ('=') {
                    if (characters.peek(2) == '=') {
                        characters.consume(3);
                        return token(identicalOp, "===");
                    } else {
                        characters.consume(2);
                        return token(equalOp, "==");
                    }
                }
                else {
                    return charToken(specify, '=');
                }
            }
            case ('+') {
                switch (characters.peek(1))
                case ('=') {
                    // TODO +=
                }
                case ('+') {
                    characters.consume(2);
                    return token(incrementOp, "++");
                }
                else {
                    return charToken(sumOp, '+');
                }
            }
            case ('-') {
                switch (characters.peek(1))
                case ('=') {
                    // TODO -=
                }
                case ('-') {
                    characters.consume(2);
                    return token(decrementOp, "--");
                }
                case ('>') {
                    characters.consume(2);
                    return token(entryOp, "->");
                }
                else {
                    return charToken(differenceOp, '-');
                }
            }
            case ('%') {
                if (characters.peek(1) == '=') {
                    // TODO %=
                } else {
                    return charToken(remainderOp, '%');
                }
            }
            case ('^') {
                if (characters.peek(1) == '=') {
                    // TODO ^=
                } else {
                    return charToken(powerOp, '^');
                }
            }
            case ('!') {
                if (characters.peek(1) == '=') {
                    characters.consume(2);
                    return token(notEqualOp, "!=");
                } else {
                    return charToken(notOp, '!');
                }
            }
            case ('&') {
                if (characters.peek(1) == '&') {
                    characters.consume(2);
                    return token(andOp, "&&");
                } else {
                    return charToken(intersectionOp, '&');
                }
            }
            case ('|') {
                if (characters.peek(1) == '|') {
                    characters.consume(2);
                    return token(orOp, "||");
                } else {
                    return charToken(unionOp, '|');
                }
            }
            case ('~') {
                if (characters.peek(1) == '=') {
                    // TODO ~=
                } else {
                    return charToken(complementOp, '~');
                }
            }
            case ('<') {
                if (characters.peek(1) == '=') {
                    if (characters.peek(2) == '>') {
                        characters.consume(3);
                        return token(compareOp, "<=>");
                    } else {
                        characters.consume(2);
                        return token(smallAsOp, "<=");
                    }
                } else {
                    return charToken(smallerOp, '<');
                }
            }
            case ('>') {
                if (characters.peek(1) == '=') {
                    // TODO the Ceylon.g rule for LARGE_AS_OP does lots of lookahead… why? do we need that?
                    characters.consume(2);
                    return token(largeAsOp, ">=");
                } else {
                    return charToken(largerOp, '>');
                }
            }
            else {
                if (isIdentifierStart(next)) {
                    return identifier(next);
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
    
    "Given an initial character of an identifier,
     consumes that character, then reads on
     until the identifier is finished."
    Token identifier(Character first) {
        characters.consume();
        StringBuilder text = StringBuilder();
        text.appendCharacter(first);
        Boolean lowercase = first.lowercase;
        variable Character next;
        while (isIdentifierPart(next = characters.peek())) {
            text.appendCharacter(next);
            characters.consume();
        }
        return token(lowercase then lidentifier else uidentifier, text.string);
    }
    
    "Given a single character,
     consumes that character,
     then returns a token with that single character."
    Token charToken(TokenType type, Character text) {
        characters.consume();
        return token(type, text.string);
    }
    
    Token token(TokenType type, String text)
            => Token(type, text); // TODO count token index?
    
    Boolean isIdentifierStart(Character character)
            => character.letter || character == '_';
    
    Boolean isIdentifierPart(Character character)
            => character.letter || character.digit || character == '_';
}

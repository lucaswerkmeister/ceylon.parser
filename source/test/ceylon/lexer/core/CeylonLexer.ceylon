import ceylon.lexer.core {
    CeylonLexer,
    StringCharacterStream,
    Token,
    TokenType,
    KeywordType,
    andOp,
    backtick,
    binaryLiteral,
    characterLiteral,
    comma,
    compareOp,
    complementOp,
    compute,
    decimalLiteral,
    decrementOp,
    differenceOp,
    ellipsis,
    entryOp,
    equalOp,
    floatLiteral,
    hexLiteral,
    identicalOp,
    incrementOp,
    intersectionOp,
    largeAsOp,
    largerOp,
    lbrace,
    lbracket,
    lidentifier,
    lineComment,
    lparen,
    measureOp,
    memberOp,
    multiComment,
    notEqualOp,
    notOp,
    orOp,
    powerOp,
    productOp,
    questionMark,
    quotientOp,
    rbrace,
    rbracket,
    remainderOp,
    rparen,
    safeMemberOp,
    scaleOp,
    semicolon,
    smallAsOp,
    smallerOp,
    spanOp,
    specify,
    spreadMemberOp,
    stringEnd,
    stringLiteral,
    stringMid,
    stringStart,
    sumOp,
    uidentifier,
    unionOp,
    verbatimStringLiteral,
    whitespace
}
import ceylon.test {
    test,
    assertEquals,
    assertNull
}

shared class CeylonLexerTest() {
    
    test
    shared void spaces()
            => singleToken("    ", whitespace, "Spaces");
    
    test
    shared void mixedWhitespace()
            => singleToken("    \t\n", whitespace, "Mixed whitespace");
    
    test
    shared void simpleLineComment()
            => singleToken("// Line comment", lineComment, "Simple line comment");
    
    test
    shared void emptyLineComment()
            => singleToken("//", lineComment, "Empty line comment");
    
    test
    shared void simpleShebangComment()
            => singleToken("#!/usr/bin/ceylon", lineComment, "Simple shebang comment");
    
    test
    shared void emptyShebangComment()
            => singleToken("#!", lineComment, "Empty shebang comment");
    
    test
    shared void simpleMultiComment()
            => singleToken("/* Multi comment */", multiComment, "Simple multi comment");
    
    test
    shared void nestedMultiComment()
            => singleToken("/* 1 /* 2 /* 3 */ 2 /* 3 */ 2 */ 1 /* 2 */ 1 */", multiComment, "Nested multi comment");
    
    test
    shared void emptyMultiComment()
            => singleToken("/**/", multiComment, "Empty multi comment");
    
    test
    shared void comments()
            => multipleTokens("Multiple comments",
        "// Line comment"->lineComment,
        "\n"->whitespace,
        "/*
          * multi
          * comment
          */"->multiComment,
        "// Line comment /* containing multi comment */"->lineComment);
    
    test
    shared void simpleLIdentifier()
            => singleToken("null", lidentifier, "Simple LIdentifier");
    
    test
    shared void prefixedLIdentifier()
            => singleToken("\\inull", lidentifier, "Prefixed LIdentifier");
    
    test
    shared void forcedLIdentifier()
            => singleToken("\\iSOUTH", lidentifier, "Forced LIdentifier");
    
    test
    shared void simpleUIdentifier()
            => singleToken("Object", uidentifier, "Simple UIdentifier");
    
    test
    shared void prefixedUIdentifier()
            => singleToken("\\IObject", uidentifier, "Prefixed UIdentifier");
    
    test
    shared void forcedUIdentifier()
            => singleToken("\\Iklass", uidentifier, "Forced UIdentifier");
    
    test
    shared void identifiers()
            => multipleTokens("Multiple identifiers",
        "Anything"->uidentifier,
        " "->whitespace,
        "a"->lidentifier,
        " "->whitespace,
        "\\iSOUTH"->lidentifier);
    
    test
    shared void simpleStringLiteral()
            => singleToken(""""Hello, World!"""", stringLiteral, "Simple string literal");
    
    test
    shared void stringLiteralWithEscapedQuote()
            => singleToken(""""\"Hello, World!\", said Tom."""", stringLiteral, "String literal with escaped quote");
    
    test
    shared void simpleVerbatimStringLiteral()
            => singleToken("\"\"\"Hello, World!\"\"\"", verbatimStringLiteral, "Simple verbatim string literal");
    
    test
    shared void verbatimStringLiteralWithQuotes()
            => singleToken("\"\"\"\"\"Verbatim string literal _content_ can begin or end with up to two quotes\"\"\"\"\"", verbatimStringLiteral, "Verbatim string literal with quotes");
    
    test
    shared void simpleStringStart()
            => singleToken("\"Hello, \`\`", stringStart, "Simple string start");
    
    test
    shared void simpleStringMid()
            => singleToken("\`\`, and welcome to \`\`", stringMid, "Simple string mid");
    
    test
    shared void simpleStringEnd()
            => singleToken("\`\`!\"", stringEnd, "Simple string end");
    
    test
    shared void stringTemplate()
    /*
     "Hello, ``"You"``, and welcome to ``"""here"""``!"
     */
            => multipleTokens("String template",
        "\"Hello, \`\`"->stringStart,
        "\"You\""->stringLiteral,
        "\`\`, and welcome to \`\`"->stringMid,
        "\"\"\"here\"\"\""->verbatimStringLiteral,
        "\`\`!\""->stringEnd);
    
    test
    shared void simpleCharacterLiteral()
            => singleToken("""'c'""", characterLiteral, "Simple character literal");
    
    test
    shared void characterLiteralWithUnicodeEscape()
            => singleToken("""'\{ELEPHANT}'""", characterLiteral, "Character literal with Unicode escape sequence");
    
    test
    shared void characterLiteralWithQuote()
            => singleToken("""'\''""", characterLiteral, "Character literal with escaped quote");
    
    test
    shared void simpleHexLiteral()
            => singleToken("#10_FFFF", hexLiteral, "Simple hexadecimal literal");
    
    test
    shared void simpleBinaryLiteral()
            => singleToken("$10_1010", binaryLiteral, "Simple binary literal");
    
    test
    shared void simpleDecimalLiteral()
            => singleToken("42", decimalLiteral, "Simple decimal literal");
    
    test
    shared void decimalLiteralWithMagnitude()
            => singleToken("10k", decimalLiteral, "Decimal literal with magnitude");
    
    test
    shared void decimalLiteralWithGrouping()
            => singleToken("10_000", decimalLiteral, "Decimal literal with grouping");
    
    test
    shared void simpleFloatLiteral()
            => singleToken("3.141", floatLiteral, "Simple float literal");
    
    test
    shared void floatLiteralWithMagnitude()
            => singleToken("1.5M", floatLiteral, "Float literal with (regular) magnitude");
    
    test
    shared void floatLiteralWithFractionalMagnitude()
            => singleToken("1.5u", floatLiteral, "Float literal with fractional magnitude");
    
    test
    shared void floatLiteralWithExponent()
            => singleToken("6.022E+23", floatLiteral, "Float literal with exponent (Avogadro’s constant)");
    
    test
    shared void shortcutFloatLiteral()
            => singleToken("2u", floatLiteral, "Shortcut float literal with fractional magnitude");
    
    test
    shared void floatLiteralWithGrouping()
            => singleToken("1_234.567_8", floatLiteral, "Float literal with grouping");
    
    test
    shared void singleKeywords() {
        for (kw in `KeywordType`.caseValues) {
            singleToken(kw.string[... kw.string.size - 3], kw, kw.string);
        }
    }
    
    test
    shared void singleNonKeywords() {
        for (kw in `KeywordType`.caseValues) {
            singleToken(kw.string[... kw.string.size - 3] + "_", lidentifier, "LIdentifier beginning with ``kw.string``");
        }
    }
    
    test
    shared void allKeywords() {
        assert (nonempty inputs = expand {
                { " "->whitespace },
                for (kw in `KeywordType`.caseValues)
                    {
                        kw.string[... kw.string.size - 3]->kw,
                        " "->whitespace
                    }
            }.sequence());
        multipleTokens("All keywords", *inputs);
    }
    
    test
    shared void allSymbols()
            => multipleTokens("All symbols",
        ","->comma,
        ";"->semicolon,
        "..."->ellipsis,
        "{"->lbrace,
        "}"->rbrace,
        "("->lparen,
        ")"->rparen,
        "["->lbracket,
        "]"->rbracket,
        "`"->backtick,
        "?"->questionMark, " "->whitespace,
        "."->memberOp,
        "?."->safeMemberOp,
        "*."->spreadMemberOp,
        "="->specify, " "->whitespace,
        "=>"->compute,
        "+"->sumOp,
        "-"->differenceOp,
        "*"->productOp,
        "/"->quotientOp,
        "%"->remainderOp,
        "^"->powerOp,
        "**"->scaleOp,
        "++"->incrementOp,
        "--"->decrementOp,
        ".."->spanOp,
        ":"->measureOp,
        "->"->entryOp,
        "!"->notOp,
        "&&"->andOp,
        "||"->orOp,
        "~"->complementOp,
        "&"->intersectionOp,
        "|"->unionOp,
        "==="->identicalOp,
        "=="->equalOp,
        "!="->notEqualOp,
        "<"->smallerOp,
        ">"->largerOp,
        "<="->smallAsOp, " "->whitespace,
        ">="->largeAsOp,
        "<=>"->compareOp);
    
    void singleToken(String input, TokenType expectedType, String? message = null) {
        value lexer = CeylonLexer(StringCharacterStream(input));
        assertEquals {
            actual = lexer.nextToken();
            expected = Token(expectedType, input);
            message = message;
        };
        assertNull {
            lexer.nextToken();
            message = "No more tokens expected";
        };
    }
    
    void multipleTokens(String? message, <String->TokenType>+ inputs) {
        value lexer = CeylonLexer(StringCharacterStream("".join(inputs*.key)));
        for (code->type in inputs) {
            assertEquals {
                actual = lexer.nextToken();
                expected = Token(type, code);
                message = message;
            };
        }
        assertNull {
            lexer.nextToken();
            message = "No more tokens expected";
        };
    }
}

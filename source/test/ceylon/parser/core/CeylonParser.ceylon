import ceylon.test {
    test,
    assertEquals,
    assertNotNull
}
import ceylon.parser.core {
    CeylonParser
}
import ceylon.ast.core {
    ...
}
import ceylon.lexer.core {
    CeylonLexer,
    NonIgnoredTokenSource,
    StringCharacterStream,
    TokenSourceStream
}
import ceylon.language.meta.model {
    Class
}

shared class CeylonParserTest() {
    
    void assertParseEquals(String code, Node?()(CeylonParser) ceylonParse, Node?(String) redhatParse) {
        value parser = CeylonParser(TokenSourceStream(NonIgnoredTokenSource(CeylonLexer(StringCharacterStream(code)))));
        value ceylonParsed = ceylonParse(parser)();
        value redhatParsed = redhatParse(code);
        assertNotNull(ceylonParsed);
        assertEquals {
            expected = redhatParsed;
            actual = ceylonParsed;
            message = code;
        };
    }
    
    void testParse(String code, Class<Node> nodeType) {
        value name = nodeType.declaration.name;
        assert (exists char = name.first);
        value lName = String { char.lowercased, *name.rest };
        assert (exists ceylonParserMethod = `CeylonParser`.getMethod<CeylonParser,Node?,[]>(lName));
        assert (exists redhatParseFunction = `package ceylon.ast.redhat`.getFunction("compile``name``")?.apply<Node?,[String]>());
        assertParseEquals(code, ceylonParserMethod, redhatParseFunction);
    }
    
    test
    shared void baseType_string() => testParse("String", `BaseType`);
    
    test
    shared void baseType_stringWithSpaces() => testParse("  String  ", `BaseType`);
}

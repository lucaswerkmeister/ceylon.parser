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
    Class,
    ClassModel
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
    
    void testParse(Class<Node> abstractType, <String->Class<Node>>* samples) {
        for (code->actualType in samples) {
            
            value atName = actualType.declaration.name;
            assert (exists redhatParseFunction = `package ceylon.ast.redhat`.getFunction("compile``atName``")?.apply<Node?,[String]>());
            
            variable ClassModel<Anything>? currentType = actualType;
            while (is Class<Node> ct = currentType, ct != abstractType) {
                value name = ct.declaration.name;
                assert (exists char = name.first);
                value lName = String { char.lowercased, *name.rest };
                assert (exists ceylonParserMethod = `CeylonParser`.getMethod<CeylonParser,Node?,[]>(lName));
                assertParseEquals(code, ceylonParserMethod, redhatParseFunction);
                
                currentType = ct.extendedType;
            }
        }
    }
    
    test
    shared void type()
            => testParse(`Type`,
        "String"->`BaseType`,
        "  String  "->`BaseType`,
        "Iterable<String>"->`BaseType`,
        "Iterable<String,Nothing>"->`BaseType`,
        "JIterable<out JString>"->`BaseType`);
    
    test
    shared void typeArguments()
            => testParse(`TypeArguments`,
        "<String,Nothing>"->`TypeArguments`,
        "<String, out Nothing, in Anything>"->`TypeArguments`);
    
    test
    shared void variance()
            => testParse(`Variance`, "in"->`Variance`, "out"->`Variance`);
}

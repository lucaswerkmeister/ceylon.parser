import ceylon.lexer.core {
    uidentifierType=uidentifier,
    ...
}
import ceylon.ast.core {
    ...
}

shared class CeylonParser(TokenStream tokens) {
    
    // TODO attach tokens?
    
    shared BaseType? baseType() {
        if (exists id = uidentifier()) {
            // TODO type arguments
            return BaseType(TypeNameWithTypeArguments(id));
        } else {
            return null;
        }
    }
    
    shared UIdentifier? uidentifier() {
        if (exists token = tokens.peek(), token.type == uidentifierType) {
            tokens.consume();
            if (token.text.startsWith("\\")) {
                return UIdentifier { token.text[2...]; usePrefix = true; };
            } else {
                return UIdentifier(token.text);
            }
        } else {
            return null;
        }
    }
}

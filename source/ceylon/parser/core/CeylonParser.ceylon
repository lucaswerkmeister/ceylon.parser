import ceylon.lexer.core {
    uidentifierType=uidentifier,
    ...
}
import ceylon.ast.core {
    ...
}
import ceylon.collection {
    HashSet
}

alias Tokens => Set<TokenType>;

shared class CeylonParser(TokenStream tokens) {
    
    Tokens begin_uidentifier = HashSet { uidentifierType };
    Tokens begin_baseType = begin_uidentifier;
    Tokens begin_simpleType = begin_baseType;
    Tokens begin_primaryType = begin_simpleType;
    Tokens begin_unionableType = begin_primaryType;
    Tokens begin_mainType = begin_unionableType;
    
    // TODO attach tokens?
    
    shared BaseType? baseType() {
        if (exists id = uidentifier()) {
            // TODO type arguments
            return BaseType(TypeNameWithTypeArguments(id));
        } else {
            return null;
        }
    }
    
    shared MainType? mainType() {
        if (exists token = tokens.peek()) {
            if (token.type in begin_unionableType) { return unionableType(); } else { return null; }
        } else { return null; }
    }
    
    shared PrimaryType? primaryType() {
        if (exists token = tokens.peek()) {
            if (token.type in begin_simpleType) { return simpleType(); } else { return null; }
        } else { return null; }
    }
    
    shared SimpleType? simpleType() {
        if (exists token = tokens.peek()) {
            if (token.type in begin_baseType) { return baseType(); } else { return null; }
        } else { return null; }
    }
    
    shared Type? type() {
        if (exists token = tokens.peek()) {
            if (token.type in begin_mainType) { return mainType(); } else { return null; }
        } else { return null; }
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
    
    shared UnionableType? unionableType() {
        if (exists token = tokens.peek()) {
            if (token.type in begin_primaryType) { return primaryType(); } else { return null; }
        } else { return null; }
    }
}

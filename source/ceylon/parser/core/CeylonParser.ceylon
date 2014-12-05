import ceylon.lexer.core {
    uidentifierType=uidentifier,
    ...
}
import ceylon.ast.core {
    ...
}
import ceylon.collection {
    HashSet,
    LinkedList,
    MutableList
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
    
    shared BaseType baseType() {
        value nextTokenType = tokens.peek()?.type else uidentifierType;
        if (nextTokenType == uidentifierType) {
            value id = uidentifier();
            TypeArguments? typeArguments;
            if (exists smallerOpToken = tokens.peek(), smallerOpToken.type == smallerOp) {
                // type arguments
                tokens.consume();
                MutableList<Type> argumentTypes = LinkedList<Type>();
                // TODO use-site variance
                argumentTypes.add(type());
                while (exists separatorToken = tokens.peek()) {
                    switch (separatorToken.type)
                    case (comma) {
                        tokens.consume();
                        argumentTypes.add(type());
                    }
                    case (largerOp) {
                        tokens.consume();
                        break;
                    }
                    else {
                        // TODO error: expected , or > in type argument list
                    }
                }
                assert (nonempty argTypes = argumentTypes.map(TypeArgument).sequence());
                typeArguments = TypeArguments(argTypes);
            } else {
                typeArguments = null;
            }
            return BaseType(TypeNameWithTypeArguments(id, typeArguments));
        } else {
            // TODO mark as fake
            return BaseType(TypeNameWithTypeArguments(UIdentifier("Nothing")));
        }
    }
    
    shared MainType mainType() {
        value nextTokenType = tokens.peek()?.type else uidentifierType;
        if (nextTokenType in begin_unionableType) { return unionableType(); }
        else { /* default */ return unionableType(); }
    }
    
    shared PrimaryType primaryType() {
        value nextTokenType = tokens.peek()?.type else uidentifierType;
        if (nextTokenType in begin_simpleType) { return simpleType(); }
        else { /* default */ return simpleType(); }
    }
    
    shared SimpleType simpleType() {
        value nextTokenType = tokens.peek()?.type else uidentifierType;
        if (nextTokenType in begin_baseType) { return baseType(); }
        else { /* default */ return baseType(); }
    }
    
    shared Type type() {
        value nextTokenType = tokens.peek()?.type else uidentifierType;
        if (nextTokenType in begin_mainType) { return mainType(); }
        else { /* default */ return mainType(); }
    }
    
    shared UIdentifier uidentifier() {
        if (exists token = tokens.peek(), token.type == uidentifierType) {
            tokens.consume();
            if (token.text.startsWith("\\")) {
                return UIdentifier { token.text[2...]; usePrefix = true; };
            } else {
                return UIdentifier(token.text);
            }
        } else {
            // TODO mark as fake
            return UIdentifier("Nothing");
        }
    }
    
    shared UnionableType unionableType() {
        value nextTokenType = tokens.peek()?.type else uidentifierType;
        if (nextTokenType in begin_primaryType) { return primaryType(); }
        else { /* default */ return primaryType(); }
    }
}

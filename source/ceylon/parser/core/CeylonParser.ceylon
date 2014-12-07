
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

shared Key<Token[]> tokensKey = ScopedKey<Token[]>(`class CeylonParser`, "tokens");

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
            TypeArguments? typeArgs;
            if ((tokens.peek()?.type else whitespace) == smallerOp) {
                typeArgs = typeArguments();
            } else {
                typeArgs = null;
            }
            return BaseType(TypeNameWithTypeArguments(id, typeArgs));
        } else {
            // TODO mark as fake
            return BaseType(TypeNameWithTypeArguments(UIdentifier("Nothing")));
        }
    }
    
    shared MainType mainType() {
        value nextTokenType = tokens.peek()?.type else uidentifierType;
        if (nextTokenType in begin_unionableType) {
            return unionableType();
        } else {
            // default
            return unionableType();
        }
    }
    
    shared OptionalType optionalType() {
        value ret = primaryType();
        if (is OptionalType ret) {
            return ret;
        } else {
            // TODO error expected optional type
            return OptionalType(ret);
        }
    }
    
    shared OptionalType continue_optionalType(PrimaryType definiteType) {
        Token? token;
        if ((tokens.peek()?.type else whitespace) == questionMark) {
            token = tokens.nextToken();
        } else {
            // TODO error expected ?
            token = null;
        }
        return withTokens(OptionalType(definiteType), emptyOrSingleton(token));
    }
    
    shared PrimaryType primaryType() {
        variable PrimaryType ret;
        value nextTokenType = tokens.peek()?.type else uidentifierType;
        if (nextTokenType in begin_simpleType) {
            ret = simpleType();
        } else {
            // default
            ret = simpleType();
        }
        while (exists followingToken = tokens.peek()) {
            switch (followingToken.type)
            case (questionMark) { ret = continue_optionalType(ret); }
            else { break; }
        }
        return ret;
    }
    
    shared SimpleType simpleType() {
        value nextTokenType = tokens.peek()?.type else uidentifierType;
        if (nextTokenType in begin_baseType) {
            return baseType();
        } else {
            // default
            return baseType();
        }
    }
    
    shared Type type() {
        value nextTokenType = tokens.peek()?.type else uidentifierType;
        if (nextTokenType in begin_mainType) {
            return mainType();
        } else {
            // default
            return mainType();
        }
    }
    
    shared TypeArgument typeArgument() {
        value nextTokenType = tokens.peek()?.type else uidentifierType;
        Variance? var;
        if (nextTokenType in { inKw, outKw }) {
            var = variance();
        } else {
            var = null;
        }
        return TypeArgument(type(), var);
    }
    
    shared TypeArguments typeArguments() {
        if (exists opening = tokens.peek(), opening.type == smallerOp) {
            value ownTokens = LinkedList { opening };
            tokens.consume();
            MutableList<TypeArgument> typeArgs = LinkedList<TypeArgument>();
            typeArgs.add(typeArgument());
            while (exists separatorToken = tokens.peek()) {
                switch (separatorToken.type)
                case (comma) {
                    tokens.consume();
                    ownTokens.add(separatorToken);
                    typeArgs.add(typeArgument());
                }
                case (largerOp) {
                    tokens.consume();
                    ownTokens.add(separatorToken);
                    break;
                }
                else {
                    // TODO error: expected , or > in type argument list
                }
            }
            assert (nonempty typeArgsSeq = typeArgs.sequence());
            return withTokens(TypeArguments(typeArgsSeq), ownTokens);
        } else {
            // TODO error expected <
            return TypeArguments([typeArgument()]);
        }
    }
    
    shared UIdentifier uidentifier() {
        if (exists token = tokens.peek(), token.type == uidentifierType) {
            tokens.consume();
            UIdentifier ret;
            if (token.text.startsWith("\\")) {
                ret = UIdentifier { token.text[2...]; usePrefix = true; };
            } else {
                ret = UIdentifier(token.text);
            }
            ret.put(tokensKey, [token]);
            return ret;
        } else {
            // TODO mark as fake
            return UIdentifier("Nothing");
        }
    }
    
    shared UnionableType unionableType() {
        value nextTokenType = tokens.peek()?.type else uidentifierType;
        if (nextTokenType in begin_primaryType) {
            return primaryType();
        } else {
            // default
            return primaryType();
        }
    }
    
    shared Variance variance() {
        value nextToken = tokens.peek();
        value nextTokenType = nextToken?.type else whitespace;
        switch (nextTokenType)
        case (outKw) {
            tokens.consume();
            assert (exists nextToken);
            return withTokens(OutModifier(), [nextToken]);
        }
        case (inKw) {
            tokens.consume();
            assert (exists nextToken);
            return withTokens(InModifier(), [nextToken]);
        }
        else {
            // TODO mark as fake
            return OutModifier();
        }
    }
    
    "A helper function to attach tokens to a node
     and then return it.
     
     Intended usage:
     
         // within some parse function
         return withTokens(NodeType(arg1, arg2), tokens);
         // instead of
         value ret = NodeType(arg1, arg2);
         ret.put(tokensKey, tokens.sequence());
         return ret;"
    T withTokens<T>(T node, {Token*} tokens)
            given T satisfies Node {
        node.put(tokensKey, tokens.sequence());
        return node;
    }
}

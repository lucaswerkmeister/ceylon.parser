import ceylon.collection {
    MutableList,
    ArrayList
}

"A [[TokenStream]] that gets its tokens
 from an underlying [[TokenSource]].
 
 This stream supports [[seek]]ing arbitrary indices;
 [[releasing|Marker.destroy]] a marker is a no-op."
shared class TokenSourceStream(TokenSource source)
        satisfies TokenStream {
    
    variable Integer index = 0;
    
    LazySequence<Token> tokens = LazySequence(source);
    
    shared actual class Marker()
            extends super.Marker() {
        shared actual Integer index = outer.index;
        shared actual void destroy(Throwable? error) {} // do nothing
    }
    
    shared actual void consume(Integer count) => index += count;
    
    shared actual Token? peek(Integer n) => tokens.getFromFirst(index + n);
    
    shared actual void seek(Integer index) => this.index = index;
}

class LazySequence<Element>(Iterator<Element> elements)
        satisfies {Element*}
        given Element satisfies Object {
    
    MutableList<Element> buffer = ArrayList<Element>();
    
    shared actual Iterator<Element> iterator() {
        object it satisfies Iterator<Element> {
            variable Integer index = 0;
            shared actual Element|Finished next() {
                if (exists buffered = buffer[index++]) {
                    return buffered;
                } else {
                    if (is Element element = elements.next()) {
                        buffer.add(element);
                        return element;
                    } else {
                        return finished;
                    }
                }
            }
        }
        return it;
    }
}

"""A stream of tokens
   with arbitrary lookahead and rewind.
   
   A position within the stream may be marked
   by creating a new [[Marker]]
   and later resumed by [[seek]]ing the marker’s [[index|Marker.index]].
   It is strongly recommended that this be done
   within a try-with-resources structure:
   
       try (marker = tokens.Marker()) {
           // ...
           if (!success) {
               tokens.seek(marker.index);
               // ...
           }
       }
   
   The nature of the index is unspecified – despite its name,
   it doesn’t necessarily bear any relation to the current position in the stream,
   and isn’t necessarily strictly monotonically increasing –
   and only a seek to a marked index that hasn’t yet been [[released|Marker.destroy]]
   is guaranteed to succeed.
   
   However, other usage of the token stream is not guaranteed to fail,
   and implementations may find it easier to support seeking
   released markers, or even arbitrary indices."""
shared interface TokenStream
        satisfies TokenSource {
    
    "A marker within the stream.
     
     The marked position may be restored using [[seek]]
     while the marker hasn’t yet been [[released|destroy]].
     
     To guarantee that the marker will be released when no longer needed,
     usage of the try-with-resources construct is recommended."
    shared formal class Marker()
            satisfies Destroyable {
        
        "The index of this marker.
         
         Despite its name, it’s not *necessarily* a proper index,
         and doesn’t have to bear any relation to the current position
         within the stream.
         That is to say, given the markers
         
             value m1 = tokens.Marker();
             tokens.consume(n);
             value m2 = tokens.Marker();
         
         the intuitive relation
         
             assert (m2.index == m1.index + n);
         
         isn’t guaranteed to hold.
         If the nature of the token stream is unknown,
         this index should rather be seen as an “id” of the marker.
         
         However, implementations may find it convenient to simply return
         an index into an internal list, hence the name."
        shared formal Integer index;
        
        "Releases this marker.
         
         After a marker has been released,
         [[seek]]ing its [[index]] may (or may not) fail.
         
         If multiple markers are created, they should be released
         in reverse order of their creation.
         This is done automatically if the markers are managed
         using try-with-resources."
        shared actual formal void destroy(Throwable? error);
    }
    
    "Peek [[n]] tokens ahead, where `n` must be at least 0.
     
     If there are not enough tokens in the stream,
     [[null]] is returned instead."
    shared formal Token? peek(Integer n = 0);
    
    "Consume [[count]] tokens."
    shared formal void consume(Integer count = 1);
    
    shared actual default Token? nextToken() {
        value ret = peek();
        consume();
        return ret;
    }
    
    "Reset the position of the stream to the position at which it was
     when the [[Marker]] with this [[index]] was created.
     
     This is only guaranteed to succeed if the [[index]]
     comes from a [[Marker]] ([[Marker.index]])
     that hasn’t yet been [[released|Marker.destroy]].
     
     However, other usage is unspecified (does not necessarily throw),
     and implementations may also support seeking released or other indices."
    shared formal void seek(Integer index);
}

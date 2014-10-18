"A stream of characters, without any navigation abilities."
shared interface CharacterSource {
    
    "The next character in the stream, or the character
     `PRIVATE USE 1` (U+0091)
     if there are no more characters in the stream.
     
     Returning a special character instead of [[null]]
     allows us to have the return type `Character`,
     which has several advantages over `Character?`:
     - it can be compared directly with the `==` operator
     - on the Java backend, a `switch` on it is compiled
       to a Java `switch` (on `int`) instead of a slower
       `if` / `else if` chain (with equality checks
       on [[ceylon.language::Character]] objects)."
    shared formal Character nextCharacter();
}

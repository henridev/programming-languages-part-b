# deep dive into static type systems 


## ML vs racket 

- similar but mayor difference is static vs dynamic type system
- we could actually achieve a dynamic type like experience in ML 
  if we created one big type containing contructors for each of the primitives 

## static typing 

- when: after success parsing before running - at compile time - actual values are not yet specified
- approaches: static checking 
    * **type system**
        - add **typing rules** for different language constructs eg. each var has type, two conditional branches must be same type
        - ML will check if rules are followed
- purpose: static checking 
    - reject programs that make no sense
    - reject programs that missuse a language feature

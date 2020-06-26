# building data structures in dynamicly typed languages and implementing programing languages with interpreters

## datatype programming 
---
* in static language like ML **datatype bindings**
    - adds new type to the env
    - adds contructorst to the env
    - accessors and checking via **pattern matching**

> instead of returning an int we will return an exp namely the const exp

```ML
fun eval_exp_old e =
    case e of
        Const i => i
        | Negate e2 => ~ (eval_exp_old e2)
        | Add(e1,e2) => (eval_exp_old e1) + (eval_exp_old e2)
        | Multiply(e1,e2) => (eval_exp_old e1) * (eval_exp_old e2)
fun eval_exp_new e =
    let
        fun get_int e =
                case e of
                    Const i => i
                    | _ => raise (Error "expected Const result")
    in
        case e of
            Const _ => e (* notice we return the entire exp here *)
            | Negate e2 => Const (~ (get_int (eval_exp_new e2)))
            | Add(e1,e2) => Const ((get_int (eval_exp_new e1)) + (get_int (eval_exp_new e2)))
            | Multiply(e1,e2) => Const ((get_int (eval_exp_new e1)) * (get_int (eval_exp_new e2)))
    end
```

> In racket things come down to creating creating the constructs / checkers and accessors separatly 
```scheme
; helper functions for constructing
(define (Const i) (list ’Const i))
(define (Negate e) (list ’Negate e))
(define (Add e1 e2) (list ’Add e1 e2))
(define (Multiply e1 e2) (list ’Multiply e1 e2))
; helper functions for testing
(define (Const? x) (eq? (car x) ’Const))
(define (Negate? x) (eq? (car x) ’Negate))
(define (Add? x) (eq? (car x) ’Add))
(define (Multiply? x) (eq? (car x) ’Multiply))
; helper functions for accessing
(define (Const-int e) (car (cdr e)))
(define (Negate-e e) (car (cdr e)))
(define (Add-e1 e) (car (cdr e)))
(define (Add-e2 e) (car (cdr (cdr e))))
(define (Multiply-e1 e) (car (cdr e)))
(define (Multiply-e2 e) (car (cdr (cdr e))))

(define (eval-exp e)
    (cond [(Const? e) e] ; note returning an exp, not a number
          [(Negate? e) (Const (- (Const-int (eval-exp (Negate-e e)))))]
          [(Add? e) (let ([v1 (Const-int (eval-exp (Add-e1 e)))]
                [v2 (Const-int (eval-exp (Add-e2 e)))])
            (Const (+ v1 v2)))]
          [(Multiply? e) (let ([v1 (Const-int (eval-exp (Multiply-e1 e)))]
                               [v2 (Const-int (eval-exp (Multiply-e2 e)))])
                            (Const (* v1 v2)))]
          [#t (error "eval-exp expected an exp")]))

; outputs '(Const -28)
(define test-ans (eval-exp test-exp))
```
> a better aproach is to use structs instead of defining all these helpers

> a **struct** will create the constructor the tester and accessors all in one line
```scheme
(struct foo (bar bah) #:transparent)
; (foo bar bah) as contructor returning a foo
; (foo? x) as a tester
; (foo-bar x) as accessor returning bar field
```

attributes of a struct:

* `#:transparent` = makes accessors and fields accesible outside module - useful to print structs with contents 
* `#:mutable` = all fields are mutable with mutate functions `set-foo-bar!` for example 

> easier way to represent datatypes is by using structs
```scheme
(struct const (int) #:transparent)
(struct negate (e) #:transparent)
(struct add (e1 e2) #:transparent)
(struct multiply (e1 e2) #:transparent)
```

**struct** =/= **list approach**
- struct creates new type of value (pair? for example would return false and car or cdr are not usable) 
- errors are catched sooner in structs 


## Implementing a programming language 
---

- focus of this cours > what do programming languages mean?
- also interesting > how do we implement a programming language? 
    - helps understanding semantics 
    - demistifys alot of constructs
    - programming tasks are often analogous to implementing an interpreter 


flow:

1. concrete syntax made of strings --> parser --> if syntax incorrect then error else produce **AST**
2. (OPTIONAL) AST is a tree representing the program --> type-checker --> error or next
3. two options to get our machine code 
    - **interpreter** --> we have interpreter written in Language A taking code from Language B producing answers
    - **compiler** --> we have interpreter written in Language A taking code from Language B producing code in Language C to then use some implementation of C

**meta-language** = language use to translate or interpret 

![image](https://cdn.programiz.com/sites/tutorial2program/files/interpreter-compiler.jpg)

> for eval-exp we can see this as an interpreter A (written in racket) for our own programming language B (written with structs)

> we take expressions in lang B and produces values according to rules defined in A 
* we have **expresions** for lang B which are build using our constructors
* **values** are for us constants holding int 
* we don't do the parsing and type-checking because we are already using the structs from racket 


### when are AST legal?

> easier way to represent datatypes is by using structs
```scheme
(struct const (int) #:transparent) ; int should hold a number
(struct negate (e1) #:transparent) ; e1 should hold an expression
(struct add (e1 e2) #:transparent) ; e1, e2 should hold expressions
(struct multiply (e1 e2) #:transparent) ; e1, e2 should hold expressions
; three extra expressions
(struct bool (b) #:transparent) ; b should hold #t or #f
(struct if-then-else (e1 e2 e3) #:transparent) ; e1, e2, e3 should hold expressions
(struct eq-num (e1 e2) #:transparent) ; e1, e2 should hold expressions

; now result can be an integer bool 
; OR non-existent if we are trying to treat boolean as number or number as boolean
; some operations work with only one type

; when we evaluate results of subexpressions should be checked if they carry right type 

; eval-exp-wrong
[(add? e)
    (let ([i1 (const-int (eval-exp-wrong (add-e1 e)))]
          [i2 (const-int (eval-exp-wrong (add-e2 e)))])
            (const (+ i1 i2)))]

; eval-exp
[(add? e)
    (let ([v1 (eval-exp (add-e1 e))]
          [v2 (eval-exp (add-e2 e))])
            (if (and (const? v1) (const? v2))
                (const (+ (const-int v1) (const-int v2)))
                (error "add applied to non-number")))]
```

> we don't have full control over AST being legal

- `(add 3 4)`
- `(add #t #f)`
- however or interpreter assumes it is passed legal AST's otherwise it will just crash

our rules right now for AST are
* int field of const has to have racket number
* b field of bool has to have racket bull
* other fields of expressions should hold other legal ATS (recursive)


### implementing variables and environments 

- now one recursive function which jsut returns a value
- **problem** => e contain variables so evaluation requires an **environment** which maps them to values 
- **solution** => recursive helper which given an expression and environment produces a value 
- **environment** => how this is represented depends on the implementation within the 
meta-language not the AST (ex list holding pairs of strings and values) 
    * eval variable expression = look for string in the env
    * eval subexpressions = pass recursive call same env which was passed for evaluating the outer expression
    * eval local scopes = 


- an **env** maps variables to values --> list of pairs (string and value)
- pass to interpreter the current env  
- when we get a variable just look it up in the **env**
- for sub-expressions just pass the same env to the interpreter

```scheme
(define (eval-under-env e env)
   (cond ... ;case for each kind of expression 
    ))
```


### implementing closures

recap on firstclass functions / firstclass citizens
- can be passed to other functions 
- can be returned from other functions 
- can be assigned to variables 
- can be stored in datastructures

why?
* Higher order functions 

dynamic scoping = non-local variables refer to closest defintion of that variable at time of execution of the function
lexical scoping = non-local variables refer to closest definition of that variable at time of definition of the function 

closure = record storing function together with an environment (like a small little world for a function)
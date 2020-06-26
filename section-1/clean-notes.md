# Programming languages part b

## contents

1. week 1
   1. exploring dynamically typed language syntax and semantics
   2. delayed evaluation with **thunks** and **streams** + **memoization**
   3. optional: **Macros**
2. week 2
   1. what is **datatype-programming** in racket 
   2. implement your own language - a **closure system** 
3. week 3
   1. **comparison static** vs **dynamic** type system
   2. **soundness** and **completeness**
   3. pros and cons of static type checking

## getting started with racket 

- functional (functions are first class citizens, everything is expression)
- does not have pattern matching because it is a dynamically typed language

general rule of parenthesis

```scheme
(t1 t2 ... tn)
; if t1 is not of a special form parenthesis signify a function call ;
```



> definitions for functions and simple variables
>
> - functions are values (closures) --> environment + function body
> - functions return their last evaluated expression --> usually the only thing because we avoid side-effects 
> - lambda are anonymous functions --> evaluate to functions 

```scheme
;( define ‹id› ‹expr› )
; - bind id to result of <expr>
(define cake "apple-cake")

;( define (‹id› <id>*) ‹expr›+ ) 
; - bind id to function with args <id>* and body <expr>+ 
(define (eat-cake qty cake) (string-append (to-string cake) "of" cake "eaten"))

; long version no sugar - with lambda anon fun
(define eat-cake
 	(lambda (qty qake)
  		(string-append (to-string cake) "of" cake "eaten")))

; anonymous lambda function
; (lambda (<id>*) <exp>*)
(lambda (x) (print x))
(λ (x) (print x))
```

> Conditional expressions

```scheme
; (if <exp> <exp> <exp>)
; 2 other options to include (and <exp>) (or <exp>)  
(if (= 1 1) #t #f)

;for sequence of tests (cond {[<exp> <exp>*]}) is a better option
(cond {[#f "will not execute"]
       [#f "will not execute"]
       [#t "will execute"]})
```

> binding locally
>
> 4 options
>
> - define locally within a function --> not really convenient we have to write define ... every time
> - let --> easier but bindings can't access each other when defined within the let  / it instead uses the environment from before the let expression for evaluation
> - let* --> later bindings within let can access earlier bindings within list 
> - letrec --> later bindings can access earlier once and earlier once can access later once
>
> a word about top-level binding 
>
> - in racket a  file can be seen as a big letrec --> you can use functions even if they are written further down in the file 
> - in ML this was not the case it could be seen as a let*

```scheme
;(let ({[<id> <expr>]
;		...
;	    [<id> <expr>]}))

;(let* ({[<id> <expr>]
;		...
;	    [<id> <expr>]}))

;(letrec ({[<id> <expr>]
;		...
;	    [<id> <expr>]}))
```

> is it a list or is it a pair ? 
>
> - cons creates a general **pair**
> - a **list** is a more specific form of a pair where the  last element is null

```scheme
(cons 1 (cons 2 null)) ; proper list
(cons 1 (cons 2 3)) ; improper list because it's with a pair
```

> enforcing **mutability** via **set!** (= assignment operator which mutates a binding)
>
> - shadowing =/= mutating => mutation actually changes the value inside of memory itself
> - be careful now we are making **side-effects**
> - to make cons cells aka pairs mutable we can use **mcons** and **set-mcar!**

```scheme
; eg
(define number 2)

(define (print-num number) (print (to-string number)))

(define (print-num-copy number) 
  (let ([number number])
  	(print (to-string number))))

(set! number 1)

(print-num number)
; will print 1 because body evaluation happens when function is called

(print-num-copy number)
; will print 2 because we made a copy before mutation could occur
```

## evaluation tinkering with tunks and streams

approach 1 - **eager evaluation** = if we execute a function we first evaluate it's arguments before proceeding to evaluation of the body

approach 2 - **lazy evaluation** = if we take a conditional we evaluate e1 but we do not kwon if we will do e2 or e3

```scheme
(define (bad-iffy x y z) (if x y z))
(define (good-iffy x y z) (if x (y) (z)))

(define (use-iffy x)
  (bad-iffy (= x 0)
			 1
             (* x (use-iffy (- x 1))))))
; will not work

(define (use-iffy x)
  (bad-iffy (= x 0)
			 (lambda () 1)
             (lambda () (* x (use-iffy (- x 1))))))
; will work thanks to delayed evaluation
```

> concept of **promises** | **lazy-evaluation** | **call-by-need**
>
> via **mutation** save the result of computing the first time in a pair so we ensure to only do the computation once
>
> we can take two functions to enforce lazy evaluation and make sure that we do not make heavy computations unnecessarily
>
> **delay** creates the promise to return the result of the evaluation as soon as you force me to 
>
> **force** check if computation is already made and forces the delay to return a value either way

```scheme
(define (delay f)
  (mcons #f f)) 
; this creates a thunk aka a pair with bool if already computed and f the function if not computed or f the value if already computed 

(define (force th)
  (if (mcar th)
      (mcdr th)
      (begin (set-mcar! th #t)
             (set-mcdr! th ((mcdr th))) ;exec f in thunk
             (mcdr th)))) ; return result

(define promise-x (delay (lambda () e)))
(force promise-x)

```

> **Stream** = infinite sequence of values 
>
> usually 2 parts
>
> - it knows how to create the stream values but does not know how many it has to create or what they are used for
> - it knows what to do with the created values and how many there are necessary

```scheme
(define ones (lambda () (cons 1 ones)))
(define nats
	(letrec ([f (lambda (x) (cons x (lambda () (f (+ x 	1)))))])
 		(lambda () (f 1))))

(define (number-until stream tester)
	(letrec ([f (lambda (stream ans)
		(let ([pr (stream)])
			(if (tester (car pr))
				ans
				(f (cdr pr) (+ ans 1)))))])
	(f stream 1)))
;fn tells us how to create the nex 
;arg gives us the first arg of the stream
(define (stream-maker fn arg) 
	(letrec ([f (lambda (x)
					(cons x (lambda () (f (fn x arg)))))])
      				; this gives a pair with curr element 
      				; and a thunk with a function ready to continue stremaing 
			(lambda () (f arg))))
```

## memoization

idea: we have a function without side-effects, if this function is called with the same arguments then it will produce the same result. Therefore we can create a **memo-table** in which we save the results. This table will be used to look up result for certain arguments.

implementation: use mutation to create a memo-table represented by a list with pairs each pair consisting of args and result. 

```scheme
(define fibo
	(letrec {[memo-table null]
      		 [f (lambda (x)
                  (let ([ans (assoc x memo-table)])
                    (if ans
                        (cdr ans)
                        (let ([new-ans (if (or (= x1) (= x 2))
                                           1
                                           (X (f (- x 1))
                                              (f (- x 2))))])
                          (begin
                           (set! memo-table (cons (cons x new-ans) memo-table))
                           new-ans)))))]}))
```

## macros

- **macro-definition** = description on how to transform new syntax into different syntax already in the language
- **macro-system** = languages to define macros 
- **macro-use** = using one of defined macros (replace the macro use with the appropriate syntax as defined by the macro definition  )
- **macro-expansion** =converting the macro into actual readable code 

```scheme
; eg

(define-syntax my-if
	(syntax-rules (then else) ; anything not in is an exp
		[(my-if e1 then e2 else e3)
			(if e1 e2 e3)]))

(my-if e1 then e2 else e3)
(my-delay e)
; might expand to
(if e1 e2 e3)
(mcons #f (lambda () e))
```

## datatype programming - working with structs

3 parts are needed for our own **recursive datatypes**

- access values
- constructor
- type-checker

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

; ’ is a symbol

(define (eval-exp e)
 (cond [(Const? e) e] ; note returning an exp, not a number
  [(Negate? e) (Const (- (Const-int (eval-exp (Negate-e
                                               e)))))]
  [(Add? e) (let ([v1 (Const-int (eval-exp (Add-e1 e)))]
  [v2 (Const-int (eval-exp (Add-e2 e)))])(Const (+ v1 v2)))]
  [(Multiply? e) (let ([v1 (Const-int (eval-exp (Multiply-e1
                                                 e)))]
                       [v2 (Const-int (eval-exp (Multiply-e2
                                                 e)))])
                   (Const (* v1 v2)))]
  [#t (error "eval-exp expected an exp")]))
```

> a **struct** will do a lot of scaffolding for us automatically
>
> - struct-id => constructor for type of constructor
> - struct-id? => to check at run-time is it of type struct-id
> - struct-id-field-id => to access a value from a field 
>
> a regular structure gives no constraints on type of data that can be used in fields --> if we want this use **contracts**
>
> two attributes for structl
>
> - transparent --> so that fields and accessor functions visible outside the module defining the struct. (big + allows the REPL to print struct values with their contents rather than just as an abstract value. )
> - mutable --> makes all fields mutable by also providing mutator functions  (set-struct-id-field-id!)

```scheme
;(struct struct-id (field-id ...) <#:transparent> <#:mutable>)

(struct const (int) #:transparent)
(struct negate (e) #:transparent)
(struct add (e1 e2) #:transparent)
(struct multiply (e1 e2) #:transparent)
```

## how to - implement your own interpreter 

 step by step language implementation:

parser takes strings with syntax of program and checks for syntax errors --> creation of AST --> type check AST to check possible type-errors 

<img src="C:\Users\henri\AppData\Roaming\Typora\typora-user-images\image-20200624085850870.png" alt="image-20200624085850870" style="zoom:50%;" />

given a metalanguage A we have two options

- interpreter = take code written in B use interpreter written in language A as executor for code coming from B
- compiler = take code written in B use compiler written in language A to translate B into language C then use some pre-existing implementation of C 



> an AST has to be legal --> we need to verify sub-expressions within the interpreter to see if the return type is correct 

```scheme
(struct const (int) #:transparent)
(struct negate (e) #:transparent)
(struct add (e1 e2) #:transparent)
(struct multiply (e1 e2) #:transparent)
(struct bool (b) #:transparent) ; b should hold #t or #f
(struct if-then-else (e1 e2 e3) #:transparent) ; e1, e2, e3 should hold expressions
(struct eq-num (e1 e2) #:transparent) ; e1, e2 should hold expressions

(define (eval-exp e)
  (cond [(const? e) 
         e] 
        [(negate? e) 
         (let ([v (eval-exp (negate-e1 e))])
           (if (const? v)
               (const (- (const-int v)))
               (error "negate applied to non-number")))]
        [(add? e) 
         (let ([v1 (eval-exp (add-e1 e))]
               [v2 (eval-exp (add-e2 e))])
           (if (and (const? v1) (const? v2))
               (const (+ (const-int v1) (const-int v2)))
               (error "add applied to non-number")))]
        [(multiply? e) 
         (let ([v1 (eval-exp (multiply-e1 e))]
               [v2 (eval-exp (multiply-e2 e))])
           (if (and (const? v1) (const? v2))
               (const (* (const-int v1) (const-int v2)))
               ((error "multiply applied to non-number"))))]
        [(bool? e) 
         e]
        [(eq-num? e) 
         (let ([v1 (eval-exp (eq-num-e1 e))]
               [v2 (eval-exp (eq-num-e2 e))])
           (if (and (const? v1) (const? v2))
               (bool (= (const-int v1) (const-int v2))) ; creates (bool #t) or (bool #f)
               (error "eq-num applied to non-number")))]
        [(if-then-else? e) 
         (let ([v-test (eval-exp (if-then-else-e1 e))])
           (if (bool? v-test)
               (if (bool-b v-test)
                   (eval-exp (if-then-else-e2 e))
                   (eval-exp (if-then-else-e3 e)))
               (error "if-then-else applied to non-boolean")))]
        [#t (error "eval-exp expected an exp")] ; not strictly necessary but helps debugging
        ))
```


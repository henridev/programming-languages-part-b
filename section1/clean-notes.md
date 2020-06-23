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
> via mutation save the result of computing the first time in a pair so we ensure to only do the computation once
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
```


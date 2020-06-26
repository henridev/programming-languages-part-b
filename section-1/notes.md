* Getting Started: Definitions, Functions, Lists (and if) 
* Syntax and Parentheses 
* Dynamic Typing (and cond) 
* Local bindings: let, let*, letrec, local define 
* Top-Level Definitions 
* Bindings are Generally Mutable: set! Exists 
* The Truth about cons 
* Cons cells are immutable, but there is mcons 
* Introduction to Delayed Evaluation and Thunks 
* Lazy Evaluation with Delay and Force 
* Streams 
* Memoization
* Macros: The Key Points 


# basic syntax and semantics:

- collection of definitions / bindings
    - a definition = `(define x e)` -> evaluate e and bind resulting value to x 
- **first-class functions**
    - supports programming idioms like currying, hof, callbacks ...
    - currying 
        - eg:  `(define pow
                    (lambda (x)
                        (lambda (y)
                            (if (= y 0)
                                1
                                (* x ((pow x) (- y 1)))))))`
        - but because we have multi argument functions currying is not as common 
        - **syntaxtic sugar** 
            * no `pow x y` like ML instead `((pow x) y)` otherwise it takes it as you  providing two arguments at once 
            * for defining function we do have some `(define ((pow x) y)
                                                            (if (= y 0)
                                                                1
                                                                (* x ((pow x) (- y 1)))))`

- everything is **prefix** = you can use bindings defined later in the file 
- anonymous function = `(lambda (x) e)` 
    - can be recursive because definition is in scope of function body 
    - eg:
      `(define cube1 (lambda (x) (*x (* x x))))` or **syntaxtic sugar** 
      `(define (cube1 x) (*x (* x x))))`
- if then else does not exist instead `(if e1 e2 e3)`
    - evaluate e1 check if T or F if T evaluate e2 for result else evaluate e3 for result


| Primitive   | Primitive   | Example     | 
| ----------- | ----------- | ----------- |
| null        | empty list  | null        | 
| cons        | construct list | (cons 2 (cons 3 null)) | 
| car         | get first element | (car some-list) | 
| cdr         | get list tail     | (cdr some-list) | 
| null?       | Return **#t** for the empty-list and **#f** otherwise | (null? some-value) | 


`(list 1 2 3)` -->  build in func to create list from any number of elements && does not have to be of same type 

# syntax of the parenthesis hell

2 parts in language
    * **form of atom** 
        - for which identifier is particular form it can be a variable or a **special form** aka `define, lambda, if` 
    * `(t1 t2 ... tn)` is a **sequence** of things
        - if t1 = **special form** then it affects the semantics of the rest of the sequence 
        - if t1 = **NOT** special form && sequence part of expression then it's a function call  

take away 
> Parentheses change the meaning of your program. You cannot add or remove them because you feel like it. They are never optional or meaningless.
 
# **COND** and dynamic typing 

cond = style for nested conditionals

`
[e1 e2] ; --> we skip to e2 if e1 was true 
[the branch if e1 was false]
[branch with #t to prevent falling to the bottom] --> default case if nothing ever is true 
` 
if first one is true then do the second one
else do the next branch 
repeat


# local bindings

4 different options:
- `let`
- `let *`
- `letrec`
- local `define`

**the let option**
- expression 
            `(let ([x1 e1]
                [x2 e2]
                ...
                [xn en])
             e)` 
- will create local vars x1 ... xn which are result of evaluation e1 and e2    
- !SOS! in which env do we eval the e ? --> everything before let <=> ML where we could use bindings defined in the let  
- when to use --> expressions are independent of each other 
              --> it does not matter if previous bindings are in the env for the next ones in let

**the let* option**
- this is the one which will take in previous bindings within it's local scope for ones defined late 

**letrec and define localy**
- is only used if we want or need some recursion inside our local bindings
- since with other once normally we can't make references to later bindings in earlier once normally
- although we can woth this refer to vairbales later defined the evaluation of the expressions still happens in order  

eg. `(define (bad-letrec x)
        (letrec ([y z]
                 [z 13])
            (if x y z)))`

> The semantics for letrec requires that the use of z for initializing y refers to the z in the letrec, but the expression for z (the 13) has not been evaluated yet.

# top-level definitions 

* in racket a file is like a **letrec** --> we can use variables that are actually defined later on |however be careful evaluation still happens in order top-down  
* in ML a fileis like a ***rec** --> we can only use variables defined before

# Mutability with !set

`set! x 0` = is the assignement operator in Racket in order to mutate a binding 

> when using set on a binding think about when you look up that binding to know what it's evaluation will be 

to avoid ending up using a mutated variable in a function do the following 

eg
<pre>
<code>
    (define b 3)
    (define f (lambda (x) (* 1 (+ x b))))
    (set! b 5) ; this will have replaced bound value for 
    (define z (f 4)) ; because evaluation of anonymous function only happens now b will be 5

    ; how can we mitigate for this ?

    (define f 
        (let ([b, b])) ; just copy the b beforehand
            (lambda (x) (* 1 (+ x b))))
</code>
</pre>

there is a nice thing about this set operator - thingy --> if for one top-level binding in a file set was never used then that top level binding will also not be mutable in other files that make use of this binding

so we can be assured that we don't mutate + and * given that set! is never used on them and their bindings are made in separate modules 

# cons are pairs aka cons cells 

list = nested pair ending with `null`

`(cons 1 (cons 2 null))` --> proper list
`(cons 1 (cons 2 3))` --> improper list because it's with a pair

- pair? --> returns true for anything made with cons
- length --> runtime error when used on pairs

# cons cells immutable mcons mutable

- subtle + --> list? is On operation because rest assured mutations to make a pair down the list won't occur 

# evaluation and tunks the zero-argument function idiom 

when does expression get evaluated?
- for functions 
    - **eager evaluation** of the arguments before execution
    - body evaluated once function gets called 
- for conditionals
    - e1 gets evaluated 
    - e2 and e3 do not get evaluated 


<pre>
<code> ; this will not work
    (define (my-if-bad x y z) (if x y z))
    (define (factorial-wrong x)
        my-if-bad (= x 0)
                  1
                  (* x (factorial-wrong (- x 1))))
; rules for evaluating sub-expressions of an if say only evaluate e1 
; but in my bad if we want the z argument to evaluate to but this one again 
; executes another function waiting for z ... and on and on 
</code>
</pre>

⬇️ use of concept that function bodies not evaluated until call ⬇️
**tunk** = a zero-arguments function used to delay evaluation 
**tunking an e** = use (lambda () e) instead of e

<pre>
<code>
    (define (my-if x y z) (if x (y) (z)) 
    ; this is something we can do evaluation of y and z is delayed until we get 
    ; to their use in the conditional 

    (define (factorial-right x
        my-if(= x 0)
            (lambda () 1)
            (lambda () * x (factorial-right (- x 1)))))

    ; lambda only gets evaluated when function is called 
</pre>
</code>

> because func body are not evaluated until they are called we can make **zero-argument functions** in order to delay evaluations 


# lazy eval / call by need / promises

-> use mutation to remember result of using the tunk the first time

<pre>
<code>
    ; great to thunk
    (define (f th)
        (if (..) 0 (.. (th) ..)))

    ; not great to thunk 
    (define (f th)
      (..(if (..) 0 (.. (th) ..)))
        (if (..) 0 (.. (th) ..)))
        (if (..) 0 (.. (th) ..))))
</pre>
</code>

dillema: we have large evaluation which we might conduct 0 or + times 
    * option 1 use a thunk
        - we will have to re-execute every time
        + we won't execute unnecesary 
    * option 2 just pass as if no thunk
        + only execute once
        - execute even when not needed 

🟢 use the **promise** **lazy eval** **call by need** paradigm
--> this is not the default for functoin arguments but we can code it to be this way 

<pre>
<code>
    ; thanks to the mutation the changes made to th will cary over next time my-force is called 

    (define (my-delay f) ; after thunk creation pass it to delay
        (mcons #f f))    ; pass the tunk to a pair with false meaning not evaluated yet 

    (define (my-force th) ; pass in result of my-delay 
        (if (mcar th)     ; if this is true then just return the second element of the pair
            (mcdr th)     ; second element will now be result of evaluated thunk
            ; begin means evaluate first e1 then e2 ...
            ; three tasks say evaluated by mutate element 1 pair / mutate element 2 of the pair to carry the value of executing or thunk / return the result of the tunk 
            (begin (set-mcar! th #t) 
                   (set-mcdr! th ((mcdr th))) ; 
                   (mcdr th))))
</pre>
</code>


<pre>
<code>
    ; how to make use forcing and delay-promise to avoid expensive computations
    (define (f p)
      (..(if (..) 0 (.. (my-force p) ..)))
        (if (..) 0 (.. (my-force p) ..)))
        (if (..) 0 (.. (my-force p) ..))))
    (f (my-delay (lambda)))
</pre>
</code>


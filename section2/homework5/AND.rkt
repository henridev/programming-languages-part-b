;; Programming Languages, Homework 5

#|

Remarks on logic
- (fun s1 s2 e) when e gets evaluated we need an environment to which s2 will be bound
  to our argument when called and s1 will be bound to function aka closure when called
- (call e1 e2) e1 will be a func closure so before actualy calling the body of the closure
  we need to extract the env of the closure extend
   > with k-v pair containing function-name and closure itself
   > with k-v pair containing argument-name and argument value (e2)
- (mlet s e1 e2) when e2 is evaluated be sure to have bound k-v pair s and e1 to the environment 
|#

#lang racket
(provide (all-defined-out)) ;; so we can put tests in a second file

;; definition of structures for MUPL programs - Do NOT change
(struct var  (string) #:transparent)  ;; a variable, e.g., (var "foo")
(struct int  (num)    #:transparent)  ;; a constant number, e.g., (int 17)
(struct add  (e1 e2)  #:transparent)  ;; add two expressions
(struct ifgreater (e1 e2 e3 e4)    #:transparent) ;; if e1 > e2 then e3 else e4
(struct fun  (nameopt formal body) #:transparent) ;; a recursive(?) 1-argument function
(struct call (funexp actual)       #:transparent) ;; function call
(struct mlet (var e body) #:transparent) ;; a local binding (let var = e in body) 
(struct apair (e1 e2)     #:transparent) ;; make a new pair
(struct fst  (e)    #:transparent) ;; get first part of a pair
(struct snd  (e)    #:transparent) ;; get second part of a pair
(struct aunit ()    #:transparent) ;; unit value -- good for ending a list
(struct isaunit (e) #:transparent) ;; evaluate to 1 if e is unit else 0

;; a closure is not in "source" programs but /is/ a MUPL value; it is what functions evaluate to
(struct closure (env fun) #:transparent) 

;; Problem 1

(define (racketlist->mupllist r-l)
  (if (null? r-l)
       (aunit)
       (apair (car r-l) (racketlist->mupllist (cdr r-l)))))


(define (mupllist->racketlist m-l)
  (if (aunit? m-l)
       null
       (cons (apair-e1 m-l) (mupllist->racketlist (apair-e2 m-l)))))

; (mupllist->racketlist (apair (int 3) (apair (int 4) (aunit))))

;; Problem 2


;; lookup a variable in an environment
;; Do NOT change this function
(define (envlookup env str)
  (cond [(null? env) (error "unbound variable during evaluation" str)]
        [(equal? (car (car env)) str) (cdr (car env))] ; if var name found return value associated
        [#t (envlookup (cdr env) str)])) ; else keep looping through rest of list

;; Do NOT change the two cases given to you.  
;; DO add more cases for other kinds of MUPL expressions.
;; We will test eval-under-env by calling it directly even though
;; "in real life" it would be a helper function of eval-exp.
; (var e body)
(define (eval-under-env e env)
  (letrec ([create-new-env (lambda (variable-name value)
                               (let([key-value-pair (cons variable-name value)])
                                 (cons key-value-pair env)))]
           [extend-closure (lambda (a-closure fun-name fun-argument-name argument-value)
                             (let ([key-val-arg (cons fun-argument-name argument-value)]
                                   [key-val-fun (cons fun-name a-closure)]
                                   [closure-envi (closure-env a-closure)])
                               (if fun-name
                                   (cons key-val-fun (cons key-val-arg closure-envi)) 
                                   (cons key-val-arg closure-envi))))]
           [handle-fun (lambda (e) (closure env e))]
           [handle-var (lambda (e) (envlookup env (var-string e)))]
           [handle-pair (lambda (e) (let([v1 (eval-under-env (apair-e1 e) env)]
                                         [v2 (eval-under-env (apair-e2 e) env)])
                                      (apair v1 v2)))]
           [handle-fst(lambda (e) (let([v1 (eval-under-env (fst-e e) env)])
                                      (if (apair? v1)
                                          (apair-e1 v1)
                                          (error "enter a pair"))))]
           [handle-snd(lambda (e) (let([v1 (eval-under-env (snd>der-env (mlet-e e) env)]
                                           [variable-name (mlet-var e)]
                                           [new-env (create-new-env variable-name  value)]
                                           [body (mlet-body e)])
                                      (eval-under-env body new-env)))])
    (cond [(int? e) e]
          [(closure? e) e]
          [(aunit? e) e]
          [(fst? e) (handle-fst e)]
          [(snd? e) (handle-snd e)]
          [(apair? e) (apair (eval-under-env (apair-e1 e) env) (eval-under-env (apair-e2 e) env))] 
          [(isaunit? e) (if (aunit? (eval-under-env (isaunit-e e) env)) (int 1) (int 0))]          [(var? e) (handle-var e)]
          [(add? e) (handle-add e)]
          [(ifgreater? e) (handle-is-greater e)]
          [(fun? e) (handle-fun e)]  
          [(call? e) (handle-call e)]
          [(mlet? e) (handle-mlet e)]
          [#t (error (format "bad MUPL expression: ~v" e))])))

  


;; mlet test
;(check-equal? (eval-exp (mlet "x" (int 1) (add (int 5) (v
0ar "x")))) (int 6) "mlet test")
   

;; Do NOT change
(define (eval-exp e)
  (eval-under-env e null))
        
;; Problem 3
(define (ifaunit e1 e2 e3) (ifgreater (isaunit e1) (int 0) e2 e3))

; takes list of pairs
(define (mlet* lstpairs e2) (if (empty? lstpairs)
                               e2 
                               (mlet (car (car lstpairs)) (cdr (car lstpairs)) (mlet* (cdr lstpairs) e2))))


#|
(eval-exp (mlet "f1"
                               (fun "f1" "a" (mlet "x" (var "a") (fun "f2" "z" (add (var "x") (int 1)))))
                               (mlet "f3" (fun "f3" "f" (mlet "x" (int 1729) (call (var "f") (aunit)))) 
                                     (call (var "f3") (call (var "f1") (int 1)))))))
(let ([v1 (eval-under-env (ifgreater-e1 e) env)]
                                                [v2 (eval-under-env (ifgreater-e2 e) env)])
                                            (if (and(int? v1)
                                                    (int? v2))
                                                (if (> (int-num v1) (int-num v2))
                                                    (eval-under-env (ifgreater-e3 e) env)
                                                    (eval-under-env (ifgreater-e4 e) env))
                                                ((error "comparing non non-int"))))

|#
(define (ifeq e1 e2 e3 e4) (mlet "f1"
                                 (fun #f "x" e1)
                                 (mlet "f2"
                                       (fun #f "y" e2)
                                       (if (= (int-num(call (var "f1")))
                                              (int-num(call (var "f2"))))
                                           (mlet "f3"
                                                 (fun #f "z" e3)
                                                 (call (var "f3")))
                                           (mlet "f4"
                                                 (fun #f "w" e4)
                                                 (call (var "f4")))))))
  
;; Problem 4

(define mupl-map
  (fun #f "map-fun"
       (fun "map-rec" "list"
            (ifaunit (var "list")
                     (aunit)
                     (apair (call (var "map-fun") (fst (var "list")))
                            (call (var "map-rec") (snd (var "list"))))))))

(define mupl-mapAddN 
  (mlet "map" mupl-map
        "CHANGE (notice map is now in MUPL scope)"))

;; Challenge Problem

(struct fun-challenge (nameopt formal body freevars) #:transparent) ;; a recursive(?) 1-argument function

;; We will test this function directly, so it must do
;; as described in the assignment
(define (compute-free-vars e) "CHANGE")

;; Do NOT share code with eval-under-env because that will make
;; auto-grading and peer assessment more difficult, so
;; copy most of your interpreter here and make minor changes
(define (eval-under-env-c e env) "CHANGE")

;; Do NOT change this
(define (eval-exp-c e)
  (eval-under-env-c (compute-free-vars e) null))

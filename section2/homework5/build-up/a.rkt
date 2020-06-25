;; Programming Languages, Homework 5

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

(define (add-to-env env str val)
  (cond [(null? env) (cons (cons str val) null)]
        [(equal? (car (car env)) str) (cons (cons str val) (cdr (cdr env)))] ; if var name found return value associated
        [#t (cons (car env) (add-to-env (cdr env) str))]))



;; Do NOT change the two cases given to you.  
;; DO add more cases for other kinds of MUPL expressions.
;; We will test eval-under-env by calling it directly even though
;; "in real life" it would be a helper function of eval-exp.
(define (eval-under-env e env)
  (cond [(var? e) (envlookup env (var-string e))]
        [(add? e) 
         (let ([v1 (eval-under-env (add-e1 e) env)]
               [v2 (eval-under-env (add-e2 e) env)])
           (if (and (int? v1)
                    (int? v2))
               (int (+ (int-num v1) 
                       (int-num v2)))
               (error "MUPL addition applied to non-number")))]
        [(int? e) e]
        [(closure? e) e]
        [(fun? e)
         (let* ([f-name (fun-nameopt e)]
                [f-arg (fun-formal e)]
                [body (fun-body e)]
                [create-closure (lambda (local-env) (closure local-env e))])
           (if f-name
               (let* ([local-env-0 (add-to-env env f-name body)]
                      [local-env (add-to-env env f-arg null)])
                 (create-closure local-env))
               (let ([local-env (add-to-env env f-arg null)])
                 (create-closure local-env))))]
        [(call? e)
         (letrec ([funexp (call-funexp e)]
                  ; evaluate the fun arg in the current environment
                  [arg (eval-exp (call-actual e) env)] 
                  ; map evaluated argument to the closure env
                  [map-arg-env (lambda (arg env) (cond [(null? env) null] 
                                                       [(null? (cdr (car env))) (let* ([var-name (car (car) env)]
                                                                                       [env-end (cdr(cdr env))]
                                                                                       [key-val (cons var-name arg)])
                                                                                  (cons key-val env-end))] 
                                                       [#t (cons (car env) (map-arg-env (cdr env) env))]))])
                  (cond ([(not closure? funexp) (error "not a closure")]
                         [#t (let ([local-env (map-arg-env arg env)])
                               (eval-exp ))])))]
        [(ifgreater? e) 
         (let ([v1 (eval-under-env (ifgreater-e1) env)]
               [v2 (eval-under-env (ifgreater-e2) env)])
           (if (and (int? v1) (int? v2))
               (if (> (int-num v1) (int-num v2))
                   (eval-under-env (ifgreater-e3) env)
                   (eval-under-env (ifgreater-e4) env))
               ((error "comparing non non-int"))))]
        [#t (error (format "bad MUPL expression: ~v" e))]))


;; mlet test
;(check-equal? (eval-exp (mlet "x" (int 1) (add (int 5) (var "x")))) (int 6) "mlet test")
   

;; Do NOT change
(define (eval-exp e)
  (eval-under-env e null))
        
;; Problem 3

(define (ifaunit e1 e2 e3) "CHANGE")

(define (mlet* lstlst e2) "CHANGE")

(define (ifeq e1 e2 e3 e4) "CHANGE")

;; Problem 4

(define mupl-map "CHANGE")

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

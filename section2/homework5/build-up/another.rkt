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

;; Do NOT change the two cases given to you.  
;; DO add more cases for other kinds of MUPL expressions.
;; We will test eval-under-env by calling it directly even though
;; "in real life" it would be a helper function of eval-exp.
; (var e body)
(define (eval-under-env e env)
  (letrec ([create-new-env (lambda (variable-name value)
                           (cond
                             [(null? env) (cons (cons variable-name value) null)]
                              [(equal? (car (car env)) variable-name)
                               (let([key-value-pair (cons variable-name value)])
                                 (cons key-value-pair (cdr (cdr env))))]
                              [#t (cons (car env) (create-new-env (cdr env) variable-name))]))]
           [extend-closure (lambda (a-closure fun-name fun-argument-name argument-value)
                             (let ([key-val-arg (cons fun-argument-name argument-value)]
                                   [key-val-fun (cons fun-name a-closure)])
                               (if fun-name
                                   (cons key-val-fun (cons key-val-arg env)) 
                                   (cons key-val-arg env))))]
           [handle-fun (lambda (e) (closure env e))]
           [handle-var (lambda (e) (envlookup env (var-string e)))]
           [handle-add (lambda (e) (let ([v1 (eval-under-env (add-e1 e) env)]
                                         [v2 (eval-under-env (add-e2 e) env)])
                                     (if (and (int? v1)
                                              (int? v2))
                                         (int (+ (int-num v1) 
                                                 (int-num v2)))
                                         (error "MUPL addition applied to non-number"))))]
           [handle-is-greater (lambda (e) (let ([v1 (eval-under-env (ifgreater-e1) env)]
                                                [v2 (eval-under-env (ifgreater-e2) env)])
                                            (if (and(int? v1)
                                                    (int? v2))
                                                (if (> (int-num v1) (int-num v2))
                                                    (eval-under-env (ifgreater-e3) env)
                                                    (eval-under-env (ifgreater-e4) env))
                                                ((error "comparing non non-int")))))]
           [handle-call (lambda (e) (letrec ([a-closure (eval-under-env (call-funexp e) env)]
                                             [argument-value (eval-under-env (call-actual e) env)])
                                      (if (closure? a-closure)
                                          (let* ([fun-name (fun-nameopt (closure-fun a-closure))]
                                                 [fun-argument-name (fun-formal (closure-fun a-closure))]
                                                 [new-env (extend-closure a-closure fun-name fun-argument-name argument-value)]
                                                 [closure-fun-body (fun-body (closure-fun a-closure))])
                                            (eval-under-env new-env closure-fun-body))
                                          (error "not a closure")
                                          )))]
           [handle-mlet (lambda (e) (let* ([value (eval-under-env (mlet-e e) env)]
                                           [variable-name (mlet-var e)]
                                           [new-env (create-new-env (variable-name  value))]
                                           [body (mlet-body e)])
                                      (eval-under-env body new-env)))])
    (cond [(int? e) e]
          [(closure? e) e]
          [(aunit? e) e]
          [(fun? e) (handle-fun e)]  
          [(var? e) (handle-var e)]
          [(add? e) (handle-add e)]
          [(ifgreater? e) (handle-is-greater e)]
          [(call? e) (handle-call e)]
          [(mlet? e) (handle-mlet e)]
          [#t (error (format "bad MUPL expression: ~v" e))])))

  


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

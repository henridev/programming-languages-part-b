
#lang racket

(provide (all-defined-out)) ;; so we can put tests in a second file

;; put your code below
(define ones (λ () (cons 1 ones)))

(define (sequence low high stride)
    (let ([nextElement (+ low stride)]) ; set local variable 
        (cond [(> low high) (list)] ; empty list if initialy high was under low 
              [(> nextElement high) (cons low null)]
              [#t (cons low (sequence nextElement high stride))] )))


#| other option
(define (sequence-two low high stride)
    (letrec ([invalid? (λ () (if (> low high) (list) (createSequence low)))]
             [createSequence (λ (low) (if (> (+ low stride) high) (cons low null) (cons low (createSequence (+ low stride))))) ])
        (invalid?)))
|#

(define (string-append-map stringList suffix) 
    (map (λ (x)
         (string-append x suffix))
          stringList))

#| other option
(define (string-append-map-two stringList suffix) 
    (let ([add-suffix (λ(x) (string-append x suffix))])
        (map add-suffix stringList)))
|#

(define (list-nth-mod my-list n)
    (let* ([valid? (λ () (cond  [(null? my-list) (error "list-nth-mod: empty list")]
                                     [(zero? n) (error "list-nth-mod: negative number")]
                                     [#t #t]))]
           [index (remainder n (length my-list))]
           [sub-list-nth-mod (λ () (car (list-tail my-list index)))])
                (if (valid?) (sub-list-nth-mod) null)))


(define (stream-for-n-steps s n)
  (if (= n 0)
      null
      (let ([pr (s)])
            (cons (car pr) (stream-for-n-steps (cdr pr) (- n 1))))))



(define funny-number-stream 
    (letrec ([f (λ (x) (cons (divide x) (λ () (f (+ x 1)))))]
             [divide (λ (num) (if (= 0 (remainder num 5)) (* -1 num) num))])
        (λ () (f 1))))

(define dan-then-dog
    (letrec ([f (λ (x) (cons (dan? x) (λ () (f (not x)))))]
             [dan? (λ (is-dan) (if is-dan "dan.jpg" "dog.jpg"))])
        (λ () (f #t))))



(define (stream-add-zero s)
    (letrec ([f (λ (s)
                    (let ([pr (s)])
                        (cons (add-zero (car pr)) (λ () (f (cdr pr))))))]                
            [add-zero (λ (x) (cons 0 x))])
    (λ () (f s))))

(define (cycle-lists xs ys)
    (letrec ([reset-index? (λ (i l) (if (= (+ i 1) (length l)) 0 (+ i 1)))]
             [combine (λ (i-1 i-2) (cons (list-ref xs i-1) (list-ref ys i-2)))]
             [f (λ (i-1 i-2) (cons (combine i-1 i-2) (λ () (f (reset-index? i-1 xs) (reset-index? i-2 ys)))))])
        (λ () (f 0 0))))


;def ASSOC: Locates the first element of lst whose car is equal to v according to is-equal?. 
;If such an element exists, the pair (i.e., an element of lst) is returned. Otherwise, the result is #f.
(define (vector-assoc v vec)
    (letrec ([is-equal? (λ (my-pair) (equal? v (car my-pair)))]
             [vec-length (vector-length vec)]
             [check (λ (i) 
                        (let ([pr (vector-ref vec i)])
                            (if (and (pair? pr) (is-equal? pr)) pr (loop (+ i 1)))))]
             [loop (λ (n) (if (= (+ n 1) vec-length) #f (check n)))])
        (loop 0)))

(define (cached-assoc xs n)
    (letrec ([cache (make-vector n #f)]
             [cache-i 0]
             [update-cache (λ () (if (> (+ cache-i 1) n) (set! cache-i (+ cache-i 1)) (set! cache-i 0)))]
             [f (λ (v)
                 (let ([ans (vector-assoc v cache)])
                     (if ans
                         ans
                         (let ([new-ans (assoc v xs)])
                             (begin 
                                (when new-ans
                                 (vector-set! cache cache-i new-ans)
                                 (update-cache)
                                  new-ans))))))])
    f))

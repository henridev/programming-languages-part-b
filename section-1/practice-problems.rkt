#lang racket

#|
 helpers and random streams
|#

(define ones (lambda () (cons 1 ones)))
(define twos (lambda () (cons 2 twos)))
(define threes (lambda () (cons 3 threes)))


(define nats
  (letrec ([f (lambda (x) (cons x (lambda () (f (+ x 1)))))])
    (lambda () (f 1))))


(define (stream-make fn arg)
  (letrec ([f (lambda (x)
                (cons x (lambda () (f (fn x arg)))))])
    (lambda () (f arg))))

(define powers-of-two (stream-make * 2))

(define (stream-maker f-make-next start-el)
  (letrec ([f (λ (curr-el next-el)
                (cons curr-el (λ () (f next-el (f-make-next curr-el next-el)))))])
    (λ () (f start-el 1))))

(define (fibonacci-stream start-el)
  (letrec ([f (λ (curr-el next-el)
                (cons curr-el (λ () (f next-el (+ curr-el next-el)))))])
    (λ () (f start-el 1))))

(define (fibo-stream) (stream-maker + 0))
(define (fibo-stream-bad) (stream-maker(λ (x y) (+ x y)) 0))




;function to actually create a list from a stream 

(define (list-from-stream el-count stream)
  (if (= el-count 0)
      null
      (cons (car (stream)) (list-from-stream (- el-count 1) (cdr (stream))))))


; ------------ practice problems --------------

#| problem-1
 takes a list of numbers
 returns list of numbers
 where each Element-i should be --> Ei = list[i] + list[n-i]
|#

(define (palindromic num-list)
  (letrec ([reversed-list (reverse num-list)]
           [i-end (- (length num-list) 1)]
           [helper (λ (i l1 l2) (if (= i i-end)
                                         (cons (+ (car l1) (car l2)) null)
                                         (cons (+ (car l1) (car l2)) (helper (+ i 1) (cdr l1) (cdr l2)))))])
    (helper 0 num-list reversed-list)))

(define (palindromic-bad num-list)
  (letrec ([end-num-list (- (length num-list) 1)]
         [copy-num-list num-list]
         [get-el (λ (pos) (list-ref copy-num-list pos))]
         [helper (λ (start) (let ([finish (- end-num-list start)])
                                   (if (= finish 0)
                                       (cons (+ (get-el start) (get-el finish)) null)
                                       (cons (+ (get-el start) (get-el finish)) (helper (+ 1 start))))))])
    (helper 0)))


#|problem-2
 make a stream with fibonacci numbers 
|#


(define fibonacci
  (letrec ([f (lambda (a b) (cons a (lambda () (f b (+ a b)))))])
    (lambda () (f 0 1))))



#| problem-3
 take fn and stream --> apply fn to val of stream until (fn v) = #f
|#

(define (stream-until fn stream)
    (if (fn (car stream))
        (stream-until fn (cdr (stream)))
        (print (car (stream)))))


#|problem-4
 Write a function stream-map that takes a function f|f and a stream s,
 and returns a new stream whose values are the result of applying f to the values produced by s
|#



(define (stream-map fn stream)
  (λ () (cons (fn (car (stream))) (stream-map fn (cdr (stream))))))

;((stream-map (lambda (x) (+ 1 x)) ones))

#| problem-5
 Write a function stream-zip that takes in two streams s1 and s2 and
 returns a stream that produces the pairs that result from the other
 two streams (so the first value for the result stream will be the pair of
 the first value of s1 and the first value of s2).
|#

(define (stream-zip s-1 s-2)
  (λ () (cons (cons (car (s-1)) (car (s-2))) (stream-zip (cdr (s-1)) (cdr (s-2))))))

#| problem-7
 Write a function interleave that takes a list of streams and produces a new stream
 that takes one element from each stream in sequence. So it will first produce
 the first value of the first stream,
 then the first value of the second stream and so on,
 and it will go back to the first stream when it reaches the end of the list.
 Try to do this without ever adding an element to the end of a list
|#
(define s-list (list fibonacci twos))


(define (inter s-list)
  (letrec ([get-s-value (lambda (i s-list) (car((list-ref s-list i))))]
           [new-list (lambda (i s-list) (list-set s-list i (cdr((list-ref s-list i)))))]
           [end-i (- (length s-list) 1)]
           [f (λ (i s-list)(if (= i end-i)
                               (cons (get-s-value i s-list) (λ () (f 0 (new-list i s-list)) ))
                               (cons (get-s-value i s-list) (λ () (f (+ 1 i) (new-list i s-list))))))])
    (λ () (f 0 s-list))))

; ((cdr((inter s-list))))
;((cdr((cdr((cdr((cdr((cdr((cdr((inter s-list))))))))))))))

; ------------ end practice problems --------------


; testers


; (fibonacci)
; ((cdr(fibonacci)))
; ((cdr((cdr(fibonacci)))))
; ((cdr((cdr((cdr(fibonacci)))))))
; ((cdr ((interleave s-list))))





; tester
; (list-from-stream 4 (fibo-stream))
#lang racket



#|
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


#|
 make a stream with fibonacci numbers 
|#

; general purpose stream maker 
(define (stream-maker f-make-next start-el)
  (letrec ([f (λ (curr-el next-el)
                (cons curr-el (λ () (f next-el (f-make-next curr-el next-el)))))])
    (λ () (f start-el 1))))


(define (fibo-stream) (stream-maker + 0))
(define (fibo-stream-bad) (stream-maker(λ (x y) (+ x y)) 0))

; testers
; ((fibo-stream))
; ((cdr((fibo-stream))))
; ((cdr((cdr((fibo-stream))))))
; ((cdr((cdr((cdr((fibo-stream))))))))

#|
 function to actually create a list from a stream 
|#

(define (list-from-stream el-count stream)
  (if (= el-count 0)
      null
      (cons (car (stream)) (list-from-stream (- el-count 1) (cdr (stream))))))


; tester
; (list-from-stream 4 (fibo-stream))
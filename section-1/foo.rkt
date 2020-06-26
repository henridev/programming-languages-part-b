#lang racket

(provide (all-defined-out))

(define s "hello")


(define (sum xs)
  (if (null? xs)
      0
      (+ (car xs) (sum (cdr xs)))))
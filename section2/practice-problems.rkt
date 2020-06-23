#lang racket

(provide (all-defined-out))

(struct btree-leaf () #:transparent)
(struct btree-node (value left right) #:transparent)

#| (define (tree-height b-tree) 
    (letrec ([sub-tree-height (λ (acc curr) (cond [(btree-leaf? curr) set-max-height(acc)]
                                                  [#t (begin (if (btree-node? (btree-node-right curr)) (sub-tree-height (+ 1 acc) (btree-node-right curr)) (sub-tree-height acc (btree-node-right curr)))
                                                             (if (btree-node? (btree-node-left curr)) (sub-tree-height (+ 1 acc) (btree-node-left curr)) (sub-tree-height acc (btree-node-right curr))))]))]
            [set-max-height (λ (acc) (if (> acc max-height) (set! max-height acc) (null)))]
            [max-height 0])
        (begin (sub-tree-height 0 b-tree)
               (max-height)))) |#

(define (tree-height b-tree) 
    (cond [(btree-leaf? b-tree) 0]
          [#t (let [left-height (tree-height (btree-node-left b-tree))]
                   [right-height (tree-height (btree-node-right b-tree))]
                   (+ 1
                    
                   ))])
                                                                    (sub-tree-height (+ 1 acc) (btree-node-right curr)) 
                                                                    (sub-tree-height acc (btree-node-right curr)))
                                                             (if (btree-node? (btree-node-left curr)) 
                                                                    (sub-tree-height (+ 1 acc) (btree-node-left curr))
                                                                    (sub-tree-height acc (btree-node-right curr))))]))]
            [set-max-height (λ (acc) (if (> acc max-height) (set! max-height acc) (null)))]
            [max-height 0])
        (begin (sub-tree-height 0 b-tree)
               (max-height))))

(define b-tree (btree-node #t  
                    (btree-node #t  
                        (btree-node #t (btree-leaf) (btree-leaf)) 
                        (btree-node #t (btree-leaf) (btree-leaf))) 
                    (btree-node #t  
                        (btree-node #t (btree-leaf) (btree-leaf))
                        (btree-node #t (btree-leaf) (btree-leaf)))))

(define b-tree-2 (btree-node #t
                             (btree-node #t
                                         (btree-node #t
                                                     (btree-leaf)
                                                     (btree-leaf))
                                         (btree-node #t
                                                     (btree-leaf)
                                                     (btree-leaf)))
                             (btree-node #t
                                         (btree-node #t
                                                     (btree-leaf)
                                                     (btree-leaf))
                                         (btree-node #t
                                                     (btree-leaf)
                                                     (btree-leaf)))))
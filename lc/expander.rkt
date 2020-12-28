#lang racket

(provide postfix-expand-inner postfix-expand)

(define (postfix-expand-inner in out)
  (cond
    ((empty? in) (list in out))
    (#t
     (let ([h (car in)]
           [t (cdr in)])
       (match h
         ['app
          (postfix-expand-inner
           t
           (cons (cons 'app (take out 2)) (drop out 2)))]
         ['abs
          (postfix-expand-inner
           t
           (cons (cons 'abs (take out 1)) (drop out 1)))]
         [(var v)
          (postfix-expand-inner
           t
           (cons v out))])))))

(define (postfix-expand in)
  (cadr (postfix-expand-inner in '())))

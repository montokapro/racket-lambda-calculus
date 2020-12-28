#lang racket

(provide contract-inner prefix-contract postfix-contract format)

; eval relies heavily on the prefix convention of racket s-exps
(define (contract-inner in out eval)
  (cond
    ((empty? in) (list in out))
    (#t
     (let ([h (car in)]
           [t (cdr in)])
       (match h
         [`(app ,f ,x)
          (contract-inner (append (eval h) t) out eval)]
         [`(abs ,e)
          (contract-inner (append (eval h) t) out eval)]
         [(var v)
          (contract-inner t (cons v out) eval)])))))

; list? → list?
(define (prefix-contract in)
  (cadr (contract-inner in '() reverse)))

; list? → list?
(define (postfix-contract in)
  (cadr (contract-inner in '() identity)))

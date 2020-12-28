#lang racket

(provide contract contract-inner postfix-contract postfix-contract-inner format)

(define (contract-inner in out)
  (cond
    ((empty? in) (list in out))
    (#t
     (let ([h (car in)]
           [t (cdr in)])
       (match h
         [`(app ,f ,x)
          (contract-inner (list* x f 'app t) out)]
         [`(abs ,e)
          (contract-inner (list* e 'abs t) out)]
         [(var v)
          (contract-inner t (cons v out))])))))

; list? → list?
(define (contract in)
  (cadr (contract-inner in '())))

(define (postfix-contract-inner in out)
  (cond
    ((empty? in) (list in out))
    (#t
     (let ([h (car in)]
           [t (cdr in)])
       (match h
         [`(app ,f ,x)
          (postfix-contract-inner (list* 'app f x t) out)]
         [`(abs ,e)
          (postfix-contract-inner (list* 'abs e t) out)]
         [(var v)
          (postfix-contract-inner t (cons v out))])))))

; list? → list?
(define (postfix-contract in)
  (cadr (postfix-contract-inner in '())))

(define (token->string t)
  (cond
    ((number? t) (number->string t))
    (#t (symbol->string t))))

(define (format tokens)
  (string-join
   (map
    token->string
    tokens)))

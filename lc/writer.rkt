#lang racket

(provide contract contract-inner format)

(define (contract-inner in out)
  (cond
    ((empty? in) (list in out)) ; TODO: error handling
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

(define (token->string t)
  (cond
    ((number? t) (number->string t))
    (#t (symbol->string t))))

(define (format tokens)
  (string-join
   (map
    token->string
    tokens)))

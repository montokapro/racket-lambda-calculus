#lang racket

(provide format)

(define (token->string t)
  (cond
    ((number? t) (number->string t))
    (#t (symbol->string t))))

(define (format tokens)
  (string-join
   (map
    token->string
    tokens)))

; for now, use a string of ones and zeros
; each term starts with one boolean and is terminated by the opposite boolean
(define (token->prefix-string t)
  (match t
    ['app
     "110"]
    ['abs
     "10"]
    [(var v)
     (string-join (append (make-list v "0") '("1")) "")]))

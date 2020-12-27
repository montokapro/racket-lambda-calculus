#lang racket

(require syntax/strip-context)

(provide (rename-out [read-inner read]
                     [read-syntax-inner read-syntax]))

(define (string->token s)
  (let ([maybe-number (string->number s)])
    (cond
      ((number? maybe-number) maybe-number)
      (#t (string->symbol s)))))

(define (lexe in)
  (map
   string->token
   (string-split (port->string in))))

(define (expand-inner expand-acc)
  (let ([token (car expand-acc)]
        [remainder (cdr expand-acc)])
    (match token
      ['app
       (letrec ([expand-acc-a (expand-inner remainder)]
                [expr-a (car expand-acc-a)]
                [remainder-a (cdr expand-acc-a)]
                [expand-acc-b (expand-inner remainder-a)]
                [expr-b (car expand-acc-b)]
                [remainder-b (cdr expand-acc-b)])
         (cons
          `(app ,expr-a ,expr-b)
          remainder-b))]
      ['abs
       (letrec ([expand-acc-a (expand-inner remainder)]
                [expr-a (car expand-acc-a)]
                [remainder-a (cdr expand-acc-a)])
         (cons
          `(abs ,expr-a)
          remainder-a))]
      [(var v)
       expand-acc])))

(define (expand tokens)
  (car (expand-inner tokens)))

(define (read-syntax-inner src in)
  (with-syntax ([expr (expand (lexe in))])
    (strip-context
     #'(module anything racket
         (provide data)
         (define data 'expr)))))

(define (read-inner in)
  (syntax->datum
   (read-syntax-inner #f in)))

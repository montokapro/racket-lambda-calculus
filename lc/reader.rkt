#lang racket
(require syntax/strip-context)

(provide (rename-out [read-inner read]
                     [read-syntax-inner read-syntax]))

(define (read-inner in)
  (syntax->datum
   (read-syntax-inner #f in)))

(define (read-syntax-inner src in)
  (with-syntax ([tokens (string-split (port->string in))])
    (strip-context
     #'(module anything racket
         (provide data)
         (define data 'tokens)))))

#lang racket/base

(require
 data/either
 data/applicative
 data/monad
 megaparsack
 megaparsack/text)

(require "main.rkt")

(provide
 app/p
 abs/p
 var/p)

(define whitespace/p (many/p space/p))

(define positive-digit/p
  (label/p "positive number" (char-in/p "123456789")))

(define positive-integer/p
  (label/p "integer"
           (do [positive-digit <- positive-digit/p]
               [digits <- (many/p digit/p)]
               (pure (string->number (apply string (cons positive-digit digits)))))))

(define app/p
  (do (string/p "app")
      whitespace/p
      [a <- expr/p]
      whitespace/p
      [b <- expr/p]
      (pure (eval-by-name `(app ,b ,a)))))

(define abs/p
  (do (string/p "abs")
      whitespace/p
      [a <- expr/p]
      (pure `(abs ,a))))

(define var/p positive-integer/p)

; TODO: factor out try/p to improve error message
(define expr/p
  (or/p
   (try/p app/p)
   (try/p abs/p)
   var/p))

#lang racket

(require
 data/either
 data/applicative
 data/monad
 megaparsack
 megaparsack/text)

(require "main.rkt")

(provide
 var/p
 abs/p
 app+/p
 expr/p
 env-var/p
 env-abs/p
 env-app+/p
 env-expr/p)

(define whitespace/p (many/p space/p))

(define var/p letter/p)

(define (env-var/p env)
  ((pure (λ (char)
           ((λ (a)
              (cond
                ((number? a) (+ a 1))
                (#t char)))
            (index-of env char))))
   var/p))

(define abs/p
  (do (char/p #\λ)
      whitespace/p
      [names <- (many+/p var/p #:sep whitespace/p)]
      whitespace/p
      (char/p #\.)
      whitespace/p
      [expr <- ((pure (λ (a) (list a)))
                var/p)]
      (pure (append
             (map (lambda (x) 'abs) names)
             expr))))

(define (env-abs/p env)
  (do (char/p #\λ)
      whitespace/p
      [names <- (many+/p var/p #:sep whitespace/p)]
      whitespace/p
      (char/p #\.)
      whitespace/p
      [expr <- ((pure (λ (a) (list a)))
                (env-var/p (append (reverse names) env)))]
      (pure (append
             (map (lambda (x) 'abs) names)
             expr))))

(define parens/p
  (do (char/p #\()
      [expr <- app+/p]
      (char/p #\))
      (pure expr)))

(define (env-parens/p env)
  (do (char/p #\()
      [expr <- (env-app+/p env)]
      (char/p #\))
      (pure expr)))

(define app+/p
  (do [a <- (or/p
             (try/p parens/p)
             ((pure (λ (a) (list a)))
              var/p))]
      (or/p
       (try/p
        (do whitespace/p
            [b <- app+/p]
            (pure (append '(app) b a))))
       (pure a))))

(define (env-app+/p env)
  (do [a <- (or/p
             (try/p (env-parens/p env))
             ((pure (λ (a) (list a)))
              (env-var/p env)))]
      (or/p
       (try/p
        (do whitespace/p
            [b <- (env-app+/p env)]
            (pure (append '(app) b a))))
       (pure a))))

(define expr/p
  (or/p
   (try/p app+/p)
   (try/p abs/p)
   var/p))

(define (env-expr/p env)
  (or/p
   (try/p (env-app+/p env))
   (try/p (env-abs/p env))
   (env-var/p env)))

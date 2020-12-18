#lang racket

(require racket/match)

(provide shift shift-up shift-down substitute reduce eval)

(define (shift expr offset n op)
  (match expr
    [`(app ,f ,x)
     `(app ,(shift f offset n op) ,(shift x offset n op))]
    [`(abs ,e)
     `(abs ,(shift e (+ offset 1) n op))]
    [(var v)
     (if
      (>= v offset)
      (op v n)
      v)]))

(define (shift-up expr)
  (shift expr 1 1 +))

(define (shift-down expr)
  (shift expr 1 1 -))

(define (substitute-inner expr env offset)
  (match expr
    [`(app ,f ,x)
     `(app ,(substitute-inner f env offset) ,(substitute-inner x env offset))]
    [`(abs ,e)
     `(abs ,(substitute-inner e env (+ offset 1)))]
    [(var v)
     (if
      (and (>= v offset) (< (- v offset) (length env)))
      (shift (list-ref env (- v offset)) 1 offset +)
      v)]))

(define (substitute expr env)
  (substitute-inner expr env 0))

(define (reduce expr env)
  (substitute (shift-down expr) env))

(define (eval exp)
  (match exp
    [`(app ,f ,x)
     (match f
       [`(abs ,body)
        (eval (reduce body `(,x)))]
       [_
        `(app ,(eval f) ,(eval x))])]
    [`(abs ,e)
     `(abs ,(eval e))]
    [_
     exp]))

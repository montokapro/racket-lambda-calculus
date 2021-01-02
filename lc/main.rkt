#lang racket

(require racket/match)

(provide
 shift shift-up shift-down substitute reduce
 eval-all
 eval-by-name-fixpoint eval-by-name
 eval-by-value-fixpoint eval-by-value
 ast)

(define (shift expr offset n op)
  (match expr
    [`(app ,f ,x)
     `(app ,(shift f offset n op) ,(shift x offset n op))]
    [`(abs ,e)
     `(abs ,(shift e (+ offset 1) n op))]
    [(? number? v)
     (if
      (>= v offset)
      (op v n)
      v)]
    [_
     `(shift ,expr ,offset ,n ,op)]))

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
    [(? number? v)
     (if
      (and (>= v offset) (< (- v offset) (length env)))
      (shift (list-ref env (- v offset)) 1 offset +)
      v)]
    [_
     `(substitute-inner ,expr ,env ,offset)]))

(define (substitute expr env)
  (substitute-inner expr env 0))

(define (reduce expr env)
  (substitute (shift-down expr) env))

(define recur
  ((lambda (f)
     (f f))
   (lambda (z)
     (lambda (f)
       (f
        (lambda (x)
          ;; (display "recur-print: ")
          ;; (displayln x)
          (((z z) f) x)))))))

(define eval-all-fixpoint
  (lambda (f)
    (lambda (expr)
      (match expr
        [`(app ,a ,b)
         (match a
           [`(abs ,c)
            (f (reduce c (list b)))]
           [_
            `(app ,(f a) ,(f b))])]
        [`(abs ,a)
         `(abs ,(f a))]
        [_
         expr]))))

(define eval-all
  (recur eval-all-fixpoint))

(define eval-by-name-fixpoint
  (lambda (f)
    (lambda (expr)
      (match expr
        [`(app (abs ,a) ,b)
         (f (reduce a (list b)))]
        [_
         expr]))))

(define eval-by-name
  (recur eval-by-name-fixpoint))

(define eval-by-value-fixpoint
  (lambda (f)
    (lambda (expr)
      (match expr
        [`(app (abs ,a) ,b)
         (reduce a (list (f b)))]
        [_
         expr]))))

(define eval-by-value
  (recur eval-by-value-fixpoint))

(define (ast exprs)
  (match (car exprs)
    ['app
     (let* ([fexprs (ast (cdr exprs))]
            [xexprs (ast (cadr fexprs))])
       (list
        `(app ,(car fexprs) ,(car xexprs))
        (cadr xexprs)))]
    ['abs
     (let ([eexprs (ast (cdr exprs))])
       (list
        `(abs ,(car eexprs))
        (cadr eexprs)))]
    [(var v)
     (list v (cdr exprs))]))

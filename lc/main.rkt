#lang racket

(require racket/match)

(provide
 shift substitute
 eval-all
 eval-by-name-fixpoint eval-by-name
 eval-by-value-fixpoint eval-by-value
 ast)

; https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.296.2485&rep=rep1&type=pdf - slide 9

(define (shift expr offset n)
  (match expr
    [`(app ,f ,x)
     `(app ,(shift f offset n) ,(shift x offset n))]
    [`(abs ,e)
     `(abs ,(shift e (+ offset 1) n))]
    [(? number? v)
     (cond
      ((> v offset) (- (+ v n) 1))
      (#t v))]
    [_
     `(shift ,expr ,offset ,n)]))

(define (substitute expr term offset)
  (match expr
    [`(app ,f ,x)
     `(app ,(substitute f term offset) ,(substitute x term offset))]
    [`(abs ,e)
     `(abs ,(substitute e term (+ offset 1)))]
    [(? number? v)
     (cond
       ((> v offset) (- v 1))
       ((= v offset) (shift term 0 offset))
       (#t v))]
    [_
     `(substitute ,expr ,term ,offset)]))

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
            (f (substitute c b 1))]
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
         (f (substitute a b 1))]
        [_
         expr]))))

(define eval-by-name
  (recur eval-by-name-fixpoint))

(define eval-by-value-fixpoint
  (lambda (f)
    (lambda (expr)
      (match expr
        [`(app (abs ,a) ,b)
         (substitute a (f b) 1)]
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

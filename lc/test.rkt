#lang racket/base

(require rackunit/text-ui)
(require rackunit "main.rkt")

(run-tests
 (test-suite
  "shift-up"
  (test-case "var"
    (check-equal?
     (shift-up 1)
     2))
  (test-case "abs - bound"
    (check-equal?
     (shift-up '(abs 1))
     '(abs 1)))
  (test-case "abs - free"
    (check-equal?
     (shift-up '(abs 2))
     '(abs 3)))
  (test-case "app"
    (check-equal?
     (shift-up '(app 1 1))
     '(app 2 2)))
  (test-case "deep"
    (check-equal?
     (shift-up '(abs (app 1 (abs (app 2 3)))))
     '(abs (app 1 (abs (app 2 4))))))))

(run-tests
 (test-suite
  "shift-down"
  (test-case "var"
    (check-equal?
     (shift-down 2)
     1))
  (test-case "abs - bound"
    (check-equal?
     (shift-down '(abs 1))
     '(abs 1)))
  (test-case "abs - free"
    (check-equal?
     (shift-down '(abs 2))
     '(abs 1)))
  (test-case "app"
    (check-equal?
     (shift-down '(app 2 2))
     '(app 1 1)))
  (test-case "deep"
    (check-equal?
     (shift-down '(abs (app 1 (abs (app 2 4)))))
     '(abs (app 1 (abs (app 2 3))))))))

(run-tests
 (test-suite
  "substitute"
  (test-case "var - without env"
    (check-equal?
     (substitute 0 '())
     0))
  (test-case "bound var - with env"
    (check-equal?
     (substitute 0 '((abs 1)))
     '(abs 1)))
  (test-case "free var - with env"
    (check-equal?
     (substitute 1 '((abs 1)))
     1))
  (test-case "bound var - with deep env"
    (check-equal?
     (substitute 0 '((abs 2)))
     '(abs 2)))
  (test-case "free var - with deep env"
    (check-equal?
     (substitute 1 '((abs 2)))
     1))
  (test-case "abs - bound"
    (check-equal?
     (substitute '(abs 1) '((abs 1)))
     '(abs (abs 1))))
  (test-case "abs - free"
    (check-equal?
     (substitute '(abs 2) '((abs 1)))
     '(abs 2)))
  (test-case "abs - bound with deep env"
    (check-equal?
     (substitute '(abs 1) '((abs 2)))
     '(abs (abs 3))))
  (test-case "abs - free with deep env"
    (check-equal?
     (substitute '(abs 2) '((abs 2)))
     '(abs 2)))
  (test-case "abs - deep bound with bound env"
    (check-equal?
     (substitute '(abs (abs 2)) '((abs 1)))
     '(abs (abs (abs 1)))))
  (test-case "abs - deep bound with free env"
    (check-equal?
     (substitute '(abs (abs 2)) '((abs 2)))
     '(abs (abs (abs 4)))))
  (test-case "abs - deep free"
    (check-equal?
     (substitute '(abs (abs 3)) '((abs 1)))
     '(abs (abs 3))))
  (test-case "app"
    (check-equal?
     (substitute '(app 0 0) '((abs 1)))
     '(app (abs 1) (abs 1))))
  (test-case "deep"
    (check-equal?
     (substitute '(abs (abs (app 4 (app 2 (abs (app 1 3)))))) '((abs 1)))
     '(abs (abs (app 4 (app (abs 1) (abs (app 1 (abs 1)))))))))))

(run-tests
 (test-suite
  "reduce"
  (test-case "complex"
    (check-equal?
     ; (λ λ 4 2 (λ 1 3)) (λ 5 1)
     ; @!!@4@2!@13!@51
     (reduce '(abs (app (app 4 2) (abs (app 1 3)))) '((abs (app 5 1))))
     ; λ 3 (λ 6 1) (λ 1 (λ 7 1))
     ; !@3@!@61!@1!@71
     '(abs (app (app 3 (abs (app 6 1))) (abs (app 1 (abs (app 7 1))))))))))

(run-tests
 (test-suite
  "eval-all"
  (test-case "irreducible"
    (check-equal?
     (eval-all '(abs (app 1 1)))
     '(abs (app 1 1))))
  (test-case "identity"
    (check-equal?
     (eval-all '(app (abs 1) 1))
     '1))
  (test-case "deep identity"
    (check-equal?
     (eval-all '(app (abs 1) (abs 2)))
     '(abs 2)))
  ; https://cs.stackexchange.com/questions/52941/lambda-calculus-reduction-examples
  (test-case "stackexchange"
    (check-equal?
     (eval-all '(app (abs (app 1 2)) (abs (app 1 3))))
     '(app 1 2)))
  ; http://pages.cs.wisc.edu/~horwitz/CS704-NOTES/1.LAMBDA-CALCULUS.html
  (test-case "wisc"
    (check-equal?
     (eval-all '(app (abs (abs 2)) (abs 1)))
     '(abs (abs 1))))
  ; https://en.wikipedia.org/wiki/De_Bruijn_index#Formal_definition
  (test-case "wikipedia"
    (check-equal?
     ; (λ λ 4 2 (λ 1 3)) (λ 5 1)
     (eval-all '(app (abs (abs (app (app 4 2) (abs (app 1 3))))) (abs (app 5 1))))
     ; λ 3 (λ 6 1) (λ 1 (λ 7 1))
     '(abs (app (app 3 (abs (app 6 1))) (abs (app 1 (abs (app 7 1))))))))))

(run-tests
 (test-suite
  "eval-by-name"
  (test-case "irreducible"
    (check-equal?
     (eval-by-name '(abs (app 1 1)))
     '(abs (app 1 1))))
  (test-case "identity"
    (check-equal?
     (eval-by-name '(app (abs 1) 1))
     '1))
  (test-case "deep identity"
    (check-equal?
     (eval-by-name '(app (abs 1) (abs 2)))
     '(abs 2)))
  ;; (test-case "evaluates omega once"
  ;;   (check-equal?
  ;;    (eval-by-name '(app (abs (app 1 1)) (abs (app 1 1))))
  ;;    '(app (abs (app 1 1)) (abs (app 1 1)))))
  ;; (test-case "does not evaluate omega"
  ;;   (check-equal?
  ;;    (eval-by-name '(app (abs (abs 1)) (app (abs (app 1 1)) (abs (app 1 1)))))
  ;;    '(abs 1)))
  ; https://cs.stackexchange.com/questions/52941/lambda-calculus-reduction-examples
  (test-case "stackexchange"
    (check-equal?
     (eval-by-name '(app (abs (app 1 2)) (abs (app 1 3))))
     '(app 1 2)))
  ; http://pages.cs.wisc.edu/~horwitz/CS704-NOTES/1.LAMBDA-CALCULUS.html
  (test-case "wisc"
    (check-equal?
     (eval-by-name '(app (abs (abs 2)) (abs 1)))
     '(abs (abs 1))))
  ; https://en.wikipedia.org/wiki/De_Bruijn_index#Formal_definition
  (test-case "wikipedia"
    (check-equal?
     ; (λ λ 4 2 (λ 1 3)) (λ 5 1)
     (eval-by-name '(app (abs (abs (app (app 4 2) (abs (app 1 3))))) (abs (app 5 1))))
     ; λ 3 (λ 6 1) (λ 1 (λ 7 1))
     '(abs (app (app 3 (abs (app 6 1))) (abs (app 1 (abs (app 7 1))))))))))

(run-tests
 (test-suite
  "eval-by-value"
  (test-case "irreducible"
    (check-equal?
     (eval-by-name '(abs (app 1 1)))
     '(abs (app 1 1))))
  (test-case "identity"
    (check-equal?
     (eval-by-name '(app (abs 1) 1))
     '1))
  (test-case "deep identity"
    (check-equal?
     (eval-by-name '(app (abs 1) (abs 2)))
     '(abs 2)))
  ;; (test-case "evaluates omega infinitely"
  ;;   (check-equal?
  ;;    (eval-by-name '(app (abs (app 1 1)) (abs (app 1 1))))
  ;;    '(app (abs (app 1 1)) (abs (app 1 1)))))
  ;; (test-case "evaluate omega"
  ;;   (check-equal?
  ;;    (eval-by-name '(app (abs (abs 1)) (app (abs (app 1 1)) (abs (app 1 1)))))
  ;;    '(abs 1)))
  ;; ; https://cs.stackexchange.com/questions/52941/lambda-calculus-reduction-examples
  (test-case "stackexchange"
    (check-equal?
     (eval-by-value '(app (abs (app 1 2)) (abs (app 1 3))))
     '(app (abs (app 1 3)) 1)))
  ; http://pages.cs.wisc.edu/~horwitz/CS704-NOTES/1.LAMBDA-CALCULUS.html
  (test-case "wisc"
    (check-equal?
     (eval-by-value '(app (abs (abs 2)) (abs 1)))
     '(abs (abs 1))))
  ; https://en.wikipedia.org/wiki/De_Bruijn_index#Formal_definition
  (test-case "wikipedia"
    (check-equal?
     ; (λ λ 4 2 (λ 1 3)) (λ 5 1)
     (eval-by-value '(app (abs (abs (app (app 4 2) (abs (app 1 3))))) (abs (app 5 1))))
     ; λ 3 (λ 6 1) (λ 1 (λ 7 1))
     '(abs (app (app 3 (abs (app 6 1))) (abs (app 1 (abs (app 7 1))))))))))

(run-tests
 (test-suite
  "ast"
  (test-case "var"
    (check-equal?
     (ast '(1))
     '(1 ())))
  (test-case "var - extra"
    (check-equal?
     (ast '(1 2))
     '(1 (2))))
  (test-case "abs"
    (check-equal?
     (ast '(abs 1))
     '((abs 1) ())))
  (test-case "abs - extra"
    (check-equal?
     (ast '(abs 1 2))
     '((abs 1) (2))))
  (test-case "app"
    (check-equal?
     (ast '(app 1 2))
     '((app 1 2) ())))
  (test-case "comple - deep"
    (check-equal?
     (ast '(abs app abs 1 2))
     '((abs (app (abs 1) 2)) ())))))

#lang racket/base

(require rackunit/text-ui)
(require rackunit "main.rkt")

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
     (eval-by-value '(app (abs 1) (abs 2)))
     '(abs 2)))
  (test-case "complex"
    (check-equal?
     (eval-by-value '(app (abs (abs (app 1 2))) (app 3 4)))
     '(abs (app 1 (app 4 5)))))
  ; https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.296.2485&rep=rep1&type=pdf
  (test-case "Fairouz Kamareddine"
    (check-equal?
     (eval-by-name '(app (abs (abs (app 2 1))) 2))
     '(abs (app 3 1))))
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
  "eval-by-name-fixpoint"
  (test-case "step"
    (check-equal?
     ((eval-by-name-fixpoint (λ (a) `(eval ,a))) '(app (abs 1) 2))
     '(eval 2)))))

(run-tests
 (test-suite
  "eval-by-value-fixpoint"
  (test-case "step"
    (check-equal?
     ((eval-by-value-fixpoint (λ (a) `(eval ,a))) '(app (abs 1) 2))
     `(shift (eval 2) 0 1)))))

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
  (test-case "complex"
    (check-equal?
     (eval-by-name '(app (abs (abs (app 1 2))) (app 3 4)))
     '(abs (app 1 (app 4 5)))))
  ;; (test-case "evaluates omega once"
  ;;   (check-equal?
  ;;    (eval-by-name '(app (abs (app 1 1)) (abs (app 1 1))))
  ;;    '(app (abs (app 1 1)) (abs (app 1 1)))))
  ;; (test-case "does not evaluate omega"
  ;;   (check-equal?
  ;;    (eval-by-name '(app (abs (abs 1)) (app (abs (app 1 1)) (abs (app 1 1)))))
  ;;    '(abs 1)))
  ; https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.296.2485&rep=rep1&type=pdf
  (test-case "Fairouz Kamareddine"
    (check-equal?
     (eval-by-name '(app (abs (abs (app 2 1))) 2))
     '(abs (app 3 1))))
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
     (eval-by-value '(abs (app 1 1)))
     '(abs (app 1 1))))
  (test-case "identity"
    (check-equal?
     (eval-by-value '(app (abs 1) 1))
     '1))
  (test-case "deep identity"
    (check-equal?
     (eval-by-value '(app (abs 1) (abs 2)))
     '(abs 2)))
  (test-case "complex"
    (check-equal?
     (eval-by-value '(app (abs (abs (app 1 2))) (app 3 4)))
     '(abs (app 1 (app 4 5)))))
  ;; (test-case "evaluates omega infinitely"
  ;;   (check-equal?
  ;;    (eval-by-name '(app (abs (app 1 1)) (abs (app 1 1))))
  ;;    '(app (abs (app 1 1)) (abs (app 1 1)))))
  ;; (test-case "evaluate omega"
  ;;   (check-equal?
  ;;    (eval-by-name '(app (abs (abs 1)) (app (abs (app 1 1)) (abs (app 1 1)))))
  ;;    '(abs 1)))
  ; https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.296.2485&rep=rep1&type=pdf
  (test-case "Fairouz Kamareddine"
    (check-equal?
     (eval-by-value '(app (abs (abs (app 2 1))) 2))
     '(abs (app 3 1))))
  ; https://cs.stackexchange.com/questions/52941/lambda-calculus-reduction-examples
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
  (test-case "compile - deep"
    (check-equal?
     (ast '(abs app abs 1 2))
     '((abs (app (abs 1) 2)) ())))))

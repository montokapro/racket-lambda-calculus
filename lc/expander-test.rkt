#lang racket

(require rackunit/text-ui)
(require rackunit "expander.rkt")

(run-tests
 (test-suite
  "postfix-expand-inner"
  (test-case "empty"
    (check-equal?
     (postfix-expand-inner '() '())
     '(() ())))
  (test-case "many"
    (check-equal?
     (postfix-expand-inner '(1 2 3) '())
     '(() (3 2 1))))
  (test-case "preserve out"
    (check-equal?
     (postfix-expand-inner '() '(out))
     '(() (out))))
  (test-case "preserve unknown"
    (check-equal?
     (postfix-expand-inner '(in) '())
     '(() (in))))))

(run-tests
 (test-suite
  "postfix-expand"
  (test-case "empty"
    (check-equal?
     (postfix-expand '())
     '()))
  (test-case "var"
    (check-equal?
     (postfix-expand '(1))
     '(1)))
  (test-case "abs"
    (check-equal?
     (postfix-expand '(1 abs))
     '((abs 1))))
  (test-case "app"
    (check-equal?
     (postfix-expand '(2 1 app))
     '((app 1 2))))
  (test-case "many"
    (check-equal?
     (postfix-expand '(4 3 app 2 abs 1))
     '(1 (abs 2) (app 3 4))))
  (test-case "deep"
    (check-equal?
     (postfix-expand '(4 3 app 2 1 app abs app))
     '((app (abs (app 1 2)) (app 3 4)))))))

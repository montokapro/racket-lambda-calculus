#lang racket

(require rackunit/text-ui)
(require rackunit "writer.rkt")

(run-tests
 (test-suite
  "contract-inner"
  (test-case "empty"
    (check-equal?
     (contract-inner '() '() identity)
     '(() ())))
  (test-case "many"
    (check-equal?
     (contract-inner '(1 2 3) '() identity)
     '(() (3 2 1))))
  (test-case "preserve out"
    (check-equal?
     (contract-inner '() '(out) identity)
     '(() (out))))
  (test-case "preserve unknown"
    (check-equal?
     (contract-inner '(in) '() identity)
     '(() (in))))))

(run-tests
 (test-suite
  "prefix-contract"
  (test-case "empty"
    (check-equal?
     (prefix-contract '())
     '()))
  (test-case "var"
    (check-equal?
     (prefix-contract '(1))
     '(1)))
  (test-case "abs"
    (check-equal?
     (prefix-contract '((abs 1)))
     '(abs 1)))
  (test-case "app"
    (check-equal?
     (prefix-contract '((app 1 2)))
     '(app 1 2)))
  (test-case "many"
    (check-equal?
     (prefix-contract '(1 (abs 2) (app 3 4)))
     '(app 3 4 abs 2 1)))
  (test-case "deep"
    (check-equal?
     (prefix-contract '((app (abs (app 1 2)) (app 3 4))))
     '(app abs app 1 2 app 3 4)))))

(run-tests
 (test-suite
  "postfix-contract"
  (test-case "empty"
    (check-equal?
     (postfix-contract '())
     '()))
  (test-case "var"
    (check-equal?
     (postfix-contract '(1))
     '(1)))
  (test-case "abs"
    (check-equal?
     (postfix-contract '((abs 1)))
     '(1 abs)))
  (test-case "app"
    (check-equal?
     (postfix-contract '((app 1 2)))
     '(2 1 app)))
  (test-case "many"
    (check-equal?
     (postfix-contract '(1 (abs 2) (app 3 4)))
     '(4 3 app 2 abs 1)))
  (test-case "deep"
    (check-equal?
     (postfix-contract '((app (abs (app 1 2)) (app 3 4))))
     '(4 3 app 2 1 app abs app)))))

(run-tests
 (test-suite
  "format"
  (test-case "empty"
    (check-equal?
     (format '())
     ""))
  (test-case "var"
    (check-equal?
     (format '(1))
     "1"))
  (test-case "abs"
    (check-equal?
     (format '(abs 1))
     "abs 1"))
  (test-case "app"
    (check-equal?
     (format '(app 1 2))
     "app 1 2"))
  (test-case "many"
    (check-equal?
     (format '(app 3 4 abs 2 1))
     "app 3 4 abs 2 1"))
  (test-case "deep"
    (check-equal?
     (format '(app abs app 1 2 app 3 4))
     "app abs app 1 2 app 3 4"))))

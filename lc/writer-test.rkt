#lang racket/base

(require rackunit/text-ui)
(require rackunit "writer.rkt")

(run-tests
 (test-suite
  "contract-inner"
  (test-case "empty"
    (check-equal?
     (contract-inner '() '())
     '(() ())))
  (test-case "many"
    (check-equal?
     (contract-inner '(1 2 3) '())
     '(() (3 2 1))))
  (test-case "preserve out"
    (check-equal?
     (contract-inner '() '(out))
     '(() (out))))
  (test-case "preserve unknown"
    (check-equal?
     (contract-inner '(in) '())
     '(() (in))))))

(run-tests
 (test-suite
  "contract"
  (test-case "empty"
    (check-equal?
     (contract '())
     '()))
  (test-case "var"
    (check-equal?
     (contract '(1))
     '(1)))
  (test-case "abs"
    (check-equal?
     (contract '((abs 1)))
     '(abs 1)))
  (test-case "app"
    (check-equal?
     (contract '((app 1 2)))
     '(app 1 2)))
  (test-case "many"
    (check-equal?
     (contract '(1 (abs 2) (app 3 4)))
     '(app 3 4 abs 2 1)))
  (test-case "deep"
    (check-equal?
     (contract '((app (abs (app 1 2)) (app 3 4))))
     '(app abs app 1 2 app 3 4)))))

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

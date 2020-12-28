#lang racket

(require rackunit/text-ui)
(require rackunit "writer.rkt")

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

#lang racket/base

(require rackunit/text-ui)
(require rackunit "de-bruijn.rkt")

(run-tests
 (test-suite
  "token-depth"
  (test-case "app"
    (check-equal? (token-depth 'app) 2))
  (test-case "abs"
    (check-equal? (token-depth 'abs) 1))
  (test-case "var"
    (check-equal? (token-depth 1) 0))))

(run-tests
 (test-suite
  "tokens-depth"
  (test-case "app"
    (check-equal? (tokens-depth '(app)) 2))
  (test-case "abs"
    (check-equal? (tokens-depth '(abs)) 1))
  (test-case "var"
    (check-equal? (tokens-depth '(1)) 0))
  (test-case "many"
    (check-equal? (tokens-depth '(app abs 1 abs 2)) 4))))

(run-tests
 (test-suite
  "parse-balanced-term"
  (test-case "app"
    (check-equal?
     (parse-balanced-term '(1 2 3) '(app))
     '(app 1 2)))
  (test-case "abs"
    (check-equal?
     (parse-balanced-term '(1 2) '(abs))
     '(abs 1)))
  (test-case "var"
    (check-equal?
     (parse-balanced-term '(2) '(1))
     '(1)))
  (test-case "var"
    (check-equal?
     (parse-balanced-term '(abs 1 abs 2 abs 3) '(app))
     '(app abs 1 abs 2)))))

#lang racket/base

(require
 data/either
 megaparsack
 megaparsack/text
 rackunit
 rackunit/spec)

(require "de-bruijn.rkt")

(describe "var/p"
  (it "succeeds with a positive integer"
    (check-equal? (parse-string var/p "42")
                  (success 42)))
  (it "fails with a negative integer"
    (check-equal? (parse-string var/p "-1")
                  (failure (message (srcloc 'string 1 0 1 1) #\- '("integer")))))
  (it "fails with zero"
    (check-equal? (parse-string var/p "0")
                  (failure (message (srcloc 'string 1 0 1 1) #\0 '("integer")))))
  (it "fails with a leading zero"
    (check-equal? (parse-string var/p "01")
                  (failure (message (srcloc 'string 1 0 1 1) #\0 '("integer"))))))

(describe "abs/p"
  (it "succeeds with an argument"
    (check-equal? (parse-string abs/p "abs 1")
                  (success '(abs 1))))
  (it "succeeds with a nested expression"
    (check-equal? (parse-string abs/p "abs abs 1")
                  (success '(abs (abs 1)))))
  (it "fails without an argument"
    (check-equal? (parse-string abs/p "abs abs")
                  (failure (message (srcloc 'string 1 4 5 1)
                                    #\b
                                    '("pp" "whitespace" "app" "abs" "integer" "integer"))))))

(describe "app/p"
  (it "succeeds with arguments"
    (check-equal? (parse-string app/p "app 1 2")
                  (success '(app 2 1))))
  (it "succeeds with a nested expression"
    (check-equal? (parse-string app/p "app app 1 2 app 3 4")
                  (success '(app (app 4 3) (app 2 1)))))
  (it "succeeds with beta reduction"
    (check-equal? (parse-string app/p "app app 1 2 abs app 1 2")
                  (success '(app 1 (app 2 1)))))
  (it "succeeds with nested beta reduction"
    (check-equal? (parse-string app/p "app app 4 3 abs abs app 2 1")
                  (success '(abs (app 1 (app 4 5))))))
  (it "fails without sufficient arguments"
    (check-equal? (parse-string app/p "app 1")
                  (failure (message (srcloc #f #f #f #f #f)
                                    "end of input"
                                    '("number" "number" "whitespace" "app" "abs" "integer"))))))

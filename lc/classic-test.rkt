#lang racket/base

(require
 data/either
 megaparsack
 megaparsack/text
 rackunit
 rackunit/spec)

(require "classic.rkt")

(describe "var"
  (it "succeeds with letter"
    (check-equal? (parse-string var/p "a")
                  (success #\a))))

(describe "env-var"
  (it "bound"
    (check-equal? (parse-string (env-var/p '(#\a)) "a")
                  (success 1)))
  (it "free"
    (check-equal? (parse-string (env-var/p '(#\b)) "a")
                  (success #\a))))

(describe "abs"
  (it "fails without var"
    (check-equal? (parse-string abs/p "λ.a")
                  (failure (message (srcloc 'string 1 0 1 2)
                                    #\.
                                    '("whitespace" "letter")))))
  (it "succeeds with single var"
    (check-equal? (parse-string abs/p "λa.a")
                  (success '(abs #\a))))
  ; TODO - respect whitespace before period
  (it "succeeds with multiple vars"
    (check-equal? (parse-string abs/p "λ a  b   c d. c")
                  (success '(abs abs abs abs #\c)))))

(describe "env-abs"
  (it "bound abs"
    (check-equal? (parse-string (env-abs/p '(#\b #\a)) "λc d.c")
                  (success '(abs abs 2))))
  (it "bound env"
    (check-equal? (parse-string (env-abs/p '(#\b #\a)) "λc d.b")
                  (success '(abs abs 3))))
  (it "free"
    (check-equal? (parse-string (env-abs/p '(#\b #\a)) "λc d.e")
                  (success '(abs abs #\e)))))

(describe "app+"
  (it "succeeds with a single var"
    (check-equal? (parse-string app+/p "a")
                  (success '(#\a))))
  (it "succeeds with multiple vars"
    (check-equal? (parse-string app+/p "a b c")
                  (success '(app app #\c #\b #\a))))
  (it "succeeds with a single var in parens"
    (check-equal? (parse-string app+/p "(a)")
                  (success '(#\a))))
  (it "succeeds with multiple vars in parens"
    (check-equal? (parse-string app+/p "((a) (b))")
                  (success '(app #\b #\a)))))

(describe "env-app+"
  (it "succeeds with a single var"
    (check-equal? (parse-string (env-app+/p '(#\a)) "a")
                  (success '(1))))
  (it "succeeds with multiple vars"
    (check-equal? (parse-string (env-app+/p '(#\a #\b)) "a b c")
                  (success '(app app #\c 2 1))))
  (it "succeeds with a single var in parens"
    (check-equal? (parse-string (env-app+/p '(#\a)) "(a)")
                  (success '(1))))
  (it "succeeds with multiple vars in parens"
    (check-equal? (parse-string (env-app+/p '(#\a #\b)) "((a) (b))")
                  (success '(app 2 1)))))

;; (describe "complex"
;;   (it "succeeds with a positive integer"
;;     (check-equal? (parse-string var/p "λc.λb.λa.c(a)(b)")
;;                   (success '(abs abs abs app 2 app 1 3)))))

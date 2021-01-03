#lang racket

; https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.296.2485&rep=rep1&type=pdf

(require racket/match)

(provide
 token-depth tokens-depth
 parse-balanced-term)

(define (token-depth token)
  (match token
    ['app 2]
    ['abs 1]
    [_ 0]))

;; parallelizable step
(define (tokens-depth tokens)
  (foldr + 0 (map token-depth tokens)))

(define (parse-balanced-term in tokens)
  ((lambda (depth)
     (cond
       ((< depth 0)
        (error "invalid sequence"))
       ((> depth 0)
        (append tokens (parse-balanced-term (drop in depth) (take in depth))))
       ((= depth 0)
        tokens)))
   (tokens-depth tokens)))

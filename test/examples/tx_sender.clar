(define-data-var sender (optional principal) none)

(define-read-only (read)
  (ok (var-get sender)))

(define-public (update)
  (begin
    (var-set sender (some tx-sender))
    (ok (var-get sender))))

(define-public (clear)
  (begin
    (var-set sender none)
    (ok (var-get sender))))

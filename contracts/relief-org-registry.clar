;; Relief Organization Registry Contract

(define-map organizations
  { org-id: uint }
  {
    name: (string-utf8 100),
    contact: (string-ascii 50),
    location: (string-utf8 100),
    verified: bool
  }
)

(define-data-var org-id-nonce uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_ALREADY_EXISTS (err u409))

(define-read-only (get-organization (org-id uint))
  (map-get? organizations { org-id: org-id })
)

(define-public (register-organization
    (name (string-utf8 100))
    (contact (string-ascii 50))
    (location (string-utf8 100)))
  (let
    ((new-org-id (+ (var-get org-id-nonce) u1)))
    (map-set organizations
      { org-id: new-org-id }
      {
        name: name,
        contact: contact,
        location: location,
        verified: false
      }
    )
    (var-set org-id-nonce new-org-id)
    (ok new-org-id)
  )
)

(define-public (verify-organization (org-id uint))
  (let
    ((org (unwrap! (get-organization org-id) ERR_NOT_FOUND)))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set organizations
      { org-id: org-id }
      (merge org { verified: true })
    )
    (ok true)
  )
)

(define-read-only (get-all-organizations)
  (ok (var-get org-id-nonce))
)


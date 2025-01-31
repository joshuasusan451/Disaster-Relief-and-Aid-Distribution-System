;; Volunteer Management Contract

(define-map volunteers
  { volunteer-id: uint }
  {
    name: (string-utf8 100),
    skills: (list 10 (string-ascii 50)),
    availability: (string-ascii 20),
    location: (string-utf8 100)
  }
)

(define-map assignments
  { assignment-id: uint }
  {
    volunteer-id: uint,
    org-id: uint,
    task: (string-utf8 200),
    start-date: uint,
    end-date: uint,
    status: (string-ascii 20)
  }
)

(define-data-var volunteer-id-nonce uint u0)
(define-data-var assignment-id-nonce uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_NOT_FOUND (err u404))

(define-read-only (get-volunteer (volunteer-id uint))
  (map-get? volunteers { volunteer-id: volunteer-id })
)

(define-read-only (get-assignment (assignment-id uint))
  (map-get? assignments { assignment-id: assignment-id })
)

(define-public (register-volunteer
    (name (string-utf8 100))
    (skills (list 10 (string-ascii 50)))
    (availability (string-ascii 20))
    (location (string-utf8 100)))
  (let
    ((new-volunteer-id (+ (var-get volunteer-id-nonce) u1)))
    (map-set volunteers
      { volunteer-id: new-volunteer-id }
      {
        name: name,
        skills: skills,
        availability: availability,
        location: location
      }
    )
    (var-set volunteer-id-nonce new-volunteer-id)
    (ok new-volunteer-id)
  )
)

(define-public (create-assignment
    (volunteer-id uint)
    (org-id uint)
    (task (string-utf8 200))
    (start-date uint)
    (end-date uint))
  (let
    ((new-assignment-id (+ (var-get assignment-id-nonce) u1)))
    (asserts! (is-some (get-volunteer volunteer-id)) ERR_NOT_FOUND)
    (map-set assignments
      { assignment-id: new-assignment-id }
      {
        volunteer-id: volunteer-id,
        org-id: org-id,
        task: task,
        start-date: start-date,
        end-date: end-date,
        status: "Assigned"
      }
    )
    (var-set assignment-id-nonce new-assignment-id)
    (ok new-assignment-id)
  )
)

(define-public (update-assignment-status (assignment-id uint) (new-status (string-ascii 20)))
  (let
    ((assignment (unwrap! (get-assignment assignment-id) ERR_NOT_FOUND)))
    (map-set assignments
      { assignment-id: assignment-id }
      (merge assignment { status: new-status })
    )
    (ok true)
  )
)

(define-read-only (get-all-volunteers)
  (ok (var-get volunteer-id-nonce))
)

(define-read-only (get-all-assignments)
  (ok (var-get assignment-id-nonce))
)


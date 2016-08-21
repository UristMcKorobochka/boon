;;; boon-regs.el --- An Ergonomic Command Mode  -*- lexical-binding: t -*-

;;; Commentary:


;;; Code:

(defun boon-mk-reg (mrk pnt &optional cursor)
  (list mrk pnt cursor))

(defun boon-reg-from-bounds (bnds)
  (list 'region (boon-mk-reg (car bnds) (cdr bnds) nil)))

(defun boon-regs-from-bounds (bnds)
  (list (boon-mk-reg (car bnds) (cdr bnds) nil)))

(defun boon-reg-mark (reg)
  (car reg))

(defun boon-reg-point (reg)
  (cadr reg))

(defun boon-reg-cursor (reg)
  (caddr reg))

(defun boon-normalize-reg (reg)
  "Normalize the region REG by making sure that mark < point."
  (boon-mk-reg (boon-reg-begin reg) (boon-reg-end reg) (boon-reg-cursor reg)))

(defun boon-reg-to-markers (reg)
  "Put copy the markers defining REG borders, and return that."
  (boon-mk-reg (copy-marker (boon-reg-mark reg)) (copy-marker (boon-reg-point reg)) (boon-reg-cursor reg)))

(defun boon-borders (reg how-much)
  "Given a normalized region REG, return its borders (as a region list).
The size of the borders is HOW-MUCH."
  ;; TODO: if the results would touch or overlap, return the input region
  (list (boon-mk-reg (boon-reg-end reg)   (- (boon-reg-end reg) how-much) (boon-reg-cursor reg))
        (boon-mk-reg (boon-reg-begin reg) (+ (boon-reg-begin reg) how-much) (boon-reg-cursor reg))))

;; TODO: also include surrounding blank lines if the other boundary is at bol/eol.
(defun boon-include-surround-spaces (reg)
  "Return REG, extended to include spaces around 'boon-reg-point'.
The spaces are searched after 'boon-regpoint' if the region is
directed forward, or or before, if the region is backwards."
  (save-excursion
    (let* ((mk (boon-reg-mark  reg))
           (pt (boon-reg-point reg))
           (fwd (> pt mk)))
      (boon-mk-reg mk
           (if fwd
               (progn
                 (goto-char pt)
                 (skip-syntax-forward "-")
                 (point))
             (progn
               (goto-char pt)
               (skip-syntax-backward "-")
               (point)))
               (boon-reg-cursor reg)))))

(defun boon-reg-begin (reg)
  "The begining of region REG."
  (min (boon-reg-point reg) (boon-reg-mark reg)))

(defun boon-reg-end (reg)
  "The end of region REG."
  (max (boon-reg-point reg) (boon-reg-mark reg)))

(defun boon-content (reg)
  "Given a region REG, return its contents (crop the region by 1)."
  (boon-mk-reg (+ (boon-reg-begin reg) 1) (- (boon-reg-end reg) 1) (boon-reg-cursor reg)))

(defun boon-reg-after (r1 r2)
  "Return non-nil when R1 occurs after R2."
  (> (boon-reg-begin r1) (boon-reg-end r2)))

(provide 'boon-regs)
;;; boon-regs.el ends here

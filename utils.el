
(defun kb/toggle-window-transparency ()
  "Toggle the value of `alpha-background'.

Toggles between 100 and 72 by default.  Can choose which value to change
to if called with ARG, or any prefix argument."
  (interactive "P")
  (let ((transparency (pcase arg
                        ((pred numberp) arg)
                        ((pred car) (read-number "Change the transparency to which value (0-100)? "))
                        (_
                         (pcase (frame-parameter nil 'alpha-background)
                           (72 100)
                           (100 72)
                           (t 100))))))
    (set-frame-parameter nil 'alpha-background transparency)))

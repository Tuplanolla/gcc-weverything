#! /usr/bin/csi -script

; This is a "write once, run away" kind of a utility for
;  extracting warning options from the source code of GCC by
;  using a regular parser (irregex) for an irregular language (C).
; This script takes a single command line argument that
;  should specify where the source code is.

(use data-structures)
(use defstruct)
(use irregex)
(use posix)
(use srfi-1)
(use utils)

(define (strings-sort ss)
  (delete-duplicates
    (sort ss string<)
    string=))

(define (irregex-extract-matches ir st)
  (irregex-fold ir
                (lambda (_ m ms) (cons m ms))
                '()
                st
                (lambda (_ ms) (reverse ms))))

(defstruct toplev
  file)

(defstruct opt
  file)

(define (find-toplev s)
  (let ((ss (find-files s
                        test: ".*/toplev\\.c"
                        dotfiles: #f)))
    (if (pair? ss)
      (make-toplev file: (car ss))
      #f)))

(define (find-opt s)
  (let ((ss (find-files s
                        test: ".*/c\\.opt"
                        dotfiles: #f)))
    (if (pair? ss)
      (make-opt file: (car ss))
      #f)))

(define (find-any s)
  (let ((ss (find-opt s)))
    (if ss
      ss
      (find-toplev s))))

(define (parse-toplev s)
  (let ((new-toplev "documented_lang_options\\s*\\[\\s*\\]\\s*=\\s*{\\s*(.*?)\\s*}\\s*;")
        (old-toplev "lang_options\\s*\\[\\s*\\]\\s*=\\s*{\\s*(.*?)\\s*}\\s*;")
        (array "{\\s*(.*?)\\s*}"))
    (map (lambda (s)
           (string-trim-both (string-trim-both s) #\"))
         (strings-sort
           (map car
                (filter (lambda (ss)
                          (and (>= (length ss) 2)
                               (irregex-search "\\bW" (car ss))))
                        (let ((m (irregex-search
                                   (irregex new-toplev 'single-line)
                                   s)))
                          (if m
                            (map (lambda (m)
                                   (irregex-split "," (irregex-match-substring m 1)))
                                 (irregex-extract-matches
                                   (irregex array
                                            'single-line)
                                   (irregex-match-substring m 1)))
                            (let ((m (irregex-search
                                       (irregex old-toplev 'single-line)
                                       s)))
                              (if m
                                (map (lambda (s)
                                       (list s ""))
                                     (irregex-split "," (irregex-match-substring m 1)))
                                #f))))))))))

(define (parse-opt s)
  (map (lambda (s)
         (string-append "-" (string-trim-both s)))
       (strings-sort
         (map car
              (filter (lambda (ss)
                        (and (>= (length ss) 2)
                             (irregex-search "\\bW" (car ss))
                             (irregex-search "\\bC\\b" (cadr ss))))
                      (map (lambda (s)
                             (irregex-split "\n" s))
                           (irregex-split "\n\n" s)))))))

(define (parse-any s)
  (cond
    ((toplev? s) (parse-toplev (read-all (toplev-file s))))
    ((opt? s) (parse-opt (read-all (opt-file s))))
    (else #f)))

(let ((ss (command-line-arguments)))
  (if (= (length ss) 1)
    (let ((s (find-any (car ss))))
      (if s
        (begin (for-each print (parse-any s))
               (exit 0))
        (begin (print "Options not found.")
               (exit 1))))
    (begin (print "Argument not found.")
           (exit 1))))

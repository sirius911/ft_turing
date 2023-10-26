(lang dune 3.9)

(name ft_turing)

(generate_opam_files true)

(source
 (github sirius911/ft_turing))

(authors "Cyrille LORIN" "Jeremy Caudal")

(maintainers "Cyrille LORIN")

(license LICENSE)

(documentation https://github.com/sirius911/ft_turing/blob/main/README.md)

(package
 (name ft_turing)
 (synopsis "Turing machine interpreter")
 (description "An interpreter for Turing machines defined in .json files.")
 (depends
  (ocaml
   (>= 4.08))
  (dune
   (>= 2.8))
  (yojson
   (>= 1.7.0))))
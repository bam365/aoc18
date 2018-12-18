solutions = aoc01.exe aoc01b.exe

all: $(solutions)

AocLib.cmo: AocLib.mli AocLib.ml
	ocamlfind ocamlc -linkpkg -package containers,containers.iter AocLib.mli AocLib.ml -o $@

aoc%.exe: AocLib.cmo aoc%.ml 
	ocamlfind ocamlc -linkpkg -package containers,containers.iter $^ -o $@


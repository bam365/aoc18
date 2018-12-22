solutions = aoc01.exe aoc01b.exe aoc02.exe

all: $(solutions)

AocLib.cma: AocLib.mli AocLib.ml
	ocamlfind ocamlc -linkpkg -linkall -package containers,containers.iter AocLib.mli AocLib.ml -a -o $@

aoc%.exe: AocLib.cma aoc%.ml 
	ocamlfind ocamlc -linkpkg -package containers,containers.iter $^ -o $@

clean:
	rm $(solutions)
	rm *.cmo
	rm *.cmi

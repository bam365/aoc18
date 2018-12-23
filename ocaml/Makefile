solutions = aoc01.exe aoc01b.exe aoc02.exe aoc03.exe
all: $(solutions)

AocLib.cma: AocLib.mli AocLib.ml
	ocamlfind ocamlc -linkpkg -linkall -package containers,containers.iter -g AocLib.mli AocLib.ml -a -o $@

aoc%.exe: AocLib.cma aoc%.ml 
	ocamlfind ocamlc -linkpkg -package containers,containers.iter,str -g $^ -o $@

clean:
	rm $(solutions)
	rm *.cmo
	rm *.cmi

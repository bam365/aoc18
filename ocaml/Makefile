solutions = aoc01.exe aoc01b.exe aoc02.exe aoc03.exe aoc04.exe aoc05.exe aoc13.exe
all: $(solutions)

AocLib.cma: AocLib.mli AocLib.ml
	ocamlfind ocamlc -package containers,containers.iter,containers_let,ppx_jane -g AocLib.mli AocLib.ml -a -o $@

aoc%.exe: AocLib.cma aoc%.ml 
	ocamlfind ocamlc -linkpkg -package calendar,containers,containers.iter,containers_let,ppx_jane,str -g $^ -o $@

clean:
	rm *.cmo
	rm *.cmi
	rm *.cma
	rm $(solutions)

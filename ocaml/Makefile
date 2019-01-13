solutions = aoc01.exe aoc01b.exe aoc02.exe aoc03.exe aoc04.exe aoc05.exe
all: $(solutions)

AocLib.cma: AocLib.mli AocLib.ml
	ocamlfind ocamlc -package containers,containers.iter -g AocLib.mli AocLib.ml -a -o $@

aoc%.exe: AocLib.cma aoc%.ml 
	ocamlfind ocamlc -linkpkg -package calendar,containers,containers.iter,str -g $^ -o $@

clean:
	rm *.cmo
	rm *.cmi
	rm *.cma
	rm $(solutions)

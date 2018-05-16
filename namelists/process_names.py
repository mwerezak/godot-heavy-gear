names = []
with open("raw.txt", "rt") as infile:
	#names = [ s.strip() for s in infile]
	for line in infile:
		tokens = [ t.strip() for t in line.split() ]
		tokens = [ tokens[i] for i in range(len(tokens)) if i % 2 == 0 ]
		names.extend(tokens)

names.sort()
with open("output.txt", "wt") as outfile:
	outfile.writelines(name + '\n' for name in names)

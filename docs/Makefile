IMAGE = latex-docker
MAIN = report.tex
OUTDIR = build

build-image:
	docker build -t $(IMAGE) .

pdf:
	mkdir -p $(OUTDIR)
	docker run --rm \
		-v $(PWD):/work \
		$(IMAGE) \
		latexmk -xelatex -shell-escape \
		-output-directory=$(OUTDIR) \
		-interaction=nonstopmode $(MAIN)

clean:
	rm -rf $(OUTDIR)

watch:
	mkdir -p $(OUTDIR)
	docker run --rm \
		-v $(PWD):/work \
		$(IMAGE) \
		latexmk -xelatex -shell-escape \
		-output-directory=$(OUTDIR) \
		-pvc $(MAIN)
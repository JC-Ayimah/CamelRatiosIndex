# Makefile for CamelRatiosIndex

.PHONY: all check test document install build site clean

all: document check test

document:
	Rscript -e "devtools::document()"

check:
	Rscript -e "devtools::check()"

test:
	Rscript -e "devtools::test()"

install:
	Rscript -e "devtools::install()"

build:
	Rscript -e "devtools::build()"

site:
	Rscript -e "pkgdown::build_site()"

clean:
	Rscript -e "devtools::clean_vignettes()"
	rm -f CamelRatiosIndex_*.tar.gz
	rm -rf docs/

cran-check:
	Rscript -e "devtools::check(cran = TRUE, remote = TRUE)"

rhub:
	Rscript -e "devtools::check_rhub()"

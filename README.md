# fortitudo

Crazy tool for Spreadsheet Warriors to generate Strength Training programs using edn data, embedded ruby (erubis) templates, and a bit of LaTex.

## examples

Here's an example output: [GZCL Intro+](https://drive.google.com/a/dyn.com/file/d/0B7W-DkIiFiYvOHdfY1hlN3FYMnc/view)

## usage

Get a clean state and gems installed:

```bash
make clean
```

Generate some tex from an edn file:

```bash
./fortitudo.rb -c gzcl-introplus.edn
```

Generate a PDF (assuming a working LaTeX environment):

```bash
./fortitudo.rb -c gzcl-introplus.edn | pdflatex
```

## et ceteras

♡ 2015 by Carlton Stedman. Copying art is an act of love. Please copy.

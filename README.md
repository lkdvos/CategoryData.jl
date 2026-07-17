# CategoryData.jl

This branch contains the raw data that is read in for the different categories.

---

## Conventions

Most files come from the anyonwiki and thus follow their conventions. In particular, since the data are multiplicity-free, we have
- Nsymbols: `a b c`
- Fsymbols: `a b c d e f Re Im`
- Rsymbols: `a b c Re Im`

We also have some files generated separately from the anyonwiki data, which follow the following conventions:
- Nsymbols: `a b c Nabc`
- Fsymbols: `a b c d e f α β μ ν Re Im`
- Rsymbols: `a b c μ ν Re Im`
- fusiontensors: `a b c m1 m2 m3 μ Re Im`

The spacings between columns are spaces.
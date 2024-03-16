<picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/lkdvos/CategoryData.jl/blob/main/docs/src/assets/logo-dark.svg">
    <img alt="CategoryData.jl logo" src="https://github.com/lkdvos/CategoryData.jl/blob/main/docs/src/assets/logo.svg" width="150">
</picture>

# CategoryData

[TensorKit.jl](https://github.com/Jutho/TensorKit.jl) extension for low rank unitary fusion categories, using [smallRankUnitaryFusionData](https://github.com/JCBridgeman/smallRankUnitaryFusionData) and the [AnyonWiki](https://anyonwiki.github.io/)

[![Build Status](https://github.com/lkdvos/CategoryData.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/lkdvos/CategoryData.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/lkdvos/CategoryData.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/lkdvos/CategoryData.jl)

This package currently provides TensorKit's sectortypes for all objects of multiplicity-free (braided)
fusion categories up to rank 6. The full list, along with the naming convention can be found
[here](https://anyonwiki.github.io/pages/Lists/losmffc.html).

Additionally, some specific categories with multiplicities have also been added.

The fusion categories adhere to a hierarchical structure of exported abstract types:
```julia
BraidedCategory <: FusionCategory <: FusionRing
```

which indicate implementations of fusion rules (`Nsymbol`), associators (`Fsymbol`) and
braidings (`Rsymbol`). 

Objects in these categories are identified with integers ranging from `1` to `R`, where $R$
is the rank of the category and the identity object is always `1`. These can then be used as
any other `Sector` for constructing `TensorMap`s.

```julia
using TensorKit, CategoryData
𝒞 = CategoryData.Fib # Fibonacci category
𝒪 = Object{𝒞}
@show collect(values(𝒪))                    # 1 -> I, 2 -> τ

t = TensorMap(rand, ComplexF64, Vect[𝒪](1 => 2, 2 => 2) ← Vect[𝒪](1 =>2, 2 => 2))
```

# Artifacts

The data for the fusion categories is stored in the `data` github branch, and retrieved using the `Artifacts` package. In particular, in order to add to, or change the data, the following steps should be taken:
1. Update the `data` github branch with the new data.
2. Release/tag a new version of the data `data-vX.Y.Z`, which can then be registered as an artifact.
3. Check the url of the release, which should be of the following form `"https://github.com/lkdvos/CategoryData.jl/archive/refs/tags/data-vX.Y.Z.tar.gz"`
4. Switch to the `main` branch, and update the `Artifact.toml` file. This can be done either manually, or by using `ArtifactUtils.jl`:
```julia-repl
julia> using ArtifactUtils
julia> add_artifact("Artifacts.toml", "fusiondata", "https://github.com/lkdvos/CategoryData.jl/archive/refs/tags/data-vX.Y.Z.tar.gz"; force=true);
```
5. Update the `artifact_path` constant in the source code `src/artifacts.jl`.
6. Push the changes to the `main` branch.

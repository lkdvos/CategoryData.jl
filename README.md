<picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/lkdvos/CategoryData.jl/blob/main/docs/src/assets/logo-dark.svg">
    <img alt="CategoryData.jl logo" src="https://github.com/lkdvos/CategoryData.jl/blob/main/docs/src/assets/logo.svg" width="150">
</picture>

# CategoryData

[TensorKit.jl](https://github.com/Jutho/TensorKit.jl) and [TensorKitSectors.jl](https://github.com/QuantumKitHub/TensorKitSectors.jl) extension for low rank unitary fusion categories, using [smallRankUnitaryFusionData](https://github.com/JCBridgeman/smallRankUnitaryFusionData) and the [AnyonWiki](https://anyonwiki.github.io/).

[![Build Status](https://github.com/lkdvos/CategoryData.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/lkdvos/CategoryData.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/lkdvos/CategoryData.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/lkdvos/CategoryData.jl)

This package currently provides [TensorKit.jl](https://github.com/Jutho/TensorKit.jl)'s sectortypes for all objects of multiplicity-free (braided)
 fusion categories up to rank 6. The full list can be found [here](https://anyonwiki.github.io/pages/Lists/losmffc.html), along with the naming convention [here](https://anyonwiki.github.io/pages/Concepts/FormalFusionRingNames.html).

Additionally, some specific categories with multiplicities have also been added.

The fusion categories adhere to a hierarchical structure of exported abstract types:
```julia
BraidedCategory <: FusionCategory <: FusionRing
```

which indicate implementations of fusion rules (`Nsymbol`), associators (`Fsymbol`) and
braidings (`Rsymbol`). 

Objects in these categories are identified with integers ranging from `1` to `R`, where $R$ is the rank of the category and the identity object is always `1`. These can then be used as any other `Sector` for constructing `TensorMap`s.

```julia
using TensorKit, CategoryData
𝒞 = CategoryData.Fib # Fibonacci category
𝒪 = Object{𝒞}
@show collect(values(𝒪))                    # 1 -> I, 2 -> τ

t = TensorMap(rand, ComplexF64, Vect[𝒪](1 => 2, 2 => 2) ← Vect[𝒪](1 =>2, 2 => 2))
```

For readability, we introduce a constant of a singleton type `Irr[F]` with `F<:FusionRing`. This notation is motivated by $\mathsf{Irr}_\mathcal{C}$ being common notation for the isomorphism classes of simple objects of a category $\mathcal{C}$. This constant can be used as
```julia
cat = UFC{2,1,0,1,1}

julia> Irr[cat]
Irr[UFC{2, 1, 0, 1, 1}]

julia> Vect[Irr[cat]](1=>1,2=>2)
Vect[Irr[UFC{2, 1, 0, 1, 1}]](1=>1, 2=>2)

julia> TensorMap(rand, ComplexF64, Vect[Irr[Fib]](1 => 1, 2 => 1) ← Vect[Irr[Fib]](1 => 1, 2 => 1))
TensorMap(Vect[Irr[Fib]](:I=>1, :τ=>1) ← Vect[Irr[Fib]](:I=>1, :τ=>1)):
* Data for fusiontree FusionTree{Irr[Fib]}((:I,), :I, (false,), ()) ← FusionTree{Irr[Fib]}((:I,), :I, (false,), ()):
 0.8086551324607184 + 0.2992468192479567im
* Data for fusiontree FusionTree{Irr[Fib]}((:τ,), :τ, (false,), ()) ← FusionTree{Irr[Fib]}((:τ,), :τ, (false,), ()):
 0.2785260062231665 + 0.4562450499428161im
```
## `@objectnames`
 Should a more clear identification of the objects of a particular category be wanted, the macro `@objectnames` allows one to identify the integers `1` to `R` with custom `Symbol`s. An already done example is:
 
 ```julia
 using TensorKit, CategoryData

julia> ob = Object{Fib}
Irr[Fib]
julia> ob(2)
:τ ∈ Irr[Fib]
julia> Irr[Fib](2)
:τ ∈ Irr[Fib]
julia> ob(:τ)
:τ ∈ Irr[Fib]
julia> Irr[Fib](:τ)
:τ ∈ Irr[Fib]

julia> Vect[ob](:I=>2,:τ=>2)
Vect[Irr[Fib]](:I=>2, :τ=>2)
 
julia> TensorMap(rand, ComplexF64, Vect[ob](:I => 1, :τ => 2) ← Vect[ob](:I => 1, :τ => 2))
TensorMap(Vect[Irr[Fib]](:I=>1, :τ=>2) ← Vect[Irr[Fib]](:I=>1, :τ=>2)):
* Data for fusiontree FusionTree{Irr[Fib]}((:I,), :I, (false,), ()) ← FusionTree{Irr[Fib]}((:I,), :I, (false,), ()):
 0.13039878034594143 + 0.19458098458789785im
* Data for fusiontree FusionTree{Irr[Fib]}((:τ,), :τ, (false,), ()) ← FusionTree{Irr[Fib]}((:τ,), :τ, (false,), ()):
  0.6696724619231914 + 0.0666600496240164im    0.285325730950295 + 0.03901184589817808im
 0.17722417457846185 + 0.9256706814953874im  0.24079997957218324 + 0.9904318781963207im
 ```
 
 Using the macro would look like:
 
 ```julia
 @objectnames custom_name = category symbols
 @objectnames category symbols
 ```
 Note: the symbols given here are not of `Type{Symbol}`.

# Artifacts

The data for the fusion categories is stored in the `data` github branch, and retrieved using the `Artifacts` package. In particular, in order to add to, or change the data, the following steps should be taken:
1. Update the `data` github branch with the new data.
2. Release/tag a new version of the data `data-vX.Y.Z`, which can then be registered as an artifact.
3. Check the url of the release, which should be of the following form `"https://github.com/lkdvos/CategoryData.jl/archive/refs/tags/data-vX.Y.Z.tar.gz"`
4. Switch to the `main` branch, and update the `Artifact.toml` file. This can be done either manually, or by using `ArtifactUtils.jl`:
```julia-repl
julia> using ArtifactUtils
julia> add_artifact!("Artifacts.toml", "fusiondata", "https://github.com/lkdvos/CategoryData.jl/archive/refs/tags/data-vX.Y.Z.tar.gz"; force=true);
```
5. Update the `artifact_path` constant in the source code `src/artifacts.jl`.
6. Push the changes to the `main` branch.

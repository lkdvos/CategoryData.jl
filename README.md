# CategoryData

[TensorKit.jl](https://github.com/Jutho/TensorKit.jl) extension for low rank unitary fusion categories, using [smallRankUnitaryFusionData](https://github.com/JCBridgeman/smallRankUnitaryFusionData)

[![Build Status](https://github.com/lkdvos/CategoryData.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/lkdvos/CategoryData.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/lkdvos/CategoryData.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/lkdvos/CategoryData.jl)

This package provides TensorKit's sectortypes for all objects of multiplicity-free (braided) fusion categories up to rank 6. The full list, along with the naming convention can be found in the [Anyon Wiki](http://www.thphys.nuim.ie/AnyonWiki/index.php/List_of_small_multiplicity-free_fusion_rings).

The fusion categories adhere to a hierarchical structure of exported abstract types:
```julia
PreModularFusionCategory{R,N,I,D₁,D₂} <: UnitaryFusionCategory{R,N,I,D₁} <: FusionRing{R,N,I}
```
which indicate implementations of fusion rules (`Nsymbol`), associators (`Fsymbol`) and braidings (`Rsymbol`). The naming is such that `R` indicates the rank, `N` the amount of non-self-dual objects, `I` the fusion ring index, such that equal values imply the same objects and fusion rules. `D₁` is the category index, enumerating different solutions for `Fsymbol` of the pentagon equation, while `D₂` enumerates different solutions of `Rsymbol` the hexagon equation.

Objects in these categories are identified with integers ranging from `1` to `R`, where the unit is always `1`. These can then be used as any other `Sector` for constructing `TensorMap`s.

```julia
using TensorKit, CategoryData
𝒞 = PreModularFusionCategory{2,0,2,0,0}     # Fibonacci category
𝒪 = Object{𝒞}
@show collect(values(𝒪))                    # 1 -> I, 2 -> τ

t = TensorMap(rand, ComplexF64, Vect[𝒪](1 => 2, 2 => 2) ← Vect[𝒪](1 =>2, 2 => 2))
```
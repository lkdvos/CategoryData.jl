module CategoryData

using Pkg
using Pkg.Artifacts

using Tar, Inflate, SHA

using TensorKit
using TensorKit: SectorValues
using TensorKit: SimpleFusion, GenericFusion, Anyonic, NoBraiding

using SparseArrayKit

export FusionRing, FusionCategory, BraidedCategory
export FR, UFC, PMFC
export RepA4, E6, Fib, Ising
export Object
export multiplicity, rank, algebraic_structure, selfduality
export S, D, Vec, Rep, Ƶ

include("categories.jl")
include("objects.jl")
include("artifacts.jl")
include("prettyprinting.jl")
include("aliases.jl")

end

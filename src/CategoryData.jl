module CategoryData

using Pkg
using Pkg.Artifacts

using Tar, Inflate, SHA

using TensorKitSectors
using TensorKitSectors: SectorValues
using TensorKitSectors: SimpleFusion, GenericFusion, Anyonic, NoBraiding

using SparseArrayKit

export FusionRing, FusionCategory, BraidedCategory
export FR, UFC, PMFC
export RepA4, E6, Fib, Ising, H1, H2, H3, ZVecS3, ZVecD4
export Object
export multiplicity, rank, algebraic_structure, selfduality
export S, D, Ƶ
export @objectnames

include("categories.jl")
include("objects.jl")
include("artifacts.jl")
include("prettyprinting.jl")
include("aliases.jl")

end

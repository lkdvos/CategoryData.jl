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
export RepA4, E6
export Object
export multiplicity, rank

include("categories.jl")
include("objects.jl")
include("artifacts.jl")
include("prettyprinting.jl")
include("aliases.jl")

function Object{H1}(a::Symbol)
    a === :I && return Object{H1}(1)
    a === :μ && return Object{H1}(2)
    a === :η && return Object{H1}(3)
    a === :ν && return Object{H1}(4)
    throw(ArgumentError("Unknown $H1 object $a."))
end

function Base.show(io::IO, ::MIME"text/plain", ψ::Object{H1})
    symbol = ψ.id == 1 ? :I : ψ.id == 2 ? :μ : ψ.id == 3 ? :η : :ν
    if get(io, :typeinfo, Any) !== Object{H1}
        print(io, symbol, " ∈ 𝒪($H1)")
    else
        print(io, symbol)
    end
end

function Object{H3}(a::Symbol)
    a === :I && return Object{H3}(1)
    a === :ρ && return Object{H3}(4) # Need to double check!
    throw(ArgumentError("Unknown $H3 object $a."))
end

function Base.show(io::IO, ::MIME"text/plain", ψ::Object{H3})
    symbol = ψ.id == 1 ? :I : ψ.id == 4 ? :ρ : ψ.id
    if get(io, :typeinfo, Any) !== H1
        print(io, symbol, " ∈ 𝒪($H1)")
    else
        print(io, symbol)
    end
end

function list_available()
    simplefusionrings = Type{<:SimpleFusionRing}[]
    fusionrings = Type{<:FusionRing}[]
    fusioncategories = Type{<:UnitaryFusionCategory}[]
    braidedcategories = Type{<:PreModularFusionCategory}[]
    for (dir, _, files) in walkdir(joinpath(artifact"fusiondata", versionName, "uFC"))
        if files == ["Nabc.txt"]
            FR_str = last(splitpath(dir))
            prefix, R, N, I = split(FR_str, "_")
            R, N, I = parse.(Int, (R, N, I))
            push!(simplefusionrings, SimpleFusionRing{R,N,I})
        elseif files == ["F.txt"]
            FR_str, D_str = splitpath(dir)[(end - 1):end]
            prefix, R, N, I = split(FR_str, "_")
            R, N, I, D = parse.(Int, (R, N, I, D_str))
            push!(fusioncategories, UnitaryFusionCategory{R,N,I,1,D})
        elseif files == ["R.txt"]
            FR_str, D₁_str, D₂_str = splitpath(dir)[(end - 2):end]
            prefix, R, N, I = split(FR_str, "_")
            R, N, I, D₁, D₂ = parse.(Int, (R, N, I, D₁_str, D₂_str))
            push!(braidedcategories, PreModularFusionCategory{R,N,I,1,D₁,D₂})
        end
    end
    for (dir, _, files) in walkdir("folder")
        if files == ["Nabc.txt"]
            FR_str = last(splitpath(dir))
            _, R, N, I, m = split(FR_str, "_")
            R, N, I, m = parse.(Int, (R, N, I, m))
            push!(fusionrings, FusionRing{R,M,N,I})
        elseif files == ["F.txt"]
            FR_str, D_str = splitpath(dir)[(end - 1):end]
            prefix, R, N, I, m = split(FR_str, "_")
            R, N, I, m, D = parse.(Int, (R, N, I, m, D_str))
            push!(fusioncategories, UnitaryFusionCategory{R,N,I,m,D})
        end
    end
    return simplefusionrings, fusionrings, fusioncategories, braidedcategories
end

end

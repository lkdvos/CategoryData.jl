module CategoryData

using Pkg
using Pkg.Artifacts

using Tar, Inflate, SHA

using TensorKit
using TensorKit: SectorValues
using TensorKit: SimpleFusion, GenericFusion, Anyonic, NoBraiding

using SparseArrayKit

export FusionRing, UnitaryFusionCategory, UFC, PreModularFusionCategory, PMFC, Object
export multiplicity, rank

######################
## Type definitions ##
######################
abstract type FusionRing{R,N,I} end
fusionring(::Type{<:FusionRing{R,N,I}}) where {R,N,I} = FusionRing{R,N,I}
Base.string(::Type{FusionRing{R,N,I}}) where {R,N,I} = "FR_$(R)_$(N)_$(I)"

rank(::Type{<:FusionRing{R}}) where {R} = R
selfduality(::Type{<:FusionRing{R,N}}) where {R,N} = N
multiplicity(::Type{<:FusionRing}) = 1 # currently does not allow multiplicity

abstract type UnitaryFusionCategory{R,N,I,D} <: FusionRing{R,N,I} end

category_index(::Type{<:UnitaryFusionCategory{R,N,I,D}}) where {R,N,I,D} = D

function Base.string(::Type{UnitaryFusionCategory{R,N,I,D}}) where {R,N,I,D}
    return "FR_$(R)_$(N)_$(I)_$(D)"
end

abstract type PreModularFusionCategory{R,N,I,D₁,D₂} <: UnitaryFusionCategory{R,N,I,D₁} end

braid_index(::Type{<:PreModularFusionCategory{R,N,I,D₁,D₂}}) where {R,N,I,D₁,D₂} = D₂

function Base.string(::Type{PreModularFusionCategory{R,N,I,D₁,D₂}}) where {R,N,I,D₁,D₂}
    return "FR_$(R)_$(N)_$(I)_$(D₁)_$(D₂)"
end

struct Object{FR} <: Sector where {FR<:FusionRing}
    id::Int
    function Object{FR}(a::Int) where {FR<:FusionRing}
        0 < a <= rank(FR) || throw(ArgumentError("Unknown $FR object $a."))
        return new{FR}(a)
    end
end

##################
## Type aliases ##
##################

const UFC{R,N,I,D}      = UnitaryFusionCategory{R,N,I,D}
const PMFC{R,N,I,D₁,D₂} = PreModularFusionCategory{R,N,I,D₁,D₂}

const Z2 = PMFC{2,0,1,0,0}
const Ising = PMFC{3,0,1,1,3}
const RepS3 = PMFC{3,0,2,0,0}
const Z3 = PMFC{3,2,1,0,0}
const Z2xZ2 = PMFC{4,0,1,0,0}
const RepD5 = PMFC{4,0,3,0,0}
const Z4 = PMFC{4,2,1,0,0}
const RepD4 = PMFC{5,0,1,3,0}
const RepD7 = PMFC{5,0,4,0,0}
const RepS4 = PMFC{5,0,6,1,0}
const Z5 = PMFC{5,4,1,0,0}
const Z6 = PMFC{6,4,1,0,0}

const Fib = UFC{2,0,2,0}
const H2 = UFC{6,2,8,2}
const H3 = UFC{6,2,8,3}

##########################
## Common functionality ##
##########################
Base.isless(a::Object{F}, b::Object{F}) where {F} = isless(a.id, b.id)
Base.hash(a::Object{F}, h::UInt) where {F} = hash(a.id, h)
Base.convert(::Type{F}, d::Integer) where {F<:Object} = F(d)

Base.IteratorSize(::Type{SectorValues{<:Object}}) = HasLength()
Base.length(::SectorValues{<:Object{FR}}) where {FR} = rank(FR)
function Base.iterate(::SectorValues{<:Object{FR}}, i=1) where {FR}
    return i > rank(FR) ? nothing : (Object{FR}(i), i + 1)
end
function Base.getindex(S::SectorValues{<:Object{FR}}, i) where {FR}
    return 0 < i <= rank(FR) ? Object{FR}(i) : throw(BoundsError(S, i))
end
TensorKit.findindex(::SectorValues{I}, c::I) where {I<:Object} = c.id

function TensorKit.FusionStyle(::Type{<:Object{F}}) where {F<:FusionRing}
    return multiplicity(F) == 1 ? SimpleFusion() : GenericFusion()
end

TensorKit.BraidingStyle(::Type{<:Object{F}}) where {F<:UFC} = NoBraiding()
TensorKit.BraidingStyle(::Type{<:Object{F}}) where {F<:PMFC} = Anyonic()

function TensorKit.:⊗(a::I, b::I) where {I<:Object}
    return Iterators.filter(c -> Nsymbol(a, b, c) > 0, values(I))
end

Base.one(::Type{<:Object{F}}) where {F} = Object{F}(1)
function Base.conj(a::Object{F}) where {F}
    if selfduality(F) == 0
        return a
    else
        return Object{F}(findfirst(x -> Nsymbol(a, x, one(a)) == 1,
                                   collect(values(typeof(a)))))
    end
end

##########################
## Loading of artifacts ##
##########################

const versionName = "JCBridgeman-smallRankUnitaryFusionData-a6ba1c3"

function _renew_artifacthash(filename="$versionName.tar.gz")
    println("sha256: ", bytes2hex(open(sha256, filename)))
    println("git-tree-sha1: ", Tar.tree_hash(IOBuffer(inflate_gzip(filename))))
    return nothing
end

function list_available()
    fusionrings = Type{<:FusionRing}[]
    fusioncategories = Type{<:UnitaryFusionCategory}[]
    braidedcategories = Type{<:PreModularFusionCategory}[]
    for (dir, _, files) in walkdir(joinpath(artifact"fusiondata", versionName, "uFC"))
        if files == ["Nabc.txt"]
            FR_str = last(splitpath(dir))
            prefix, R, N, I = split(FR_str, "_")
            R, N, I = parse.(Int, (R, N, I))
            push!(fusionrings, FusionRing{R,N,I})
        elseif files == ["F.txt"]
            FR_str, D_str = splitpath(dir)[(end - 1):end]
            prefix, R, N, I = split(FR_str, "_")
            R, N, I, D = parse.(Int, (R, N, I, D_str))
            push!(fusioncategories, UnitaryFusionCategory{R,N,I,D})
        elseif files == ["R.txt"]
            FR_str, D₁_str, D₂_str = splitpath(dir)[(end - 2):end]
            prefix, R, N, I = split(FR_str, "_")
            R, N, I, D₁, D₂ = parse.(Int, (R, N, I, D₁_str, D₂_str))
            push!(braidedcategories, PreModularFusionCategory{R,N,I,D₁,D₂})
        end
    end
    return fusionrings, fusioncategories, braidedcategories
end

function Nsymbol_filename(ring::Type{<:FusionRing})
    return joinpath(artifact"fusiondata", versionName, "uFC", string(fusionring(ring)),
                    "Nabc.txt")
end

function Fsymbol_filename(ring::Type{<:UnitaryFusionCategory})
    return joinpath(artifact"fusiondata", versionName, "uFC", string(fusionring(ring)),
                    "$(category_index(ring))", "F.txt")
end

function Rsymbol_filename(ring::Type{<:PreModularFusionCategory})
    return joinpath(artifact"fusiondata", versionName, "uFC", string(fusionring(ring)),
                    "$(category_index(ring))", "$(braid_index(ring))", "R.txt")
end

const Nformat = r"(?<a>\d+) (?<b>\d+) (?<c>\d+) (?<N>\d+)"

function parse_Nsymbol(line)
    m = match(Nformat, line)
    local labels, val
    try
        labels = parse.(Int, (m[:a], m[:b], m[:c]))
        val = parse(Int, m[:N])
    catch
        throw(Meta.ParseError("invalid N pattern: $m"))
    end
    return labels..., val
end

function extract_Nsymbol(ring::Type{<:FusionRing})
    filename = Nsymbol_filename(ring)
    r = rank(ring)
    N_array = SparseArray{Int}(undef, (r, r, r))
    for line in eachline(filename)
        a, b, c, val = parse_Nsymbol(line)
        N_array[a, b, c] = val
    end
    return N_array
end

const Fformat = r"(?<a>\d+) (?<b>\d+) (?<c>\d+) (?<d>\d+) (?<α>\d+) (?<e>\d+) (?<β>\d+) (?<μ>\d+) (?<f>\d+) (?<ν>\d+) (?<re>-?\d+(\.\d+)?) (?<im>-?\d+(\.\d+)?)"

function parse_Fsymbol(line)
    m = match(Fformat, line)
    local labels, val
    try
        labels = parse.(Int, 
            (m[:a], m[:b], m[:c], m[:d], m[:α], m[:e], m[:β], m[:μ], m[:f], m[:ν]))
        val = complex(parse.(Float64, (m[:re], m[:im]))...)
    catch
        throw(Meta.ParseError("invalid F pattern: $m"))
    end
    return labels..., val
end

function extract_Fsymbol(category::Type{<:UFC{R,N,I,D}}) where {R,N,I,D}
    filename = Fsymbol_filename(category)
    r = rank(category)
    F_array = SparseArray{ComplexF64}(undef, (r, r, r, r, r, r))

    for line in eachline(filename)
        a, b, c, d, α, e, β, μ, f, ν, val = parse_Fsymbol(line)
        μ == ν == α == β == 1 || error("not multiplicity-free")
        F_array[a, b, c, d, e, f] = val
    end
    
    return isreal(F_array) ? convert(SparseArray{Float64}, F_array) : F_array
end

const Rformat = r"(?<a>\d+) (?<b>\d+) (?<c>\d+) (?<μ>\d+) (?<ν>\d+) (?<re>-?\d+(\.\d+)?) (?<im>-?\d+(\.\d+)?)"

function parse_Rsymbol(line)
    m = match(Rformat, line)
    local labels, val
    try
        labels = parse.(Int, (m[:a], m[:b], m[:c], m[:μ], m[:ν]))
        val = complex(parse.(Float64, (m[:re], m[:im]))...)
    catch
        throw(Meta.ParseError("invalid R pattern: $m"))
    end
    return labels..., val
end

function extract_Rsymbol(category::Type{<:PMFC})
    filename = Rsymbol_filename(category)
    r = rank(category)
    R_array = SparseArray{ComplexF64}(undef, (r, r, r))

    for line in eachline(filename)
        a, b, c, μ, ν, val = parse_Rsymbol(line)
        μ == ν == 1 || throw(DomainError("R should not be a matrix"))
        R_array[a, b, c] = val
    end
    
    return isreal(R_array) ? convert(SparseArray{Float64}, R_array) : R_array
end

#######################
## N, F and Rsymbols ##
#######################

@generated function TensorKit.Nsymbol(a::Object{F}, b::Object{F},
                                      c::Object{F}) where {F<:FusionRing}
    N_array = extract_Nsymbol(F)
    return :(getindex($(N_array), a.id, b.id, c.id))
end

@generated function TensorKit.Fsymbol(a::Object{F}, b::Object{F}, c::Object{F},
                                      d::Object{F}, e::Object{F},
                                      f::Object{F}) where {F<:UFC}
    F_array = extract_Fsymbol(F)
    return :(getindex($(F_array), a.id, b.id, c.id, d.id, e.id, f.id))
end

@generated function TensorKit.Rsymbol(a::Object{F}, b::Object{F},
                                      c::Object{F}) where {F<:PMFC}
    R_array = extract_Rsymbol(F)
    return :(getindex($(R_array), a.id, b.id, c.id))
end

end

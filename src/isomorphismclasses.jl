struct Irr{F} <: Sector where {F<:FusionRing}
    id::Int
    function Irr{F}(a::Int) where {F<:FusionRing}
        0 < a <= rank(F) || throw(ArgumentError("Unknown $a ∈ Irr($F)."))
        return new{F}(a)
    end
end

function algebraic_structure(::Union{Type{Irr{F}},Irr{F}}) where {F}
    return F
end

Base.isless(a::Irr{F}, b::Irr{F}) where {F} = isless(a.id, b.id)
Base.hash(a::Irr{F}, h::UInt) where {F} = hash(a.id, h)
Base.convert(::Type{F}, d::Integer) where {F<:Irr} = F(d)

Base.IteratorSize(::Type{SectorValues{<:Irr}}) = HasLength()
Base.length(::SectorValues{<:Irr{F}}) where {F} = rank(F)
function Base.iterate(::SectorValues{<:Irr{F}}, i=1) where {F}
    return i > rank(F) ? nothing : (Irr{F}(i), i + 1)
end
function Base.getindex(S::SectorValues{<:Irr{F}}, i::Int) where {F}
    return 0 < i <= rank(F) ? Irr{F}(i) : throw(BoundsError(S, i))
end
TensorKitSectors.findindex(::SectorValues{I}, c::I) where {I<:Irr} = c.id

# some fallback styles - should probably be overwritten for specific categories

function TensorKitSectors.FusionStyle(::Type{<:Irr{F}}) where {F}
    return multiplicity(F) == 1 ? SimpleFusion() : GenericFusion()
end
TensorKitSectors.BraidingStyle(::Type{<:Irr{<:BraidedCategory}}) = Anyonic()
TensorKitSectors.BraidingStyle(::Type{<:Irr{<:FusionRing}}) = NoBraiding()

function TensorKitSectors.:⊗(a::I, b::I) where {I<:Irr}
    return Iterators.filter(c -> Nsymbol(a, b, c) > 0, values(I))
end

Base.one(::Type{<:Irr{F}}) where {F} = Irr{F}(1)
function Base.conj(a::Irr{F}) where {F}
    if selfduality(F) == 0
        return a
    else
        return Irr{F}(findfirst(x -> Nsymbol(a, x, one(a)) == 1,
                                   collect(values(typeof(a)))))
    end
end

# must be integer for fusiontensor
TensorKitSectors.dim(a::Irr{RepA4}) = a.id == 4 ? 3 : 1
TensorKitSectors.BraidingStyle(::Type{Irr{RepA4}}) = TensorKitSectors.Bosonic()

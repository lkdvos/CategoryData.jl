struct Object{F} <: Sector where {F<:FusionRing}
    id::Int
    function Object{F}(a::Int) where {F<:FusionRing}
        0 < a <= rank(F) || throw(ArgumentError("Unknown $F Object $a."))
        return new{F}(a)
    end
end

function algebraic_structure(::Union{Type{Object{F}},Object{F}}) where {F}
    return F
end

Base.isless(a::Object{F}, b::Object{F}) where {F} = isless(a.id, b.id)
Base.hash(a::Object{F}, h::UInt) where {F} = hash(a.id, h)
Base.convert(::Type{F}, d::Integer) where {F<:Object} = F(d)

Base.IteratorSize(::Type{SectorValues{<:Object}}) = HasLength()
Base.length(::SectorValues{<:Object{F}}) where {F} = rank(F)
function Base.iterate(::SectorValues{<:Object{F}}, i=1) where {F}
    return i > rank(F) ? nothing : (Object{F}(i), i + 1)
end
function Base.getindex(S::SectorValues{<:Object{F}}, i::Int) where {F}
    return 0 < i <= rank(F) ? Object{F}(i) : throw(BoundsError(S, i))
end
TensorKitSectors.findindex(::SectorValues{I}, c::I) where {I<:Object} = c.id

# some fallback styles - should probably be overwritten for specific categories

function TensorKitSectors.FusionStyle(::Type{<:Object{F}}) where {F}
    return multiplicity(F) == 1 ? SimpleFusion() : GenericFusion()
end
TensorKitSectors.BraidingStyle(::Type{<:Object{<:BraidedCategory}}) = Anyonic()
TensorKitSectors.BraidingStyle(::Type{<:Object{<:FusionRing}}) = NoBraiding()

function TensorKitSectors.:⊗(a::I, b::I) where {I<:Object}
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

# must be integer for fusiontensor
TensorKitSectors.dim(a::Object{RepA4}) = a.id == 4 ? 3 : 1
TensorKitSectors.BraidingStyle(::Type{Object{RepA4}}) = TensorKitSectors.Bosonic()

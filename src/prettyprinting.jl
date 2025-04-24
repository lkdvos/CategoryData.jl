# Utility
# -------

function subscript(i::Integer)
    return i < 0 ? error("$i is negative") :
           string(Iterators.reverse('₀' + d for d in digits(i))...)
end
function superscript(i::Integer)
    if i < 0
        throw(ArgumentError("$i is negative"))
    else
        # for some reason superscript two and three are not in the logical spots of the table
        return string(map(Iterators.reverse(digits(i))) do x
                          return x == 2 ? '²' : x == 3 ? '³' : '⁰' + x
                      end...)
    end
end

"""
    macro objectnames(category, names)

Defines a category name and its objects, along with pretty printing functionality.

# Examples

```julia
@objectnames PMFC{2,1,0,1,0,0} 0 1 # without category name
@objectnames Fib = UFC{2,1,0,2,0} I τ # with category name
"""
macro objectnames(categoryname, names...)
    if Meta.isexpr(categoryname, :(=), 2)
        name = categoryname.args[1]
        category = categoryname.args[2]
        length(names) == rank(@eval $category) ||
            throw(ArgumentError("Number of names does not match number of objects."))
        name_str = string(name)
        constex = if __module__ == CategoryData
            quote
                const $name = $category
                export $name
            end
        else
            quote
                const $name = $category
                function Base.show(io::IO, ::Type{$name})
                    return print(io, $name_str)
                end
                function Base.show(io::IO, ::MIME"text/plain", ::Type{$name})
                    return print(io, $name_str)
                end
            end
        end
    else
        name = categoryname
        category = categoryname
        constex = :()
    end

    ex = quote
        $constex
        function Object{$name}(a::Symbol)
            id = findfirst(==(a), $names)
            isnothing(id) && throw(ArgumentError("Unknown $($name_str) Object $a."))
            return Object{$name}(id)
        end

        function Base.show(io::IO, ψ::Object{$name})
            symbol = $names[ψ.id]
            if typeof(ψ) === get(io, :typeinfo, Any)
                print(io, ':', symbol)
            else
                print(io, typeof(ψ), "(:$symbol)")
            end
            return nothing
        end

        function Base.show(io::IO, ::MIME"text/plain", ψ::Object{$name})
            symbol = $names[ψ.id]
            if get(io, :typeinfo, Any) !== Object{$name}
                print(io, ':', symbol, " ∈ Irr[", $name, "]")
            else
                print(io, symbol)
            end
        end

        function Base.convert(::Type{Object{$name}}, a::Symbol)
            id = findfirst(==(a), $names)
            isnothing(id) && throw(ArgumentError("Unknown $($name_str) Object $a."))
            return Object{$name}(id)
        end
    end

    return esc(ex)
end

# TensorKit shorter GradedSpaces
struct ObjectTable end
"""
    const Irr

A constant of singleton type used as `Irr[F]` with `F<:FusionRing` to construct or obtain
the concrete type of the isomorphism classes of simple objects in the fusion ring `F`.
"""
const Irr = ObjectTable()
TensorKitSectors.type_repr(::Type{<:Object{F}}) where {F<:FusionRing} = "Irr[$F]"
Base.getindex(::ObjectTable, C::Type{<:FusionRing}) = Object{C}

# Show and friends
# ----------------

function Base.show(io::IO, ::MIME"text/plain", C::Type{FR{R,M,N,I}}) where {R,M,N,I}
    aliases = Base.make_typealias(C)
    if !isnothing(aliases)
        show(io, C)
        return nothing
    end

    if get(io, :compact, true)
        if M == 1
            print(io, "FR$(superscript(R)) $(superscript(N))$(subscript(I))")
        else
            print(io,
                  "FR$(superscript(R)) $(superscript(M)) $(superscript(N))$(subscript(I))")
        end
    else
        show(io, FR{R,M,N,I})
    end
end

function Base.show(io::IO, ::MIME"text/plain", C::Type{UFC{R,M,N,I,D}}) where {R,M,N,I,D}
    aliases = Base.make_typealias(C)
    if !isnothing(aliases)
        show(io, C)
        return nothing
    end

    if get(io, :compact, true)
        if M == 1
            print(io,
                  "UFC$(superscript(R)) $(superscript(N))$(subscript(I)) $(subscript(D))")
        else
            print(io,
                  "UFC$(superscript(R)) $(superscript(M)) $(superscript(N))$(subscript(I)) $(subscript(D))")
        end
    else
        show(io, UFC{R,M,N,I,D})
    end
end

function Base.show(io::IO, ::MIME"text/plain",
                   C::Type{PMFC{R,M,N,I,D₁,D₂}}) where {R,M,N,I,D₁,D₂}
    aliases = Base.make_typealias(C)
    if !isnothing(aliases)
        show(io, C)
        return nothing
    end

    if get(io, :compact, true)
        if M == 1
            print(io,
                  "PMFC$(superscript(R)) $(superscript(N))$(subscript(I)) $(subscript(D₁)) $(subscript(D₂))")
        else
            print(io,
                  "PMFC$(superscript(R)) $(superscript(M)) $(superscript(N))$(subscript(I)) $(subscript(D₁)) $(subscript(D₂))")
        end
    else
        show(io, PMFC{R,M,N,I,D₁,D₂})
    end
end

function Base.show(io::IO, ::MIME"text/plain", ψ::Object{FR}) where {FR<:FusionRing}
    if get(io, :typeinfo, Any) !== Object{FR}
        print(io, ψ.id, " ∈ Irr[", FR, "]")
    else
        print(io, ψ.id)
    end
end

function Base.show(io::IO, ψ::Object)
    if typeof(ψ) === get(io, :typeinfo, Any)
        print(io, ψ.id)
    else
        print(io, typeof(ψ), "(", ψ.id, ")")
    end
    return nothing
end

function Base.show(io::IO, ::Type{Object{F}}) where {F<:FusionRing}
    return print(io, "Irr[", F, "]")
end

# Grouplike things
# ----------------
abstract type D{N} <: TensorKitSectors.Group end

const D₃ = D{3}
const D₄ = D{4}
const D₅ = D{5}
const D₆ = D{6}

abstract type S{N} <: TensorKitSectors.Group end

const S₃ = S{3} # == D₃
const S₄ = S{4}

function Base.getindex(::TensorKitSectors.IrrepTable, G::Type{D{N}}) where {N}
    𝒞 = N == 3 ? RepD3 :
        N == 4 ? RepD4 :
        N == 5 ? RepD5 :
        N == 6 ? RepD7 :
        throw(ArgumentError("Rep[D{$N}] not implemented."))
    return Object{𝒞}
end

function Base.getindex(::TensorKitSectors.IrrepTable, G::Type{S{N}}) where {N}
    𝒞 = N == 3 ? RepS3 :
        N == 4 ? RepS4 :
        throw(ArgumentError("Rep[S{$N}] not implemented."))
    return Object{𝒞}
end

# Centers
# -------

struct CenterTable end

"""
    const Ƶ

A constant of singleton type used as `Ƶ[C]` with `C<:FusionCategory` to construct or obtain
the concrete type of the center of the category `C`.
"""
const Ƶ = CenterTable()

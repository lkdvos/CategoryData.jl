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
        return string(
            map(Iterators.reverse(digits(i))) do x
                return x == 2 ? '²' : x == 3 ? '³' : '⁰' + x
            end...
        )
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
        constex = :(const $name = $category)
    else
        name = categoryname
        category = categoryname
        constex = :()
    end

    try
        R = rank(eval(category))
        length(names) == R ||
            throw(ArgumentError("Number of names does not match number of objects"))
    catch ex
        if ex isa UndefVarError
            throw(ArgumentError("Unknown category $category"))
        else
            rethrow(ex)
        end
    end

    name_str = string(name)

    ex = quote
        $constex

        $TensorKitSectors.type_repr(::Type{$name}) = $name_str

        function Object{$name}(a::Symbol)
            id = findfirst(==(a), $names)
            isnothing(id) && throw(ArgumentError("Unknown $($name_str) Object $a."))
            return Object{$name}(id)
        end

        $CategoryData._label(a::Object{$name}) = string(QuoteNode($names[a.id]))

        function Base.convert(::Type{Object{$name}}, a::Symbol)
            id = findfirst(==(a), $names)
            isnothing(id) && throw(ArgumentError("Unknown $($name_str) Object $a."))
            return Object{$name}(id)
        end
    end

    return esc(ex)
end

# Show and friends
# ----------------

function TensorKitSectors.type_repr(::Type{Object{F}}) where {F <: FusionRing}
    return "Object{$(TensorKitSectors.type_repr(F))}"
end

# overloadable getter for the id of an object
_label(o::Object) = o.id

function Base.show(io::IO, ψ::Object)
    I = typeof(ψ)
    if I === get(io, :typeinfo, nothing)
        print(io, _label(ψ))
    else
        print(io, TensorKitSectors.type_repr(I), "(", _label(ψ), ")")
    end
    return nothing
end

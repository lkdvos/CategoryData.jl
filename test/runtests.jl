using CategoryData
using Test, TestExtras, Random
using TensorKit
using TensorKit: fusiontensor, pentagon_equation, hexagon_equation
using Base.Iterators: product
using LinearAlgebra: LinearAlgebra

Random.seed!(1234)

smallset(::Type{I}) where {I<:Object} = values(I)
function randsector(::Type{I}) where {I<:Object}
    s = collect(smallset(I))
    a = rand(s)
    while a == one(a) # don't use trivial label
        a = rand(s)
    end
    return a
end

function hasfusiontensor(I::Type{<:Object})
    try
        fusiontensor(one(I), one(I), one(I))
        return true
    catch e
        if e isa MethodError
            return false
        else
            rethrow(e)
        end
    end
end

include("fusionrings.jl")
include("fusioncategories.jl")
include("braidedcategories.jl")

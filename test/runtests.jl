using CategoryData
using Test, TestExtras, Random
using TensorKitSectors
using TensorKitSectors: fusiontensor, pentagon_equation, hexagon_equation
using Base.Iterators: product
using LinearAlgebra: LinearAlgebra
using TensorOperations: @tensor

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

# printing tests
object_name_list = [Fib, Ising, H1, H2, H3] # these have unit alias :I

@testset verbose = true "Object alias $(F)" for F in object_name_list
    I = Object{F}
    Istr = TensorKitSectors.type_repr(I)

    @testset "Pretty printing of Sector $Istr" begin
        @test @constinferred(convert(I, :I)) == one(I)
        @test eval(Meta.parse(sprint(show, I(:I)))) == one(I) == I(:I) == I(1)

        s = randsector(I)
        @test eval(Meta.parse(sprint(show, s))) == I(s.id) == s
    end
end

@testset "Pretty printing of Sector Object{ZVecS3}" begin
    I = Object{ZVecS3}
    @test @constinferred(convert(I, :A)) == one(I)
    @test eval(Meta.parse(sprint(show, I(:A)))) == one(I) == I(:A) == I(1)

    s = randsector(I)
    @test eval(Meta.parse(sprint(show, s))) == I(s.id) == s
    
end

@testset "@objectnames" begin
    @testset "Working examples" begin
        global testcat, testcat2, testcat3
        @objectnames testcat = FR{4,1,2,2} A B C D
        @objectnames testcat2 = UFC{5,1,2,4,0} α β γ δ ε
        @objectnames testcat3 = PMFC{6,1,0,4,0,7} a b c d e f

        @test Object{testcat}(:A) == one(Object{testcat})
        @test Object{testcat2}(:β) == Object{testcat2}(2)
        @test Object{testcat3}(:c) == Object{testcat3}(3)
    end

    @testset "Erroring examples" begin
        error1 = "Number of names does not match number of objects"
        error2 = "Unknown category PMFC{6, 5, 4, 3, 2, 1}"
        @test_throws ArgumentError(error1) @macroexpand @objectnames testcat = UFC{5,1,2,4,
                                                                                   0} α β γ δ
        @test_throws ArgumentError(error1) @macroexpand @objectnames testcat2 = PMFC{6,1,0,
                                                                                     4,0,7} a b c d e f g
        @test_throws ArgumentError(error2) @macroexpand @objectnames testcat3 = PMFC{6,5,4,
                                                                                     3,2,1} A B C D E F
    end
end
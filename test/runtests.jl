using CategoryData
using Test, TestExtras
using Random
using TensorKitSectors
using LinearAlgebra: LinearAlgebra
using TensorOperations: @tensor

Random.seed!(1234)

testsuite_path = joinpath(
    dirname(dirname(pathof(TensorKitSectors))), # TensorKitSectors root
    "test", "testsuite.jl"
)
include(testsuite_path)
using .SectorTestSuite: randsector

SectorTestSuite.smallset(::Type{I}) where {I <: Object} = collect(values(I))

# sector tests
@testset "Fusion rings" begin
    include("fusionrings.jl") # custom test selection
end

@testset "Fusion categories" begin
    for sector in CategoryData.list_fusioncategories()
        SectorTestSuite.test_sector(Object{sector})
    end
end

@testset "Braided categories" begin
    for sector in CategoryData.list_braidedcategories()
        SectorTestSuite.test_sector(Object{sector})
    end
end

SectorTestSuite.test_sector(Object{RepA4} ⊠ Object{Fib})

# printing tests
object_name_list = [Fib, Ising, H1, H2, H3] # these have unit alias :I

@testset verbose = true "Object alias $(F)" for F in object_name_list
    I = Object{F}
    Istr = TensorKitSectors.type_repr(I)

    @testset "Pretty printing of Sector $Istr" begin
        @test @constinferred(convert(I, :I)) == unit(I)
        @test eval(Meta.parse(sprint(show, I(:I)))) == unit(I) == I(:I) == I(1)

        s = randsector(I)
        @test eval(Meta.parse(sprint(show, s))) == I(s.id) == s
    end
end

@testset "Pretty printing of Sector Object{ZVecS3}" begin
    I = Object{ZVecS3}
    @test @constinferred(convert(I, :A)) == unit(I)
    @test eval(Meta.parse(sprint(show, I(:A)))) == unit(I) == I(:A) == I(1)

    s = randsector(I)
    @test eval(Meta.parse(sprint(show, s))) == I(s.id) == s
end

@testset verbose = true "@objectnames" begin
    @testset "Working examples" begin
        global testcat, testcat2, testcat3
        @objectnames testcat = FR{4, 1, 2, 2} A B C D
        @objectnames testcat2 = UFC{5, 1, 2, 4, 0} α β γ δ ε
        @objectnames testcat3 = PMFC{6, 1, 0, 4, 0, 7} a b c d e f

        @test Object{testcat}(:A) == unit(Object{testcat})
        @test Object{testcat2}(:β) == Object{testcat2}(2)
        @test Object{testcat3}(:c) == Object{testcat3}(3)
    end

    @testset "Erroring examples" begin
        error = "Number of names does not match number of objects"
        @test_throws ArgumentError(error) @macroexpand @objectnames testcat = UFC{5, 1, 2, 4, 0} α β γ δ
        @test_throws ArgumentError(error) @macroexpand @objectnames testcat2 = PMFC{6, 1, 0, 4, 0, 7} a b c d e f g
    end
end

@testset "Aqua" begin
    using Aqua: Aqua
    Aqua.test_all(CategoryData)
end

@testset "JET" begin
    using JET: JET
    JET.test_package(TensorKitSectors; target_defined_modules = true)
end

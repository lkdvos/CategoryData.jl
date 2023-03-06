using CategoryData
using Test, TestExtras, Random
using TensorKit
using TensorKit: fusiontensor
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

fusionrings, fusioncategories, braidedcategories = CategoryData.list_available()
sectorlist = (Object{F} for F in (braidedcategories..., fusioncategories...))

println("------------------------------------")
println("Sectors")
println("------------------------------------")
ti = time()

@timedtestset "Sector properties of $(TensorKit.type_repr(I))" for I in sectorlist
    Istr = TensorKit.type_repr(I)
    @testset "Sector $Istr: Basic properties" begin
        s = (randsector(I), randsector(I), randsector(I))
        @test eval(Meta.parse(sprint(show, I))) == I
        @test eval(Meta.parse(TensorKit.type_repr(I))) == I
        @test eval(Meta.parse(sprint(show, s[1]))) == s[1]
        @test @constinferred(hash(s[1])) == hash(deepcopy(s[1]))
        @test @constinferred(one(s[1])) == @constinferred(one(I))
        @constinferred dual(s[1])
        @constinferred dim(s[1])
        @constinferred frobeniusschur(s[1])
        @constinferred Nsymbol(s...)
        BraidingStyle(I) isa TensorKit.NoBraiding || @constinferred Rsymbol(s...)
        @constinferred Bsymbol(s...)
        @constinferred Fsymbol(s..., s...)
        it = @constinferred s[1] ⊗ s[2]
        @constinferred ⊗(s..., s...)
    end
    
    @testset "Sector $Istr: Value iterator" begin
        @test eltype(values(I)) == I
        sprev = one(I)
        for (i, s) in enumerate(values(I))
            @test !isless(s, sprev) # confirm compatibility with sort order
            if Base.IteratorSize(values(I)) == Base.IsInfinite() && I <: ProductSector
                @test_throws ArgumentError values(I)[i]
                @test_throws ArgumentError TensorKit.findindex(values(I), s)
            elseif hasmethod(Base.getindex, Tuple{typeof(values(I)),Int})
                @test s == @constinferred (values(I)[i])
                @test TensorKit.findindex(values(I), s) == i
            end
            sprev = s
            i >= 10 && break
        end
        @test one(I) == first(values(I))
        if Base.IteratorSize(values(I)) == Base.IsInfinite() && I <: ProductSector
            @test_throws ArgumentError TensorKit.findindex(values(I), one(I))
        elseif hasmethod(Base.getindex, Tuple{typeof(values(I)),Int})
            @test (@constinferred TensorKit.findindex(values(I), one(I))) == 1
            for s in smallset(I)
                @test (@constinferred values(I)[TensorKit.findindex(values(I), s)]) == s
            end
        end
    end

    @testset "Sector $Istr: Unitarity of F-move" begin
        for a in smallset(I), b in smallset(I), c in smallset(I)
            for d in ⊗(a, b, c)
                es = collect(intersect(⊗(a, b), map(dual, ⊗(c, dual(d)))))
                fs = collect(intersect(⊗(b, c), map(dual, ⊗(dual(d), a))))
                if FusionStyle(I) isa MultiplicityFreeFusion
                    @test length(es) == length(fs)
                    F = [Fsymbol(a, b, c, d, e, f) for e in es, f in fs]
                else
                    Fblocks = Vector{Any}()
                    for e in es
                        for f in fs
                            Fs = Fsymbol(a, b, c, d, e, f)
                            push!(Fblocks,
                                  reshape(Fs,
                                          (size(Fs, 1) * size(Fs, 2),
                                           size(Fs, 3) * size(Fs, 4))))
                        end
                    end
                    F = hvcat(length(fs), Fblocks...)
                end
                @test isapprox(F' * F, one(F); atol=1e-12, rtol=1e-12)
                if !isapprox(F' * F, one(F); atol=1e-12, rtol=1e-12)
                    @show F
                    @show a, b, c, d
                    @show es, fs
                end
            end
        end
    end
    
    @testset "Sector $Istr: Pentagon equation" begin
        for a in smallset(I), b in smallset(I), c in smallset(I), d in smallset(I)
            for f in ⊗(a, b), h in ⊗(c, d)
                for g in ⊗(f, c), i in ⊗(b, h)
                    for e in intersect(⊗(g, d), ⊗(a, i))
                        if FusionStyle(I) isa MultiplicityFreeFusion
                            p1 = Fsymbol(f, c, d, e, g, h) * Fsymbol(a, b, h, e, f, i)
                            p2 = zero(p1)
                            for j in ⊗(b, c)
                                p2 += Fsymbol(a, b, c, g, f, j) *
                                      Fsymbol(a, j, d, e, g, i) *
                                      Fsymbol(b, c, d, i, j, h)
                            end
                            @test isapprox(p1, p2; atol=1e-12, rtol=1e-12)
                        else
                            @tensor p1[λ, μ, ν, κ, ρ, σ] := Fsymbol(f, c, d, e, g, h)[λ, μ,
                                                                                      ν,
                                                                                      τ] *
                                                            Fsymbol(a, b, h, e, f, i)[κ, τ,
                                                                                      ρ, σ]
                            p2 = zero(p1)
                            for j in ⊗(b, c)
                                @tensor p2[λ, μ, ν, κ, ρ, σ] += Fsymbol(a, b, c, g, f, j)[κ,
                                                                                          λ,
                                                                                          α,
                                                                                          β] *
                                                                Fsymbol(a, j, d, e, g, i)[β,
                                                                                          μ,
                                                                                          τ,
                                                                                          σ] *
                                                                Fsymbol(b, c, d, i, j, h)[α,
                                                                                          τ,
                                                                                          ν,
                                                                                          ρ]
                            end
                            @test isapprox(p1, p2; atol=1e-12, rtol=1e-12)
                        end
                    end
                end
            end
        end
    end
    
    BraidingStyle(I) isa TensorKit.HasBraiding &&
        @testset "Sector $Istr: Hexagon equation" begin
        for a in smallset(I), b in smallset(I), c in smallset(I)
            for e in ⊗(c, a), f in ⊗(c, b)
                for d in intersect(⊗(e, b), ⊗(a, f))
                    if FusionStyle(I) isa MultiplicityFreeFusion
                        p1 = Rsymbol(a, c, e) * Fsymbol(a, c, b, d, e, f) * Rsymbol(b, c, f)
                        p2 = zero(p1)
                        for g in ⊗(a, b)
                            p2 += Fsymbol(c, a, b, d, e, g) * Rsymbol(g, c, d) *
                                  Fsymbol(a, b, c, d, g, f)
                        end
                        @test isapprox(p1, p2; atol=1e-12, rtol=1e-12)
                    else
                        @tensor p1[α, β, μ, ν] := Rsymbol(a, c, e)[α, λ] *
                                                  Fsymbol(a, c, b, d, e, f)[λ, β, γ, ν] *
                                                  Rsymbol(b, c, f)[γ, μ]
                        p2 = zero(p1)
                        for g in ⊗(a, b)
                            @tensor p2[α, β, μ, ν] += Fsymbol(c, a, b, d, e, g)[α, β, δ,
                                                                                σ] *
                                                      Rsymbol(g, c, d)[σ, ψ] *
                                                      Fsymbol(a, b, c, d, g, f)[δ, ψ, μ, ν]
                        end
                        @test isapprox(p1, p2; atol=1e-12, rtol=1e-12)
                    end
                end
            end
        end
    end
end

tf = time()
printstyled("Finished sector tests in ",
            string(round(tf - ti; sigdigits=3)),
            " seconds."; bold=true, color=Base.info_color())
println()

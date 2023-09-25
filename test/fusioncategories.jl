@testset verbose = true "$(F)" for F in CategoryData.list_fusioncategories()
    I = Object{F}
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
        @constinferred Bsymbol(s...)
        @constinferred Fsymbol(s..., s...)
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
            end
        end
    end

    @testset "Sector $Istr: Pentagon equation" begin
        for a in smallset(I), b in smallset(I), c in smallset(I), d in smallset(I)
            @test pentagon_equation(a, b, c, d; atol=1e-12, rtol=1e-12)
        end
    end

    if hasfusiontensor(I)
        @testset "Sector $Istr: fusion tensor and F-move" begin
            for a in smallset(I), b in smallset(I), c in smallset(I)
                for e in ⊗(a, b), f in ⊗(b, c)
                    for d in intersect(⊗(e, c), ⊗(a, f))
                        X1 = fusiontensor(a, b, e)
                        X2 = fusiontensor(e, c, d)
                        Y1 = fusiontensor(b, c, f)
                        Y2 = fusiontensor(a, f, d)
                        @tensor f1[-1, -2, -3, -4] := conj(Y2[a, f, d, -4]) *
                                                      conj(Y1[b, c, f, -3]) *
                                                      X1[a, b, e, -1] * X2[e, c, d, -2]
                        f2 = Fsymbol(a, b, c, d, e, f) * dim(d)
                        @test isapprox(f1, f2; atol=1000 * eps(), rtol=1000 * eps())
                    end
                end
            end
        end
    end
end

@testset verbose = true "$(F)" for F in CategoryData.list_braidedcategories()
    I = Object{F}
    Istr = TensorKitSectors.type_repr(I)

    @testset "Sector $Istr: Basic properties" begin
        s = (randsector(I), randsector(I), randsector(I))
        @test eval(Meta.parse(sprint(show, I))) == I
        @test eval(Meta.parse(TensorKitSectors.type_repr(I))) == I
        @test eval(Meta.parse(sprint(show, s[1]))) == s[1]
        @test @constinferred(hash(s[1])) == hash(deepcopy(s[1]))
        @test @constinferred(one(s[1])) == @constinferred(one(I))
        @constinferred dual(s[1])
        @constinferred dim(s[1])
        @constinferred frobeniusschur(s[1])
        @constinferred Bsymbol(s...)
        @constinferred Fsymbol(s..., s...)
    end

    @testset "Sector $Istr: Hexagon equation" begin
        for a in smallset(I), b in smallset(I), c in smallset(I)
            @test hexagon_equation(a, b, c; atol=1e-12, rtol=1e-12)
        end
    end

    if hasfusiontensor(I)
        @testset "Sector $Istr: fusion tensor and R-move" begin
            for a in smallset(I), b in smallset(I)
                for c in ⊗(a, b)
                    X1 = permutedims(fusiontensor(a, b, c), (2, 1, 3, 4))
                    X2 = fusiontensor(b, a, c)
                    l = dim(a) * dim(b) * dim(c)
                    R = LinearAlgebra.transpose(Rsymbol(a, b, c))
                    sz = (l, convert(Int, Nsymbol(a, b, c)))
                    @test reshape(X1, sz) ≈ reshape(X2, sz) * R
                end
            end
        end
    end
end

@testset verbose = true "$(F)" for F in CategoryData.list_braidedcategories()
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

    @testset "Sector $Istr: Hexagon equation" begin
        for a in smallset(I), b in smallset(I), c in smallset(I)
            @test hexagon_equation(a, b, c; atol=1e-12, rtol=1e-12)
        end
    end
end

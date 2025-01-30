@testset verbose = true "$(F)" for F in CategoryData.list_fusionrings()
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
        # @constinferred dim(s[1])
        # @constinferred frobeniusschur(s[1])
        @constinferred Nsymbol(s...)
        # BraidingStyle(I) isa TensorKitSectors.NoBraiding || @constinferred Rsymbol(s...)
        # @constinferred Bsymbol(s...)
        # @constinferred Fsymbol(s..., s...)
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
                @test_throws ArgumentError TensorKitSectors.findindex(values(I), s)
            elseif hasmethod(Base.getindex, Tuple{typeof(values(I)),Int})
                @test s == @constinferred (values(I)[i])
                @test TensorKitSectors.findindex(values(I), s) == i
            end
            sprev = s
            i >= 10 && break
        end
        @test one(I) == first(values(I))
        if Base.IteratorSize(values(I)) == Base.IsInfinite() && I <: ProductSector
            @test_throws ArgumentError TensorKitSectors.findindex(values(I), one(I))
        elseif hasmethod(Base.getindex, Tuple{typeof(values(I)),Int})
            @test (@constinferred TensorKitSectors.findindex(values(I), one(I))) == 1
            for s in smallset(I)
                @test (@constinferred values(I)[TensorKitSectors.findindex(values(I), s)]) ==
                      s
            end
        end
    end
end

@testset "Test all aliases" begin
    for (alias, name) in aliases
        @test alias == name
    end
end
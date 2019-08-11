using Test, Distributed, Random

workers = addprocs(4)

using DataLoaders

@testset "First Test" begin
  @test true
end
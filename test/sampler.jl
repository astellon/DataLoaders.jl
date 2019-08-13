using Test, DataLoaders

include("dataset.jl")

@testset "RandomSampler" begin
  dataset = getdataset((10,10), 100)
  sampler = RandomSampler(dataset)

  @test sampler.dataset     == dataset
  @test length(sampler)     == length(dataset)
  @test IndexStyle(sampler) == IndexLinear()
end
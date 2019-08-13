using Test, DataLoaders

@testset "RandomSampler" begin
  X = rand(1000)
  Y = rand(1000)
  dataset = collect(zip(X, Y))
  sampler = RandomSampler(dataset)

  @test sampler.dataset     == dataset
  @test length(sampler)     == length(dataset)
  @test IndexStyle(sampler) == IndexLinear()
end
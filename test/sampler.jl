using DataLoaders

X = rand(1000)
Y = rand(1000)
dataset = collect(zip(X, Y))

@testset "RandomSampler" begin
  sampler = RandomSampler(dataset)
  @test sampler.dataset == dataset
  @test length(sampler) == length(dataset)
end
using Test, DataLoaders

include("dataset.jl")

@testset "DataLoder" begin
  batchsize = 16
  dataset = getdataset((10,10), 100)
  loader  = DataLoader(dataset, batchsize, ntasks = 8, shuffle=true, droplast=false)

  @test size(loader)       == size(dataset)
  @test length(loader)     == length(dataset)

  (x, y), index = iterate(loader)

  @test size(x) == (10, 10, batchsize)
  @test size(y) == (batchsize,)
  @test index   == batchsize + 1
end
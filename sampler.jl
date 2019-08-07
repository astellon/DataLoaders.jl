import Random

struct RandomSampler{T} <: AbstractArray{T, 1}
  dataset
  transform::Array{Int64, 1}

  function RandomSampler(::IndexLinear, dataset)
    instance = new{eltype(dataset)}(dataset, collect(1:length(dataset)))
    Random.shuffle!(instance)
    instance
  end
end

function RandomSampler(dataset)
  RandomSampler(IndexStyle(dataset), dataset)
end

function Base.getindex(sampler::RandomSampler, index::Int)
  sampler.dataset[sampler.transform[index]]
end

function Base.size(sampler::RandomSampler)
  Base.size(sampler.dataset)
end

function Random.shuffle!(sampler::RandomSampler)
  Random.shuffle!(sampler.transform)
  nothing
end

function Random.shuffle!(rng::Random.AbstractRNG, sampler::RandomSampler)
  Random.shuffle!(rng, sampler.transform)
  nothing
end

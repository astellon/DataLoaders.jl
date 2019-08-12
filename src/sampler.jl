import Random

struct RandomSampler
  dataset
  transform::Array{Int64, 1}

  function RandomSampler(::IndexLinear, dataset)
    instance = new(dataset, collect(1:length(dataset)))
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

Base.length(sampler::RandomSampler) = @inbounds size(sampler)[1]

Base.IndexStyle(::RandomSampler) = IndexLinear()

function Random.shuffle!(sampler::RandomSampler)
  Random.shuffle!(sampler.transform)
  nothing
end

function Random.shuffle!(rng::Random.AbstractRNG, sampler::RandomSampler)
  Random.shuffle!(rng, sampler.transform)
  nothing
end

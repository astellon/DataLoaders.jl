import Random

"""
  RandomSampler(dataset)

Random Sampler that enables to get index without any modifications of your dataset.

`dataset` should satisfy `IndexStyle(dataset) == IndexLinear()`. `getindex(dataset, index::Int)` and `size(dataset)` is required too.
"""
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

Base.size(sampler::RandomSampler) = (length(sampler),)

Base.length(sampler::RandomSampler) = length(sampler.dataset)

Base.IndexStyle(::RandomSampler) = IndexLinear()

function Random.shuffle!(sampler::RandomSampler)
  Random.shuffle!(sampler.transform)
  nothing
end

function Random.shuffle!(rng::Random.AbstractRNG, sampler::RandomSampler)
  Random.shuffle!(rng, sampler.transform)
  nothing
end

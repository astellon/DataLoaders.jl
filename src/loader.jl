using Distributed

struct DataLoader
  dataset
  batchsize::Int
  shuffle::Bool
  tasks::Array{Distributed.Future, 1}
  droplast::Bool

  function DataLoader(::IndexLinear, dataset, batchsize::Int, shuffle::Bool=true, droplast::Bool=false)
    if shuffle
      new(RandomSampler(dataset), batchsize, shuffle, Array{Distributed.Future, 1}(), droplast)
    else
      new(dataset, batchsize, shuffle, Array{Distributed.Future, 1}(), droplast)
    end
  end
end

function DataLoader(dataset, batchsize::Int, shuffle::Bool=true, droplast::Bool=false)
  DataLoader(IndexStyle(dataset), dataset, batchsize, shuffle, droplast)
end

Base.size(dl::DataLoader) = size(dl.dataset)

Base.length(dl::DataLoader) = first(Base.size(dl))

function getbatch(dl::DataLoader, first::Int, last::Int)
  mapper(x) = @inbounds dl.dataset[x]
  reducer((x1, x2), (y1, y2)) = vcat(x1, y1), vcat(x2, y2)

  @distributed reducer for i in first:last
    mapper(i)
  end
end

function Base.iterate(dl::DataLoader)
  dl.shuffle && Random.shuffle!(dl.dataset)
  return iterate(dl, 1)
end

function Base.iterate(dl::DataLoader, i::Int)
  if length(dl.dataset) < i
    # i is out of range
    return nothing
  elseif length(dl.dataset) < i+dl.batchsize-1
    # the remainings is too few
    if !(dl.droplast)
      return getbatch(dl, i, length(dl)), length(dl.dataset)+1
    else
      return nothing
    end
  end

  return getbatch(dl, i, i+dl.batchsize-1), i+dl.batchsize
end

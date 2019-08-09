using Distributed

struct DataLoader
  dataset
  batchsize::Int
  shuffle::Bool
  nworkers::Int
  tasks::Array{Distributed.Future, 1}
  droplast::Bool

  function DataLoader(::IndexLinear, dataset::AbstractArray, batchsize::Int,
                      shuffle::Bool=true, nworkers::Int=1, droplast::Bool=false)
    new(dataset, batchsize, shuffle, nworkers, Array{Distributed.Future, 1}(), droplast)
  end
end

function DataLoader(dataset::AbstractArray, batchsize::Int,
                    shuffle::Bool=true, nworkers::Int=1, droplast::Bool=false)
  DataLoader(IndexStyle(dataset), dataset, batchsize, shuffle, nworkers, droplast)
end

Base.size(dl::DataLoader) = size(dl.dataset)
Base.length(dl::DataLoader) = first(Base.size(dl))

function getbatch(dl::DataLoader, first::Int, last::Int)
  # TODO: get batch concurently
  proc(x) = dl.dataset[x]
  return Distributed.pmap(proc, first:last)
end

function Base.iterate(dl::DataLoader)
  return iterate(dl, 1)
end

function Base.iterate(dl::DataLoader, i::Int)
  if length(dl.dataset) < i
    # i is out if range
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
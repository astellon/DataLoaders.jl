struct DataLoader
  dataset
  batchsize::Int
  shuffle::Bool
  nworkers::Int
  droplast::Bool

  function DataLoader(::IndexLinear, dataset::AbstractArray, batchsize::Int,
                      shuffle::Bool=true, nworkers::Int=1, droplast::Bool=false)
    new(dataset, batchsize, shuffle, nworkers, droplast)
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
  return dl.dataset[first:last]
end

function Base.iterate(dl::DataLoader)
  if length(dl.dataset) <= 0
    # if data is empty, return nothing
    return nothing
  end

  return iterate(dl, 1)
end

function Base.iterate(dl::DataLoader, i::Int)
  if length(dl.dataset) < i
    # i is out if range
    return nothing
  elseif length(dl.dataset) < i+dl.batchsize-1
    if !(dl.droplast)
      return getbatch(dl, i, length(dl)), length(dl.dataset)+1
    else
      return nothing
    end
  end

  return getbatch(dl, i, i+dl.batchsize-1), i+dl.batchsize
end
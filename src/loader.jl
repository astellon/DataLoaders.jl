"""
  DataLoader(dataset, batchsize::Int; shuffle::Bool=true, droplast::Bool=false)

Interatable minibatch loader.

`dataset` should satisfy `IndexStyle(dataset) == IndexLinear()`. `getindex(dataset, index::Int)` and `size(dataset)` is required too.

If `droplast` is `true`, last batch whoes size is less than `batchsize` is not iterated.
"""
struct DataLoader
  dataset
  batchsize::Int
  ntasks::Int
  shuffle::Bool
  droplast::Bool

  function DataLoader(::IndexLinear, dataset, batchsize::Int; ntasks::Int = 1, shuffle::Bool = true, droplast::Bool = false)
    if shuffle
      new(RandomSampler(dataset), batchsize, ntasks, shuffle, droplast)
    else
      new(dataset, batchsize, ntasks, shuffle, droplast)
    end
  end
end

function DataLoader(dataset, batchsize::Int; ntasks::Int = 1, shuffle::Bool = true, droplast::Bool = false)
  DataLoader(IndexStyle(dataset), dataset, batchsize, ntasks = ntasks, shuffle = shuffle, droplast = droplast)
end

Base.size(dl::DataLoader) = size(dl.dataset)

Base.length(dl::DataLoader) = first(Base.size(dl))

function getbatch(dl::DataLoader, first::Int, last::Int)
  xdim = length(size(dl.dataset[1][1]))  # dimension of data   (e.g. 2 for image)
  ydim = length(size(dl.dataset[1][2]))  # demension of target (e.g. 1 for lable)

  mapper(x) = @inbounds dl.dataset[x]

  batch = asyncmap(mapper, first:last, ntasks = dl.ntasks)

  xs = cat(getindex.(batch, 1)..., dims=xdim+1)
  ys = cat(getindex.(batch, 2)..., dims=ydim+1)

  return xs, ys
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

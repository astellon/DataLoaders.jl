using Test, Distributed, Random

# TEMPORARY worker processes for test
workers = addprocs(4)

using DataLoaders

include("sampler.jl")
include("loader.jl")

# MUST remove workers
rmprocs(workers)
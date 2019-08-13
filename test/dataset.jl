# pseudo dataset fot testing

function getdataset(dims, num)
  X = [rand(dims...) for _ in 1:num]
  Y = rand(num)
  collect(zip(X, Y))
end
## Q-learning for robust controllability of the ara-operon network

using NPZ
using Revise, RobustControllability


# build the ASSR
@time include(joinpath(@__DIR__, "net.jl"))

env = Environment(bcn)
ϵ = 0.4

e = 63
Q, V = run_Q_learning(env, e; ϵ)
println("Q = ")
display(Q)  
println("V = ")
display(V)
@show minimum(V)
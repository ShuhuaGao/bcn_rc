using NPZ
using Revise, RobustControllability

# logical rules
f1(x, u, ξ) = (x[1] == x[2]) | u[1]
f2(x, u, ξ) = (~x[1]) & ξ[1]
fs = [f1, f2]

# compute the ASSR, and the transition matrix is stored in L.txt
bcn = calculate_ASSR(fs, 1, 1; to_file=joinpath(@__DIR__, "L.txt"))

env = Environment(bcn)
ϵ = 0.4
max_episodes = 10 * bcn.N 

# show Q and V result for each target state
for e in 1:bcn.N
    println("---- e = ", e)
    Q, V = run_Q_learning(env, e; ϵ, max_episodes)
    println("Q = ")
    display(Q)
    println("V = ")
    display(V)
end

# show Q and V result for all target states
println("---- all states")
Q_all, V_all = run_Q_learning(env; ϵ)
println("Q = ")
display(Q_all)
println("V = ")
display(V_all)
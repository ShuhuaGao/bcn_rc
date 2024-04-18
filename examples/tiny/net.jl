# build the BCN from logical rules 

using Revise,  RobustControllability

f1(x, u, ξ) = (x[1] == x[2]) | u[1]
f2(x, u, ξ) = (~x[1]) & ξ[1]
fs = [f1, f2]

bcn = calculate_ASSR(fs, 1, 1; to_file=joinpath(@__DIR__, "net.txt"))

T, U = check_robust_controllability(bcn; verbose=true)

println("U = ")
display(U)
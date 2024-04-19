# tiny examples for illustration purposes

using RobustControllability

# logical rules
f1(x, u, ξ) = (x[1] == x[2]) | u[1]
f2(x, u, ξ) = (~x[1]) & ξ[1]
fs = [f1, f2]

# compute the ASSR, and the transition matrix is stored in L.txt
bcn = calculate_ASSR(fs, 1, 1; to_file=joinpath(@__DIR__, "L.txt"))

T, U = check_robust_controllability(bcn; verbose=true)

println("T* = ")
display(T)

println("U* = ")
display(U)
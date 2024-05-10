# tiny examples for illustration purposes

using RobustControllability, NPZ

# logical rules
f1(x, u, ξ) = (x[1] == x[2]) | u[1]
f2(x, u, ξ) = (~x[1]) & ξ[1]
fs = [f1, f2]

# compute the ASSR, and the transition matrix is stored in L.txt
bcn = calculate_ASSR(fs, 1, 1; to_file=joinpath(@__DIR__, "L.txt"))

# set verbose to true if you want to print intermediate results
@time T, U = check_robust_controllability(bcn; verbose=true)

println("T* = ")
display(T)
mask = T .< InfTime
println("#elements in T* < ∞ = ", sum(mask))
println("Min and max values in T* except ∞ = ", extrema(T[mask]))

println("U* = ")
display(U)

# Save the results
result_dir = joinpath(@__DIR__, "result")
mkpath(result_dir)
# rewrite U into an array for storage in npy/npz
# format: s, e, u_length, u, ...
# e.g., `(1, 2) => [0x01, 0x02]` becomes `1, 2, 2, 1, 2`
U_arr = Int[]
for ((s, e), u) in U
    append!(U_arr, [s, e, length(u), u...])
end
npzwrite(joinpath(result_dir, "res.npz"), Dict("T" => getfield.(T, :value), "U"=>U_arr, 
    "bcn.M" => bcn.M, "bcn.N" => bcn.N, "bcn.Q" => bcn.Q, "bcn.L" => bcn.L))
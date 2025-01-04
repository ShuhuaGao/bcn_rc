#### dynamic programming for robust controllability

using NPZ
using Revise, RobustControllability

## load the network 
n = 9
m = 4
q = 2

# make sure the ASSR is already computed
bcn = load_bcn(joinpath(@__DIR__, "model/L.txt"))
@show bcn.M, bcn.N, bcn.Q
# set verbose to true if you want to print intermediate results
@time T, U = check_robust_controllability(bcn; verbose=false)

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
# rewrite U into an array for storage in npy/npz for further analysis 
# format: s, e, u_length, u, ...
# e.g., `(1, 2) => [0x01, 0x02]` becomes `1, 2, 2, 1, 2`
U_arr = Int[]
for ((s, e), u) in U
    append!(U_arr, [s, e, length(u), u...])
end
npzwrite(joinpath(result_dir, "res_dp.npz"), Dict("T" => getfield.(T, :value), "U"=>U_arr))
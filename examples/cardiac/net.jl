# Cardiac development examples for illustration purposes

using RobustControllability, NPZ

# logical rules
f1(x, u, ξ) = ~x[2] & x[13] | u[1]
f2(x, u, ξ) = x[15]
f3(x, u, ξ) = x[8] | (x[2] & ~x[13])
f4(x, u, ξ) = ~x[8] & (x[5] | x[10])
f5(x, u, ξ) = x[2] & x[15]
f6(x, u, ξ) = x[9] | x[8] | x[11] | ξ[1]
f7(x, u, ξ) = x[10] | x[8] | x[4] | (x[2] & x[15])
f8(x, u, ξ) = x[2] & ~x[13]
f9(x, u, ξ) = (x[7] & x[6]) | x[10] | (x[8] & x[3]) | (x[1] & x[6]) | x[11]
f10(x, u, ξ) = x[5] & ξ[1]
f11(x, u, ξ) = ~ (x[10] | x[2] & u[1]) & (x[9] | x[11] | x[8]) & ~(x[3] & ~(x[8] | x[11])) | u[2]
f12(x, u, ξ) = 1
f13(x, u, ξ) = x[12]
f14(x, u, ξ) = x[14] | u[2]
f15(x, u, ξ) = x[14]
fs = [f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14, f15]

# compute the ASSR, and the transition matrix is stored in L.txt
bcn = calculate_ASSR(fs, 2, 1; to_file=joinpath(@__DIR__, "L.txt"))
println("ASSR finished")
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
# rewrite U into an array for storage in npy/npz
# format: s, e, u_length, u, ...
# e.g., `(1, 2) => [0x01, 0x02]` becomes `1, 2, 2, 1, 2`
U_arr = Int[]
for ((s, e), u) in U
    append!(U_arr, [s, e, length(u), u...])
end
npzwrite(joinpath(result_dir, "res.npz"), Dict("T" => getfield.(T, :value), "U"=>U_arr, 
    "bcn.M" => bcn.M, "bcn.N" => bcn.N, "bcn.Q" => bcn.Q, "bcn.L" => bcn.L))
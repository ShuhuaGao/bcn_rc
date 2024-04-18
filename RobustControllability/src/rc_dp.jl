# check robust controllability via dynamic programming


# compute T¹ and the related control set U¹ as matrices 
# each element of U¹ is a vector of integers
function compute_base_case(bcn::BCN)
    (; M, N, Q) = bcn
    T¹ = fill(Inf, N, N)
    U¹ = Matrix{Vector{Int64}}(undef, N, N)
    us = Int64[]
    for s in 1:N, e in 1:N
        empty!(us)
        # whether s robustly reaches e by control u
        for u in 1:M
            if all(step(bcn, s, u, ξ) == e for ξ in 1:Q)
                push!(us, u)
        end
        if !isempty(us)
            U¹[s, e] = copy(us)
            T¹[s, e] = 1
        end
    end
    return (T¹, U¹)
end
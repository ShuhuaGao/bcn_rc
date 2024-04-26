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
        end
        if !isempty(us)
            U¹[s, e] = copy(us)
            T¹[s, e] = 1
        end
    end
    return (T¹, U¹)
end


# one-step reachable set 
function compute_R1!(R::Vector, bcn::BCN, i, j)
    empty!(R)
    for ξ = 1:bcn.Q
        push!(R, step(bcn, i, j, ξ))
    end 
    return R
end

compute_R1(bcn::BCN, i, j) = compute_R1!(Vector{Int64}(), bcn, i, j)



# return optimal time matrix T and control matrix U as matrices
# if `verbose` is set, then print the intermediate results
function check_robust_controllability(bcn::BCN; verbose::Bool=false)
    (; M, N, Q) = bcn
    (T¹, U¹) = compute_base_case(bcn)
    k = 1
    T = copy(T¹)
    T′ = copy(T¹)
    if verbose
        println("T1")
        display(T¹)
    end
    # Julia has no do-while flow; we use while-break instead.
    while true
        k += 1 
        for s in 1:N, e in 1:N
            if T¹[s, e] != 1  # i.e., ϕ(s, e) != 1
                T′[s, e] = minimum(maximum(T[r, e] for r in compute_R1(bcn, s, j)) + 1 for j in 1:M)
            end
        end
        if verbose
            println("T$k")
            display(T′)
        end
        if T == T′
            break
        else
            T, T′ = T′, T
        end
    end
    if true
        println("- Took $(k - 1) iterations in total")
    end

    res = Int[]
    U = U¹  # to facilitate readability only 
    for s in 1:N, e in 1:N
        if 1 < T[s, e] < Inf
            U[s, e] = collect(1:M) 
            empty!(res)
            # compute the RHS for each u and collect them
            for j = 1:M
                push!(res, 1 + maximum(T[r, e] for r in compute_R1(bcn, s, j)))
            end
            # find the j associated with min value in res
            min_value = minimum(res)
            filter!(j -> res[j] == min_value, U[s, e])
        end
    end

    return T, U
end



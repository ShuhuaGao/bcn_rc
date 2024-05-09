# check robust controllability via dynamic programming


# compute T¹ and the related control set U¹ as matrices 
# each element of U¹ is a vector of integers
function compute_base_case(bcn::BCN)
    (; M, N, Q) = bcn
    @show sizeof(bcn)
    T¹ = fill(InfTime, N, N)
    @show sizeof(T¹)
    # it is expensive to allocate many (at most N^2) small vectors
    # we first allocate a large memory and then build small vectors on it
    mem = zeros(TC, N*N*M)
    # BUG: U1 may not be smaller
    U¹ = reshape([@view mem[(i-1)*M+1:i*M] for i in 1:N*N], N, N)
    @show sizeof(mem) sizeof(U¹) 
    # @show typeof(U¹)
    us = TC[]
    for e in 1:N, s in 1:N
        idx = 0
        empty!(us)
        # whether s robustly reaches e by control u
        for u in 1:M
            if all(step(bcn, s, u, ξ) == e for ξ in 1:Q)
                idx += 1
                U¹[s, e][idx] = u
            end
        end
        if idx > 0
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



"""
    check_robust_controllability(bcn::BCN; verbose::Bool=false)

Compute the optimal time and control matrices `T` & `U` for the given Boolean network.
If `verbose` is set, then print the intermediate results.
Each entry of `U` is a vector of integers, and positive ones mean valid control.
"""
# return optimal time matrix T and control matrix U as matrices
# if `verbose` is set, then print the intermediate results
function check_robust_controllability(bcn::BCN; verbose::Bool=false)
    (; M, N, Q) = bcn
    (T¹, U¹) = compute_base_case(bcn)
    @assert eltype(T¹) == TT 
    k = 1
    T = copy(T¹)
    T′ = copy(T¹)
    @show sizeof(T) sizeof(T′)
    if verbose
        println("T1")
        display(T¹)
    end
    # Julia has no do-while flow; we use while-break instead.
    while true
        k += 1 
        for s in 1:N, e in 1:N
            if T¹[s, e] != TT(1)  # i.e., ϕ(s, e) != 1
                T′[s, e] = minimum(maximum_time(T[r, e] for r in compute_R1(bcn, s, j)) + 1 for j in 1:M)
            end
        end
        if verbose
            println("T$k:")
            display(T′)
        end
        if T == T′
            break
        else
            T, T′ = T′, T
        end
    end
    println("- Took $(k - 1) iterations in total")

    res = Vector{TT}(undef, M)
    U = U¹  # to facilitate readability only 
    
    for e in 1:N, s in 1:N
        if TT(1) < T[s, e] < InfTime
            # compute the RHS for each u and collect them
            for j = 1:M
                res[j] = 1 + maximum_time(T[r, e] for r in compute_R1(bcn, s, j))
            end
            # find all j associated with min value in res
            min_value = minimum(res)
            idx  = 0
            for j = 1:M
                if res[j] == min_value
                    idx += 1
                    U[s, e][idx] = j
                end
            end
        end
    end

    return T, U
end



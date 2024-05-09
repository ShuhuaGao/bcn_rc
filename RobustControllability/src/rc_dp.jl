# check robust controllability via dynamic programming


# compute T¹ (matrix) and the related control set U¹ (Dict)
function compute_base_case(bcn::BCN)
    (; M, N, Q) = bcn
     sizeof(bcn)
    T¹ = fill(InfTime, N, N)
    # typically, only a small fraction of (s, e) is robustly reachable
    # thus, we only store control for reachable pairs 
    U¹ = Dict{Tuple{Int64, Int64}, Vector{TC}}()
    us = collect(UInt8, 1:M)
    for e in 1:N, s in 1:N
        empty!(us)
        # whether s robustly reaches e by control u
        for u in 1:M
            if all(step(bcn, s, u, ξ) == e for ξ in 1:Q)
                push!(us, u)
            end
        end
        if !isempty(us)
            T¹[s, e] = 1
            U¹[s, e] = copy(us)
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

Compute the optimal time matrix `T` and optimal control dict `U` for the given Boolean network.
If `verbose` is set, then print the intermediate results.
Each entry of `U` is a vector of integers representing controls.
If a pair (s, e) does not stay in U, then it means s cannot reach e robustly.
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
    if verbose
        println("T1")
        display(T¹)
    end
    # Julia has no do-while flow; we use while-break instead.
    R = collect(Int, 1:N)
    while true
        k += 1 
        for s in 1:N, e in 1:N
            if T¹[s, e] != TT(1)  # i.e., ϕ(s, e) != 1
                T′[s, e] = minimum(maximum_time(T[r, e] for r in compute_R1!(R, bcn, s, j)) + 1 for j in 1:M)
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
    us = collect(UInt8, 1:M)
    for e in 1:N, s in 1:N
        if TT(1) < T[s, e] < InfTime
            # compute the RHS for each u and collect them
            for j = 1:M
                res[j] = 1 + maximum_time(T[r, e] for r in compute_R1!(R, bcn, s, j))
            end
            # find all control associated with min value in res
            min_value = minimum(res)
            empty!(us)
            for u in 1:M
                if res[u] == min_value
                    push!(us, u)
                end
            end
            U[(s, e)] = copy(us)
        end
    end

    return T, U
end



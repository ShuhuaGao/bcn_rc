"""
    struct TTime <: Integer

A integer type that counts the control time.
Generally, the control time is a small value, and the underlying `UInt8` is enough.
The infinite value of `TTime` is defined as the constant `InfTime`.
A short alias of `TTime` is `TT`.
"""
struct TTime <: Integer
    value::UInt8        # Change this for wider integers 
end

TTime() = TTime(0)
zero(TTime) = TTime(0)

const TT = TTime

const InfTime = TTime(0)

Base.isinf(v::TTime) = v.value == 0
Base.isfinite(v::TTime) = !isinf(v)
Base.:(==)(a::TTime, b::TTime) = a.value == b.value

Base.:(+)(a::TTime, b::TTime) = isinf(a) || isinf(b) ? InfTime : TTime(a.value + b.value)
Base.:(+)(a::TTime, b::Integer) = isinf(a) ? InfTime : TTime(a.value + b)
Base.:(+)(a::Integer, b::TTime) = b + a 

function Base.:<(a::TTime, b::TTime)
    if isinf(a)
        return false
    else
        if isinf(b)
            return true
        else
            return a.value < b.value
        end
    end
end

Base.show(io::IO, t::TTime) = print(io, t.value)

function maximum_time(ts)
    max_t = TTime(1)
    for t in ts
        if isinf(t)
            return InfTime
        end
        max_t = max(max_t, t)
    end
    return max_t
end


"""
    const TC = UInt8

A integer type that counts the control time.
Generally, the number of control inputs is small, and the underlying `UInt8` is enough, which is applicable 
to at most 7 control input variables.
"""
const TC = UInt8   # Change this for wider integers 



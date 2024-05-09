function test_filter()
    x = rand(10000)
    @show objectid(x)
    @show @allocated filter!(e-> e>0.5, x)   # 0
    @show objectid(x)
    @show @allocated push!(x, 0.9, 1.2, 4.5) # 70568
    # thus, filter does not preserve the capacity 
end

function test_empty()
    x = rand(10000)
    items = rand(8000)
    for i = 1:10
        empty!(x)   # does not release memory, preserve capacity
        @show sizeof(x)
        a = @allocated append!(x, items)  # always 0
        @show a
    end  
end


function test_resize()
    x = rand(10000)
    items = rand(8000)
    for i = 1:10
        resize!(x, 100)   # does not release memory, preserve capacity
        @show length(x)
        a = @allocated append!(x, items)  # always 0
        @show a
        @show length(x)
    end  
    @allocated resize!(x, 0)  # equiv. to empty!
end
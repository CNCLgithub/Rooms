using JSON


# index arrays using sets. Order doesn't matter
function Base.to_index(i::Set{T}) where {T}
    Base.to_index(collect(T, i))
end

#################################################################################
# IO
#################################################################################


"""
    read_json(path)
    opens the file at path, parses as JSON and returns a dictionary
"""
function read_json(path::String)
    local data
    open(path, "r") do f
        data = JSON.parse(f)
    end

    # converting strings to symbols
    sym_data = Dict()
    for (k, v) in data
        sym_data[Symbol(k)] = v
    end

    return sym_data
end

#################################################################################
# Math
#################################################################################


#################################################################################
# Room coordinate manipulation
#################################################################################

const unit_ci = CartesianIndex(1,1)

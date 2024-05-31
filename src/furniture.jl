export (Furniture,
        furniture,
        add,
        remove,
        clear_room,
        shift_furniture)

#################################################################################
# Furniture
#################################################################################

# REVIEW: Why `Set`?
# Some set based comparisons later
"""
Furniture is a set of adjacent obstacle tiles.
"""
const Furniture = Set{Int64}

"""
Returns a collection of all furniture
"""
function furniture(r::Room)::Vector{Furniture} end

# TODO: why use an `Array{Set}` rather than `Array`
function furniture(r::GridRoom)
    g = pathgraph(r)
    d = r.data
    vs = @>> g begin
        connected_components
        filter(c -> d[first(c)] == obstacle_tile)
        map(Furniture) # maybe try `collect(Furniture)` ?
    end
end



"""
    add(src, dest)::Room


Adds the furniture of `src` to `dest` without mutation
"""
function add(src::Room, dest::Room)::Room
    error("not implemented")
end

function add(src::GridRoom, dest::GridRoom)::GridRoom
    omap = src.data .== obstacle_tile
    d = deepcopy(dest.data)
    d[omap] .= obstacle_tile
    g = deepcopy(dest.graph)
    prune_edges!(g, d)
    GridRoom(dest.steps, dest.bounds, dest.entrance,
             dest.exits, g, d)
end


"""
    add(src, furniture)::Room


Adds the furniture to `src` without mutation
"""
function add(src::Room, f::Furniture)::Room
    error("not implemented")
end

function add(r::GridRoom, f::Furniture)::GridRoom
    g = @> r steps grid PathGraph
    d = deepcopy(r.data)
    d[f] .= obstacle_tile
    prune_edges!(g, d)
    GridRoom(r.steps, r.bounds, r.entrance,
             r.exits, g, d)
end

"""
    remove(src, furniture)::Room


Removes the furniture to `src` without mutation
"""
function remove(r::GridRoom, f::Furniture)::GridRoom
    g = @> r steps grid PathGraph
    d = deepcopy(r.data)
    d[f] .= floor_tile
    prune_edges!(g, d)
    GridRoom(r.steps, r.bounds, r.entrance,
             r.exits, g, d)
end

"""
    clear_room(r)::Room


Removes all obstacles in `r` without mutation
"""
function clear_room(r::Room)::Room
    error('not implemented')
end
function clear_room(r::GridRoom)
    g = @> r steps grid PathGraph
    d = deepcopy(r.data)
    d[d .== obstacle_tile] .= floor_tile
    prune_edges!(g, d)
    GridRoom(r.steps, r.bounds, r.entrance,
             r.exits, g, d)
end


"""
    shift_furniture(r::Room, f::Furniture,m::Move)

Moves `f` in `r` according to `m`.
"""
function shift_furniture(r::Room, f::Furniture, m::Move)
    error("not implemented")
end
function shift_furniture(r::Room, f::Furniture, m::Symbol)
    shift_furniture(r, f, move_d[m])
end
function shift_furniture(r::Room, f::Furniture, m::Int64)
    shift_furniture(r, f, move_map[m])
end

function shift_furniture(r::GridRoom, f::Furniture, m::Move)
    @assert all(r.data[f] .== obstacle_tile)
    d = deepcopy(r.data)
    # apply move
    moved_f = move(r, f, m)
    # update data and graph
    to_clear = setdiff(f, moved_f)
    d[to_clear] .= floor_tile
    to_add = setdiff(moved_f, f)
    d[to_add] .= obstacle_tile

    g = @> r steps grid PathGraph
    prune_edges!(g, d)
    GridRoom(r.steps, r.bounds, r.entrance,
             r.exits, g, d)
end

"""
    move(r,f,m)

Applys `m` to change the tile indices of `f`.
"""
function move(r::Room, f::Furniture, m::Move)::Furniture
    nf = collect(Int64, f)
    unsafe_move!(nf, m, r)
    Set{Int64}(nf)
end

# function unsafe_move!(::Furniture, ::Move, ::Room) end

unsafe_move!(f::Vector{Int64}, ::Up, r::GridRoom) = f .-= 1
unsafe_move!(f::Vector{Int64}, ::Down, r::GridRoom) = f .+= 1
unsafe_move!(f::Vector{Int64}, ::Left, r::GridRoom) = f .-= first(steps(r))
unsafe_move!(f::Vector{Int64}, ::Right, r::GridRoom) = f .+= first(steps(r))

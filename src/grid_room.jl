export GridRoom,
    data,
    entrance,
    exits,
    bounds,
    steps,
    expand,
    from_json


#################################################################################
# GridRoom
#################################################################################

"""
A room defined as a grid.

$(TYPEDEF)

---

$(TYPEDFIELDS)
"""
struct GridRoom <: Room
    """The number of discrete bins along per dimension"""
    steps::Tuple{Int64, Int64}
    """The span in real units per dimension"""
    bounds::Tuple{Float64, Float64}
    """A list of tiles marking the entrance"""
    entrance::Vector{Int64}
    """A list of tiles marking the exit"""
    exits::Vector{Int64}
    """The pathgraph of the room"""
    graph::PathGraph
    """A matrix containing the tile type of each node"""
    data::Matrix{Tile}
end

pathgraph(r::GridRoom) = r.graph
data(r::GridRoom) = r.data
bounds(r::GridRoom) = r.bounds
steps(r::GridRoom) = r.steps
entrance(r::GridRoom) = r.entrance
exits(r::GridRoom) = r.exits


#################################################################################
# Constructors
#################################################################################

"""
    $(TYPEDSIGNATURES)

Constructs a grid room from steps and bounds.
"""
function GridRoom(steps::Tuple{Int64,Int64},
                  bounds::Tuple{Float64,Float64})
    # initialize grid
    g = PathGraph(grid(steps))
    d = fill(floor_tile, steps)
    GridRoom(steps, bounds, Int64[], Int64[], g, d)
end


"""
    $(TYPEDSIGNATURES)

Primary constructor for `GridRoom`.
Adds wall tiles along the perimeter of the grid.
"""
function GridRoom(steps::Tuple{Int64, Int64},
                  bounds::Tuple{Float64, Float64},
                  ent::Vector{Int64},
                  exs::Vector{Int64})

    d = Matrix{Tile}(undef, steps)
    fill!(d, floor_tile)

    # add walls
    d[:, 1] .= wall_tile
    d[:, end] .= wall_tile
    d[1, :] .= wall_tile
    d[end, :] .= wall_tile

    # set entrances and exits
    # these are technically floors but are along the border
    d[ent] .= floor_tile
    d[exs] .= floor_tile

    g = init_pathgraph(GridRoom, d)

    GridRoom(steps, bounds, ent, exs, g, d)
end

"""
    $(TYPEDSIGNATURES)

using this GridRoom in render_rooms to change to wall_tiles
instead of changing struct to mutable
"""
function GridRoom(room::GridRoom, newdata::Matrix{Tile})
    return GridRoom(
        room.steps,
        room.bounds,
        room.entrance,
        room.exits,
        room.graph,
        newdata,
    )
end


"""
    $(TYPEDSIGNATURES)

scales the tiles in `r` by `factor`.
>Note: the entrance and exits will also be scaled
"""
function expand(r::GridRoom, factor::Int64)::GridRoom
    s = steps(r) .* factor
    # "expand" by `factor`
    d = data(r)
    sd = repeat(d, inner = (factor, factor))
    sg = PathGraph(grid(s))

    prune_edges!(sg, sd)

    cis = CartesianIndices(d)
    slis = LinearIndices(s)
    sents = similar(entrance(r))
    # update entrances and exits
    @inbounds for (i, v) in enumerate(entrance(r))
        sents[i] = slis[(cis[v] - unit_ci) * factor + unit_ci]
    end
    sexits = similar(exits(r))
    @inbounds for (i, v) in enumerate(exits(r))
        sexits[i] = slis[(cis[v] - unit_ci) * factor + unit_ci]
    end
    GridRoom(s, bounds(r) .* factor, sents, sexits, sg, sd)
end


#################################################################################
# IO
#################################################################################

const _char_map = Dict{Symbol, String}(
    :entrance => "◉",
    :exit => "◎",
    :path => "○"
)

function Base.show(io::IO, m::MIME"text/plain", r::GridRoom)
    Base.show(io,m,(r, Int64[]))
end
function Base.show(io::IO, m::MIME"text/plain",
                   t::Tuple{GridRoom, Vector{Int64}})
    r, paths = t
    rd = repr.(r.data)
    rd[entrance(r)] .= _char_map[:entrance]
    rd[exits(r)] .= _char_map[:exit]
    rd[paths] .= _char_map[:path]
    rd[:, 1:(end-1)] .*= " "
    rd[:, end] .*= "\n"
    s::String = join(permutedims(rd))
    println(io,s)
end

JSON.lower(r::GridRoom) = Dict(
    steps  => steps(r),
    bounds => bounds(r),
    entrance => entrance(r),
    exits => exits(r),
    data   => convert.(Symbol, data(r))
)
function JSON.lower(rp::Tuple{GridRoom, Vector{Int}})
    r,p = rp
    d = JSON.lower(r)
    d[:path] = p
    return d
end

# FIXME: several janky statements
function from_json(::Type{GridRoom}, jd::Dict)
    s = Tuple(collect(Int64, jd["steps"]))
    b = Tuple(collect(Float64, jd["bounds"]))
    g = PathGraph(grid(s))
    d = Matrix{Tile}(undef, s)
    for i = 1:s[1], j = 1:s[2]
        msg = Symbol(jd["data"][j][i])
        d[i, j] = convert(Tile, msg)
    end
    prune_edges!(g, d)
    en = collect(Int64, jd["entrance"])
    ex = collect(Int64, jd["exits"])
    GridRoom(s,b,en,ex, g, d)
end


#################################################################################
# Helpers
#################################################################################

function init_pathgraph(T::Type{GridRoom}, d::Matrix{Tile})
    r, c = size(d)
    n = length(d)
    deltas = [-1, 1, -r, r]
    adjm = Matrix{Bool}(undef, n, n)
    fill!(adjm, false)
    @inbounds for i = 1:n
        for j = deltas
            ji = i + j
            if ji < 1 || ji > n
                continue
            end
            adjm[ji, i] = adjm[i, ji] = d[i] == d[ji]
        end
    end
    PathGraph(adjm)
end

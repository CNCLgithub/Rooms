export Tile,
    Floor,
    Wall,
    Obstacle,
    floor_tile,
    wall_tile,
    obstacle_tile

import Base.convert

"""
Abstract type for tile
"""
abstract type Tile end

#################################################################################
# Generic methods for `Tile`
#################################################################################

"""
    get_tiles(::Room, ::Tile)

Returns all tile indices with the given tile type
"""
get_tiles(r::Room, t::Tile) = findall(==(t), data(r))


"""
    matched_tile(Array{Tile}, AbstractEdge)::Bool

Returns `true` if both nodes in an edge share the same type.
"""
matched_tile(d::Array{Tile}, e::AbstractEdge) = d[src(e)] == d[dst(e)]

# REVIEW: possible move to a graph_ops module
"""
Removes edges of a graph that do not have the same tile type
"""
function prune_edges!(g::PathGraph, d::Array{Tile})
    for e in collect(edges(g))
        !matched_tile(d, e) && rem_edge!(g, e)
    end
    return nothing
end

"""
    navigable(::Tile)

Whether a tile is navigable. False unless otherwise specified.
"""
navigable(::Tile) = false

#REVIEW: why this is needed?
Base.length(::Tile)  = 1
Base.iterate(t::Tile)  = (t, nothing)
Base.iterate(t::Tile, ::Nothing)  = nothing

"""
    edge_type(d::Array{Tile}, e::AbstractEdge, t::Tile)::Bool

Returns `true` if both nodes in `d` referenced in `e` have type `t`.
"""
edge_type(d::Array{Tile}, e::AbstractEdge, t::Tile) = (d[src(e)] == t) &&
    (d[dst(e)] == t)

#################################################################################
# Various helpers of `edge_type`
#################################################################################
floor_edge(d::Array{Tile}, e::AbstractEdge) = edge_type(d,e,floor_tile)
wall_edge(d::Array{Tile}, e::AbstractEdge) = edge_type(d,e,wall_tile)
obstacle_edge(d::Array{Tile}, e::AbstractEdge) = edge_type(d,e,obstacle_tile)


#################################################################################
# Tile instances
#################################################################################

struct Floor <: Tile end
const floor_tile = Floor()
navigable(::Floor) = true
Base.show(io::IO, ::Floor) = Base.print(io, '□')

struct Wall <: Tile end
const wall_tile = Wall()
navigable(::Wall) = false
Base.show(io::IO, ::Wall) = Base.print(io, '■')

struct Obstacle <: Tile end
const obstacle_tile = Obstacle()
navigable(::Obstacle) = false
Base.show(io::IO, ::Obstacle) = Base.print(io, '◆')

Base.convert(::Type{Symbol}, ::Floor) = :floor
Base.convert(::Type{Symbol}, ::Wall) = :wall
Base.convert(::Type{Symbol}, ::Obstacle) = :obstacle

const tile_d = Dict{Symbol, Tile}(
    :wall => wall_tile,
    :floor => floor_tile,
    :obstacle => obstacle_tile,
)
Base.convert(::Type{Tile}, s::Symbol) = tile_d[s]
Base.convert(::Type{Tile}, s::String) = tile_d[Symbol(s)]

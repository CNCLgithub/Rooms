"""
The [`Room`](@ref) module.

Exports:
$(EXPORTS)

Imports:
$(IMPORTS)

---

A simple API for 3D rooms in Julia

> This is a work in progress.

---

The [`LICENSE`](@ref) abbreviation can be used in the same way for the `LICENSE.md` file.
"""
module Rooms

#################################################################################
# Dependencies
#################################################################################

using JSON
using Graphs
# using Setfield
# using Statistics
using Parameters
# using LinearAlgebra
using OrderedCollections
using DocStringExtensions
# using SimpleWeightedGraphs
# using FunctionalCollections

#################################################################################
# Exports
#################################################################################

export Room,
    PathGraph,
    pathgraph,
    data,
    entrance,
    exits


"""
Abstract type for room
"""
abstract type Room end

"""
Rooms contain a graph over the paths in the room
"""
const PathGraph = SimpleGraph{Int64}

"""
    pathgraph(::Room)::PathGraph

Returns the pathgraph of the room.
Each node in the pathgraph corresponds to an index in
the data array.
"""
function pathgraph end

"""
    entrance(::Room)

Returns the entrance tiles of the room if any.
"""
function entrance end

"""
    exits(::Room)

Returns the exit tiles of the room, if any.
"""
function exits end


"""
    data(::Room)

Returns an array containing the tile data of the room.
Each index in the data array corresponds to a node
in the pathgraph.
"""
function data end

#################################################################################
# Module imports
#################################################################################

include("utils.jl")

include("tiles.jl")
include("grid_room.jl")
# REVIEW: remove?
# include("moves.jl")
# include("furniture.jl")

include("visualization/visualization.jl")

end # module Rooms

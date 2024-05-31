export RenderMethod,
    render


abstract type RenderMethod end


"""
    render(m::RenderMethod, r::Room)

Applies a render method to a room.
"""
function render(::RenderMethod, ::Room)
    error("not implemented")
end

include("cl.jl")
include("blender/blender.jl")

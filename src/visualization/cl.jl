export CommandLine

using Colors: RGB
using ImageInTerminal: imshow


const _default_colormap = Dict(
        floor_tile => RGB{Float32}(0, 0, 0),
        wall_tile => RGB{Float32}(0, 0, 1),
        obstacle_tile => RGB{Float32}(1, 0, 0)
    )

const _path_color = RGB{Float32}(0, 1, 0)


@with_kw struct CommandLine <: RenderMethod
    resolution::Tuple{Int, Int} = (400, 400)
    color_map::Dict{Tile, RGB{Float32}} = _default_colormap
    path_color::RGB{Float32} = _path_color
end

function render(m::CommandLine, r::GridRoom, p=Int64[])
    d = data(r)
    a = fill(m.color_map[floor_tile], steps(r))
    a[d .== obstacle_tile] .= m.color_map[obstacle_tile]
    a[d .== wall_tile] .= m.color_map[wall_tile]
    a[p] .= m.path_color
    # a = imresize(a, m.resolution)
    return a
end

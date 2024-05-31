using Rooms

r = GridRoom((10,20), (10.,20.), [4,5,6,7], [194]);
blender = Blender(mode = "full",
                  resolution = (720, 480));
isdir("output") || mkdir("output")
render(blender, r, "output/blender_render");

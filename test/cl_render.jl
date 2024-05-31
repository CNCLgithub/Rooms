using Rooms
using ImageInTerminal: imshow

r = GridRoom((10,20), (10.,20.), [5], [192]);
clr = CommandLine(resolution = (2, 2));
img = render(clr, r);
display(r);
imshow(img);

using Rooms


r = GridRoom((10,20), (10.,20.), [5], [192]);

display(data(r) .== floor_tile);
display(r);

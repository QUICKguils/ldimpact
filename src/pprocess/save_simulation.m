function save_simulation(Path, simName)

copyfile(Path.sim, fullfile(Path.res, simName))

end
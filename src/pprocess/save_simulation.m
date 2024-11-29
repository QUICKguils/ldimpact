function save_simulation(Path, simName)

copyfile(Path.metafor, fullfile(Path.res, simName))

end

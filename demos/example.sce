root = get_absolute_file_path("example.sce") + "../";
exec(root + "loader.sce", -1);
// G(s) = 10 / (s^2 + 2s + 10)
G = tfbode_system([10], [1 2 10]);
tfbode(G, 0.01, 100, "rad/s");
// Existing transfer functions work too:
s = %s;
H = syslin("c", (s + 3) / (s * (s + 2)));
tfbode(H, 0.001, 100, "Hz");
// Interactive entry: tfbode();

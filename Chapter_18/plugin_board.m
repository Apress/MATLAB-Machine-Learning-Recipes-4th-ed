function hB = plugin_board()
hB = hdlcoder.Board;
hB.BoardName = 'ZedBoard';

hB.FPGAVendor  = 'Xilinx';
hB.FPGAFamily  = 'Zynq';
hB.FPGADevice  = 'xc7z020';
hB.FPGAPackage = 'clg484';
hB.FPGASpeed   = '-1';

hB.SupportedTool = {'Xilinx Vivado'};
hB.JTAGChainPosition = 2;

hB.addExternalPortInterface( ...
    'IOPadConstraint', {'IOSTANDARD = LVCMOS18'});

hB.ExternalMemorySize = hex2dec('20000000');

end
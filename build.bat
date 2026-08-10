CALL .\GIT_VERSION.scad.bat

SET OPENSCAD_PATH="C:\Program Files\OpenSCAD (Nightly)\openscad.exe"
%OPENSCAD_PATH% -o "stl\ThreadedBarrelLiner_%GIT_BUILD%.stl" ThreadedBarrelLiner.scad
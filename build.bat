CALL .\GIT_VERSION.scad.bat

SET OPENSCAD_PATH="C:\Program Files\OpenSCAD (Nightly)\openscad.exe"
%OPENSCAD_PATH% -o "stl\RifledBarrelLiner_%GIT_BUILD%.3mf" -O export-3mf/material-type=color RifledBarrelLiner.scad
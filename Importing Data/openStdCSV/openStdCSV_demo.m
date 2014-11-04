% This file gives an example of how to run openStdCSV
%   The file, 'Example Standard CSV File.csv' must be on your file path

close all
clear all
clc

data = openStdCSV('Example Standard CSV File.csv');
data.raw
data.table
data.key
s = data.structured
s.cage_1
s.cage_1.mouse_1

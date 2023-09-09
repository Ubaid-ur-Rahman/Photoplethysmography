clear all;
close all;

VIDFOLDER='../../video/after-exercise/';

METHOD = 'Green';  % can be: Green, G-R, Chrom
VERBOSE = 1;

%%%%%%
% Get RGB traces
getTraceFromVidFile('VIDFOLDER', VIDFOLDER, 'VERBOSE', 1); 

%%%%%%
% Get Pulse from RGB traces
getPulseSignalFromTrace('VIDFOLDER', VIDFOLDER,'METHOD', METHOD, 'VERBOSE', 1);

%%%%%%
% Get HR from pulse
getHRFromPulse('VIDFOLDER', VIDFOLDER, 'VERBOSE', 1);
ma
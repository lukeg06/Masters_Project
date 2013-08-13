function [outputValues] = mm2pixel(inputValue)

outputValues = round(inputValue./0.32);
%outputValues = round(inputValue./0.7623);
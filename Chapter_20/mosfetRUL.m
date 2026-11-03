clear; clc; close all;
dataFolder = "/PowerMOSFETs/MOSFET_Thermal_Overstress_Aging_v0";
runIds = [26 29 32 35 36 38];
results = mosfetPreprocessing(dataFolder, runIds);
trainIds = [26 29 32 36];
testIds  = [35 38];
% Exponential model
expInfo       = mosfetTrainExp(results, trainIds);
mosfetEvaluateExp(results, expInfo, trainIds, 'Train');
mosfetEvaluateExp(results, expInfo, testIds,  'Test');
% LSTM model
 win = 10;
 ageScale = 1000;
 lstmInfo      = mosfetTrainLSTM(results, trainIds, win, ageScale);
 mosfetEvaluateLSTM(results, lstmInfo, trainIds, 'Train');
 mosfetEvaluateLSTM(results, lstmInfo, testIds,  'Test');
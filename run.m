clear all;

m_value1=2; m_value2=2; %number of m to set
cl1=[1,3]; %from multiclass to binary tasks, pair classes
cl2=[2,4];
n_t=3; %amount of time stages
time_stages = [1,250, 500, 500, 749, 999];
n_f=10; %amount of frequency components
frequency_components = [4,11,18,25,32,39,46,53,60,67,17,24,31,38,45,52,59,66,73,80];
en=5; %amount of cells to remove that have the lowest total energy
ev=10; %amount of cells to remove with ineffective information
k=5; %crossvalidation
nbSubject = 1; %number of subject
dataPrefix= '\2a\'; %location of Database

[acc] = database2_cros(m_value1,m_value2,cl1(1),cl2(1),n_f,frequency_components,time_stages,n_t,k,en,ev,nbSubject,dataPrefix);
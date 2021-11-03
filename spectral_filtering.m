function [EEG_filt] = spectral_filtering(EEG,Fs,a,b)
%design bandpass filter and run it to each channel time series
    Nyq=Fs/2;
    fLow=a/Nyq; 
    fHigh=b/Nyq;
    FilterOrder=5;
    [coef1, coef2]=butter(FilterOrder, [fLow,fHigh],'bandpass');
    EEG_filt = filter(coef1, coef2,EEG);
end

    
 
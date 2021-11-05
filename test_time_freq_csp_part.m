function [T] = test_time_freq_csp_part(X,W1,n_f,ff)

[n1, ch] = size(X);
X1F=fft(X); 

for k=1:n_f
X1Ft=X1F(ff(k):ff(k+n_f),:);
W1t=W1(:,:,k);
C1r{k} = (W1t'*X1Ft'*X1Ft*W1t)/trace(X1Ft'*X1Ft);
T1{k,1} = log(diag(C1r{k}));

end

T=cell2mat(T1);

end

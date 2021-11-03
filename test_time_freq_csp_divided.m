function [d1] = test_time_freq_csp_divided(X,W11,M1,M2,D,V,n_f,ff,tt,n_t,sw,Eij,ind_exl)
% Apply CSP classifier to a new chunk of data

T_all=[];

for ti=1:n_t
T1{ti} = test_csp_freq_time_best_part_ere(X(tt(ti):tt(ti+n_t),:),W11{ti},n_f,ff);
T_all=[T_all; T1{ti}];
end

T_all(ind_exl,:)=[];
T_all=T_all(Eij,:);

T_all = T_all.*sw';
T = V'*T_all;

d1 = sum((T-M1).^2./D);
d1 = d1-sum((T-M2).^2./D);

end

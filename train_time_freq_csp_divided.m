function [W11,M1,M2,D,V,sw,Eij,ind_exl] = train_time_freq_csp_divided(EEG,m_value,n_f,ff,tt,n_t,en1,ev1,sigma)


EE=[]; EN=[]; EI=[]; F1=[]; F2=[];

[n1, ch, tr] = size(EEG{1}); [n2, ch, tr2] = size(EEG{2});

%divide in time stages and send for frequency components decomposition,
%extract spatial patterns W11, lowest total energy EN and the lowest
%discriminative power cells EE, features for class1- F11, for class 2- F12
for ti=1:n_t
    D1=EEG{1}(tt(ti):tt(ti+n_t),:,:);
    D2=EEG{2}(tt(ti):tt(ti+n_t),:,:);
    [F11{ti},F12{ti},W11{ti},En1{ti},E11{ti},E1{ti}] = train_time_freq_csp_part(D1,D2,n_f,ff);

    EN=[EN En1{ti}]; EE=[EE E11{ti}];  EI=[EI; E1{ti}]; F1=[F1; F11{ti};]; F2=[F2; F12{ti}];
end

% find lowest energy and less informative cells
[Enn, Enj]=sort(EN); [Evv, Evj]=sort(EE);
excl_E=Enj(1:en1); excl_Ev=Evj(1:ev1);
exl_all=unique([excl_E excl_Ev]);
n_ex=size(exl_all,2);

for i=1:n_ex
    ind_exl(:,i)=((exl_all(i)-1)*ch+1):exl_all(i)*ch;
end
ind_exl=ind_exl(:);

%exclude these cells from features
F1(ind_exl,:)=[]; F2(ind_exl,:)=[]; EI(ind_exl,:)=[];
[Eii, Eij]=sort(EI, 'descend');
F1 = F1(Eij,:); F2 = F2(Eij,:);

%weight all features by a Gaussian function
new_c=ch*(n_f*n_t-(n_ex));
mt=m_value;
u=0:1:(new_c-1);
sw=exp(-u.^2/(2*(sigma).^2));
F1 = F1.*repmat(sw',1,tr); F2 = F2.*repmat(sw',1,tr2);

%Mahalanobis distance classifier
M1 = (mean(F1'))'; M2 = (mean(F2'))';
C1 = cov(F1'); C2 = cov(F2'); C = C1+C2;
[V, D] = eig(C); D = diag(D);
[D, Di] = sort(D, 'descend'); V = V(:,Di);
a = D(1)*D(mt)*(mt-1)/(D(1)-D(mt));
b = (mt*D(mt)-D(1))/(D(1)-D(mt));
D(1:mt) = D(1:mt)+D(round(new_c/2));
D(mt+1:new_c) = a./((mt+1:1:new_c)+b)+D(round(new_c/2));
M1 = V'*M1; M2 = V'*M2;

end

% fprintf('training finished.\n');

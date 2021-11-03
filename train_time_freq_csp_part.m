function [F111,F112,W11,En1,E11,Ee1] = train_time_freq_csp_part(D11,D12,n_f,ff)


% extract data for all epochs of the first class concatenated D11 and
% all epochs of the second class concatenated D12

[n1, ch, tr] = size(D11); [n2, ch, tr2] = size(D12);
C11 = zeros(ch,ch,n_f); C12 = C11;
C11e = zeros(ch,ch,n_f); C12e = C11e;

%Apply DFT
for i=1:tr
    D11s(:,:,i)=fft(D11(:,:,i));
end

for i=1:tr2
    D12s(:,:,i)=fft(D12(:,:,i));
end

%Decompose EEG time signal of each time stage into 10 groups of frequency component
for j=1:n_f
    for i=1:tr
        ccov11=D11s(ff(j):ff(j+n_f),:,i)'*D11s(ff(j):ff(j+n_f),:,i);
        C11(:,:,j)=C11(:,:,j)+ccov11./trace(ccov11);
        C11e(:,:,j)=C11e(:,:,j)+ccov11;
    end
    
    
    for i=1:tr2
        ccov12=D12s(ff(j):ff(j+n_f),:,i)'*D12s(ff(j):ff(j+n_f),:,i);
        C12(:,:,j)=C12(:,:,j)+ccov12./trace(ccov12);
        C12e(:,:,j)=C12e(:,:,j)+ccov12;
    end
    
    C11(:,:,j) = C11(:,:,j)/tr;
    C12(:,:,j)=C12(:,:,j)/tr2;
end

%Perform complex CSP on frequency components of each of the 30 time-frequency cells
for j=1:n_f
    [W1, E1] = eig(inv(C11(:,:,j)+C12(:,:,j))*C11(:,:,j));
    E1 = diag(E1);
    E1 = abs(E1-0.5); [E1, Ei] = sort(E1, 'descend');
    E11(j) = sum(E1(1:ch));
    Ee1(:,j)=E1(1:ch);
    W1(:,:,j) = W1(:,Ei);
    W11(:,:,j) = W1(:,1:ch);
end

%Extract features
for j=1:n_f
    for i=1:tr
        D11st=D11s(ff(j):ff(j+n_f),:,i);
        C11r = (W11(:,:,j)'*D11st'*D11st*W11(:,:,j))/trace(D11st'*D11st);
        F11(:,j,i) = log(diag(C11r));
    end
    En11(j) = sum(diag(W11(:,:,j)'*C11e(:,:,j)*W11(:,:,j)));
    
    for i=1:tr2
        D12st=D12s(ff(j):ff(j+n_f),:,i);
        C12r = (W11(:,:,j)'*D12st'*D12st*W11(:,:,j))/trace(D12st'*D12st);
        F12(:,j,i) = log(diag(C12r));
    end
    
    En12(j) = sum(diag(W11(:,:,j)'*C12e(:,:,j)*W11(:,:,j)));
    
end

F111=reshape(F11, ch*n_f,tr);
F112=reshape(F12, ch*n_f,tr2);
Ee1=reshape(Ee1, ch*n_f,1);

En1=En11+En12;

end
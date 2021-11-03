function [EEG_trials] = trials_maker_binary_cros(EEG_filt,EEG_filt_test,h1,classlabel,mrk1,wnd,db,cl1,cl2)

av=(h1.EVENT.POS(find(h1.EVENT.TYP==783)))';

gg1=repmat(find(mrk1==db+cl1),length(wnd),1);
gj1=repmat(wnd',1,nnz(find(mrk1==db+cl1)));
gk1=gg1+gj1;

gg11=repmat(av(find(classlabel==cl1)),length(wnd),1);
gj11=repmat(wnd',1,nnz(av(find(classlabel==cl1))));
gk11=gg11+gj11;

gg2=repmat(find(mrk1==db+cl2),length(wnd),1);
gj2=repmat(wnd',1,nnz(find(mrk1==db+cl2)));
gk2=gg2+gj2;

gg12=repmat(av(find(classlabel==cl2)),length(wnd),1);
gj12=repmat(wnd',1,nnz(av(find(classlabel==cl2))));
gk12=gg12+gj12;

for t1=1:1:size(gk1,2)
EEG_trials{1}(:,:,t1)=EEG_filt(gk1(:,t1),:);
end

for t1=1:1:size(gk11,2)
EEG_trials{1}(:,:,t1+size(gk1,2))=EEG_filt_test(gk11(:,t1),:);
end

for t2=1:1:size(gk2,2)
EEG_trials{2}(:,:,t2)=EEG_filt(gk2(:,t2),:);
end

for t2=1:1:size(gk12,2)
EEG_trials{2}(:,:,t2+size(gk2,2))=EEG_filt_test(gk12(:,t2),:);
end

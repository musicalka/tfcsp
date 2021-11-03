function [acc] = database2_cros(m_value1,m_value2,cl1,cl2,n_f,ff,tt,n_t,k,en1,ev1,nbSubject, dataPrefix)

%% === load training data,train and test===

l=nbSubject;
EEGDataFilename1 = [dataPrefix 'A0' int2str(l) 'T.gdf'];
EEGDataFilename2 = [dataPrefix 'A0' int2str(l) 'E.gdf'];
load([dataPrefix 'A0' int2str(l) 'E.mat']);
[s,h] = sload(EEGDataFilename1,0,'OVERFLOWDETECTION:OFF'); %load training data
[s1,h1] = sload(EEGDataFilename2,0,'OVERFLOWDETECTION:OFF'); %load testing data

EEG_tr=(s(:, 1:22)); %choose 22 EEG channels
Fs=h.SampleRate;
st=0*Fs; en=4*Fs; %4s window for trials

db=768; %database ques
a=1.5; b11=40; %filtering frequencies
mrk1=sparse(1,h.EVENT.POS',h.EVENT.TYP');

%filter butterworth
[EEG_filt]= spectral_filtering(EEG_tr,Fs,a,b11); %for all
wnd = round(st) : round(en);
[EEG_filt_test]= spectral_filtering(s1(:, 1:22),Fs,a,b11);

%create trials
[trainingEEGSignals] = trials_maker_binary_cros(EEG_filt,EEG_filt_test,h1,classlabel,mrk1,wnd,db,cl1,cl2);


for m_value=m_value1:m_value2
    
    subTrainingSets = cell(2,k);
    validationSets = cell(1,k);
    resul=cell(k,1);
    %dividing the data according to each class
    nbTrials1 = size(trainingEEGSignals{1},3);
    nbTrials2 = size(trainingEEGSignals{2},3);
    sizeChunk1 = floor(nbTrials1/k);
    sizeChunk2 = floor(nbTrials2/k);
    
    
    %generating the different training/testing sets of the cross validation
    score1=0;
    for iter1=1:k
        [m1,n1,v1] = size(trainingEEGSignals{1}) ;
        idx1 = randperm(v1) ;
        trainingEEGSignals_ra{1}(:,:,idx1)=trainingEEGSignals{1};
        
        [m2,n2,v2] = size(trainingEEGSignals{2}) ;
        idx2 = randperm(v2) ;
        trainingEEGSignals_ra{2}(:,:,idx2)=trainingEEGSignals{2};
        
        %computing the k-fold cross validation accuracy for each hyperparameter
        for iter=1:k
            subTrainingSetClass1 = trainingEEGSignals_ra{1}(:,:,[1:(iter-1)*sizeChunk1 (iter*sizeChunk1+1):nbTrials1]);
            subTrainingSetClass2 = trainingEEGSignals_ra{2}(:,:,[1:(iter-1)*sizeChunk2 (iter*sizeChunk2+1):nbTrials2]);
            subTrainingSets{1,iter}=subTrainingSetClass1;
            subTrainingSets{2,iter}=subTrainingSetClass2;
            validationSetClass1 = trainingEEGSignals_ra{1}(:,:,(iter-1)*sizeChunk1+1:(iter*sizeChunk1));
            cl1=ones(1,size(validationSetClass1,3));
            validationSetClass2 = trainingEEGSignals_ra{2}(:,:,(iter-1)*sizeChunk2+1:(iter*sizeChunk2));
            cl2=repmat(2,1,size(validationSetClass2,3));
            clear subTrainingSetClass1; clear subTrainingSetClass2;
            validationSets{iter} = cat(3,validationSetClass1, validationSetClass2);
            resul{iter}=[cl1';cl2'];
            clear validationSetClass1; clear validationSetClass2;
            
            
            EEG{1}=subTrainingSets{1,iter};
            EEG{2}=subTrainingSets{2,iter};
            
            j = -1.75:0.25:0.75;
            sigmaList = m_value+ j;
            %find best sigma
            [bestsigma, bestScore] = find_bestsigma(EEG,m_value,sigmaList,en1,ev1,5,n_f,ff,tt,n_t);
            %train model
            [W11,M1s,M2s,Dgs,Vs,sw,Eij,ind_exl] = train_time_freq_csp_divided(EEG,m_value,n_f,ff,tt,n_t,en1,ev1,bestsigma);
            %test model
            for g=1:size(validationSets{iter},3)
                [d1(g)] = test_time_freq_csp_divided(validationSets{iter}(:,:,g),W11,M1s,M2s,Dgs,Vs,n_f,ff,tt,n_t,sw,Eij,ind_exl);
                
            end
            localScore1 = eval_method(d1',resul{iter});
            score1 = score1 + localScore1;
            disp(['localscore => ' num2str(localScore1) '%']);
            
            
            
        end
    end
    disp(num2str(score1 / (k*k)));
    acc(m_value) = score1 / (k*k);
    
end
end
function [ bestsigma, bestScore] = find_bestsigma(trainingEEGSignals, m,sigmaList,en1,ev1, k,n_f,ff,tt,n_t)


% disp('generating the subtraining and validation sets for each fold...');
subTrainingSets = cell(2,k);
validationSets = cell(1,k);
resul=cell(k,1);
%dividing the data according to each class
nbTrials1 = size(trainingEEGSignals{1},3);
nbTrials2 = size(trainingEEGSignals{2},3);
sizeChunk1 = floor(nbTrials1/k);
sizeChunk2 = floor(nbTrials2/k);


%generating the different training/testing sets of the cross validation
for iter=1:k            
    subTrainingSetClass1 = trainingEEGSignals{1}(:,:,[1:(iter-1)*sizeChunk1 (iter*sizeChunk1+1):nbTrials1]);
    subTrainingSetClass2 = trainingEEGSignals{2}(:,:,[1:(iter-1)*sizeChunk2 (iter*sizeChunk2+1):nbTrials2]);
    subTrainingSets{1,iter}=subTrainingSetClass1;
    subTrainingSets{2,iter}=subTrainingSetClass2;
    validationSetClass1 = trainingEEGSignals{1}(:,:,(iter-1)*sizeChunk1+1:(iter*sizeChunk1));
    cl1=ones(1,size(validationSetClass1,3));
    validationSetClass2 = trainingEEGSignals{2}(:,:,(iter-1)*sizeChunk2+1:(iter*sizeChunk2));
    cl2=repmat(2,1,size(validationSetClass2,3));
    clear subTrainingSetClass1; clear subTrainingSetClass2;
    validationSets{iter} = cat(3,validationSetClass1, validationSetClass2);
    resul{iter}=[cl1';cl2'];
    clear validationSetClass1; clear validationSetClass2;
end

%evaluating the performances of the difference potential hyperparameters
bestScore = 0;

%computing the k-fold cross validation accuracy for each hyperparameter

for sigma=sigmaList
    score = 0;
    for iter=1:k
        EEG{1}=subTrainingSets{1,iter};
        EEG{2}=subTrainingSets{2,iter};
         [W11,M1s,M2s,Dgs,Vs,sw,Eij,ind_exl] = train_time_freq_csp_divided(EEG,m,n_f,ff,tt,n_t,en1,ev1,sigma); 

      
      for g=1:size(validationSets{iter},3)
        [d1(g,:)] = test_time_freq_csp_divided(validationSets{iter}(:,:,g),W11,M1s,M2s,Dgs,Vs,n_f,ff,tt,n_t,sw,Eij,ind_exl); 

      end
        localScore = eval_method(d1,resul{iter});
        score = score + localScore;
    end
    score = score / k;  
      disp(['m=' num2str(m) ',' 'sigma=' num2str(sigma) ' => ' num2str(score) '%']);
     
    if score > bestScore
        bestScore = score;
 
        bestsigma=sigma;

    end
end         
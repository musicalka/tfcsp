function accur = eval_method(d1,targets)

d1(d1>0)=2;
d1(d1<0)=1;
predictions = mode(d1,2);

accur =100-100* mean(predictions~=targets);

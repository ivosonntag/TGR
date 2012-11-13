function RMP = tgr_abf_RMP(data,Inputparameter)

for i = 1:max(length(data))
    dS = data{i}.dS;
    TestVm = mean(dS,2);
    RMP{i} = mean(TestVm(Inputparameter{i}.Baseline(1):Inputparameter{i}.Baseline(2)));
end
function RMP = tgr_abf_RMP(data,Inputparameter)

for i = 1:max(length(all_cells))
    dS = data{i};
    TestVm = mean(dS,2);
    RMP = mean(TestVm(Inputparameter{i}.Baseline(1):Inputparameter{i}.Baseline(2)));
end
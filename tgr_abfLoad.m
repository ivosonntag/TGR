function data = tgr_abfLoad(fn)

for i = 1:max(length(fn))
    [d,si,h] = abfload(fn{i});
    data{i}.dS = squeeze(d(:,1,:));
    data{i}.timebases = si*0.000001:si*0.000001:(si*0.000001)*size(d,1);
end

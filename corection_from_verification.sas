data NLSPHS10;
set NLSPHS9;
if unid=51070 then do;
email="cworrall@gunnisoncounty.org";
end;
if unid=51243 then do;
countyfull="Aroostook";
title="Aroostook Public Health District Liaison";
end;
if unid=51491 then do;
address1="32 Randolph Avenue";
email="linda.s.sanders@wv.gov";
end;
if unid=21309 then do;
ef14=3;
phy15="physician practices";
end;
if unid=71318 then delete;
if unid=24889 then do;
email="amercatante@stclaircounty.org";
end;
if unid=51340 then do;
countyfull="Mercer";
countypart="";
end;
if unid=33189 then do;
countyfull="New Haven";
countypart="";
uni16="colleges/universities";
end;

run;




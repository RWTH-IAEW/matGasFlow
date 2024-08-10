function [GN]= getHeater(GN,val)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

idx_pipe = GN.pipe.pipe_ID;
temp =table;  
for ii=1:length(idx_pipe)
temp.alpha_w_per_m2k(ii) = NaN;
temp.qext_w(ii)=NaN; 
end 

%% get information out of JSON-File

% alpha_w_per_m2k

try
    test = double(val.x_object.pipe.x_object.alpha_w_per_m2k);
    if any (test>0)
    warning ('Heater:  Heat transfer coefficients have been defined by pandapipes.')
    end 
catch
end

for ii=1:length(idx_pipe)
    try
        if test(ii)>0
            
            temp.alpha_w_per_m2k(ii)= val.x_object.pipe.x_object.alpha_w_per_m2k(ii);
        end
    catch
    end
end

% qext_w

try
    test_2 = double(val.x_object.pipe.x_object.qext_w);
    if any(test_2>0)
    warning ('Heater:  Heat transfer coefficients have been defined by pandapipes.')
    end 
catch
end

for ii=1:length(idx_pipe)
    try
    if test_2(ii)>0
            temp.qext_w(ii)= val.x_object.pipe.x_object.alpha_w_per_m2k(ii);
    end 
    catch  
    end
end

%% Define Heater 

if any(~isnan(temp.qext_w))

temp.isheater = ~isnan(temp.qext_w); 
temp.pipe_ID = idx_pipe; 
[row,col]= isnan(temp.qext_w); 
temp(row,:) = [];

for ii=1:length(temp.qext_w)
    temp.heater_ID(ii)=ii; 
end 
end 

end 
 
function [cstruct, cmap100, cmapSchwarz, cmapBlau] = rwthcolor()

cstruct.blau100 = [0, 84, 159]/255;
cstruct.blau75 = [64, 127, 183]/255;
cstruct.blau50 = [142,186,229]/255;
% cstruct.blau25 = [199, 221, 242]/255;
% cstruct.blau10 = [232, 241, 250]/255;

cstruct.schwarz100 = [0, 0, 0]/255;
cstruct.schwarz75 = [100, 101, 103]/255;
cstruct.schwarz50 = [156, 158, 159]/255;
% cstruct.schwarz25 = [207, 209, 210]/255;
% cstruct.schwarz10 = [236, 237, 237]/255;

cstruct.magenta100 = [227, 0, 102]/255;
cstruct.magenta75 = [233, 96, 136]/255;
cstruct.magenta50 = [241, 158, 177]/255;
% cstruct.magenta25 = [249, 210, 218]/255;
% cstruct.magenta10 = [253, 238, 240]/255;

cstruct.gelb100 = [255, 237, 0]/255;
cstruct.gelb75 = [255, 240, 85]/255;
cstruct.gelb50 = [255, 245, 155]/255;
% cstruct.gelb25 = [255, 250, 209]/255;
% cstruct.gelb10 = [255, 253, 238]/255;

cstruct.petrol100 = [0, 97, 101]/255;
cstruct.petrol75 = [45, 127, 131]/255;
cstruct.petrol50 = [125, 164, 167]/255;
% cstruct.petrol25 = [191, 208, 209]/255;
% cstruct.petrol10 = [230, 236, 236]/255;

cstruct.tuerkis100 = [0, 152, 161]/255;
cstruct.tuerkis75 = [0, 177, 183]/255;
cstruct.tuerkis50 = [137, 204, 207]/255;
% cstruct.tuerkis25 = [202, 231, 231]/255;
% cstruct.tuerkis10 = [235, 246, 246]/255;

cstruct.gruen100 = [87, 171, 39]/255;
cstruct.gruen75 = [141, 192, 96]/255;
cstruct.gruen50 = [184, 214, 152]/255;
% cstruct.gruen25 = [221, 235, 206]/255;
% cstruct.gruen10 = [242, 247, 236]/255;

cstruct.maigruen100 = [189, 205, 0]/255;
cstruct.maigruen75 = [208, 217, 92]/255;
cstruct.maigruen50 = [224, 230, 154]/255;
% cstruct.maigruen25 = [240, 243, 208]/255;
% cstruct.maigruen10 = [249, 250, 237]/255;

cstruct.orange100 = [246, 168, 0]/255;
cstruct.orange75 = [250, 190, 80]/255;
cstruct.orange50 = [253, 212, 143]/255;
% cstruct.orange25 = [254, 234, 201]/255;
% cstruct.orange10 = [255, 247, 234]/255;

cstruct.rot100 = [204, 7, 30]/255;
cstruct.rot75 = [216, 92, 65]/255;
cstruct.rot50 = [230, 150, 121]/255;
% cstruct.rot25 = [243, 205, 187]/255;
% cstruct.rot10 = [250, 235, 227]/255;

cstruct.bordeaux100 = [161, 16, 53]/255;
cstruct.bordeaux75 = [182, 82, 86]/255;
cstruct.bordeaux50 = [205, 139, 135]/255;
% cstruct.bordeaux25 = [229, 197, 192]/255;
% cstruct.bordeaux10 = [245, 232, 229]/255;

cstruct.violett100 = [97, 33, 88]/255;
cstruct.violett75 = [131, 78, 117]/255;
cstruct.violett50 = [168, 133, 158]/255;
% cstruct.violett25 = [210, 192, 205]/255;
% cstruct.violett10 = [237, 229, 234]/255;

cstruct.lila100 = [122, 111, 172]/255;
cstruct.lila75 = [155, 145, 193]/255;
cstruct.lila50 = [188, 181, 215]/255;
% cstruct.lila25 = [22, 218, 235]/255;
% cstruct.lila10 = [242, 240, 247]/255;

% cmap100 = colormap([
%     cstruct.blau100
%     cstruct.petrol100
%     cstruct.tuerkis100
%     cstruct.gruen100
%     cstruct.maigruen100
%     cstruct.gelb100
%     cstruct.orange100
%     cstruct.magenta100
%     cstruct.rot100
%     cstruct.bordeaux100
%     cstruct.violett100
%     cstruct.lila100
%     ]);
% 
% cmapSchwarz = colormap([
%     cstruct.schwarz100
%     cstruct.schwarz75
%     cstruct.schwarz50
%     cstruct.schwarz25
%     cstruct.schwarz10
%     ]);
% 
% cmapBlau = colormap([
%     cstruct.blau100
%     cstruct.blau75
%     cstruct.blau50
%     cstruct.blau25
%     cstruct.blau10
%     ]);
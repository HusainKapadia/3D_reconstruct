function [f, desc] = sift_file_to_mat(filename)

%read file
filestr = fileread(filename);
%%
%break it into lines
filebyline = regexp(filestr, '\n', 'split');
%% 
%split by fields
filebyfield = regexp(filebyline, ' ', 'split');

%%
%switch from cell vector of cell vectors into a 2D cell
fieldarray = vertcat(filebyfield{3:end-1});

%%
%convert all fields to numeric
numarray = str2double(fieldarray);
numarray = numarray';
%%
f = numarray(1:2,:);
desc = numarray(6:end,:);
end
function point_view_matrix = chaining(newmatches)

%initialize point view matrix with matched points in image 1
point_view_matrix = newmatches{1}(1,:);

for i = 1:length(newmatches)-1
    %fill in intersected points
    [~,ia,ib] = intersect(newmatches{i}(1,:), point_view_matrix(i,:));
    point_view_matrix(i+1,ib) = newmatches{i}(2,ia);
    
    %add new points
    [~,ia,~] = setxor(newmatches{i}(1,:), point_view_matrix(i,:));
    point_view_matrix = [point_view_matrix,[zeros(size(point_view_matrix,1)-2,length(ia));newmatches{i}(:,ia)]];
end

%% Treating Matches between last and first image pair:
newmatches_end = newmatches{end};
%CASE 1:
%points in first row of newmatches_end(i.e. points in last image) 
%already present in last row of PVM, 
%and that have matches in first row PVM
[~,ia,ib] = intersect(newmatches_end(1,:), point_view_matrix(end,:));
frame1_rep_check = newmatches_end(2,ia);
[~,iar,ibr] = intersect(frame1_rep_check,point_view_matrix(1,:));

for i = 1:length(ibr)
    point_view_matrix(:,ibr(i)) = point_view_matrix(:,ibr(i)) + point_view_matrix(:,ib(iar(i)));
end
point_view_matrix(:,ib(iar))=[];
newmatches_end(:,ia(iar))=[];

%CASE 2:
%points in first row of newmatches_end(i.e. points in last image) 
%that are not present in last row of PVM, that
%have matches in the first row of PVM
[~,ia,~] = setxor(newmatches_end(1,:), point_view_matrix(end,:));
frame1_rep_check = newmatches_end(2,ia);
[~,iar,ibr] = intersect(frame1_rep_check,point_view_matrix(1,:));
point_view_matrix(end,ibr) = newmatches_end(1,ia(iar));

newmatches_end(:,ia(iar)) = [];

%CASE 3:
%points in the first row of newmatches_end(i.e. points in last image) that are 
%already present in the last row of PVM
%but have no match in first row of PVM
[~,ia,ib] = intersect(newmatches_end(1,:), point_view_matrix(end,:));
point_view_matrix(1,ib) = newmatches_end(2,ia);

%CASE 4:
%points in the first row of newmatches_end(i.e. points in last image) that are 
%not present in the last row of PVM
%and have no match in first row of PVM
[~,ia,~] = setxor(newmatches_end(1,:), point_view_matrix(end,:));
point_view_matrix = [point_view_matrix,[newmatches_end(2,ia);zeros(size(point_view_matrix,1)-2,length(ia));newmatches_end(1,ia)]];


end
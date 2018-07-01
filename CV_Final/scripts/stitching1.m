%%  Extracting blocks of features that have matches in 3 consecutive images

%copying first three rows to the bottom of Point_view_matrix to complete the loop
PVM = [point_view_matrix; point_view_matrix(1:3,:)]; 

%Initializing Point_view_matrix blocks: PVMb
PVMb = cell(1,size(point_view_matrix,1));

%Initializing a cell array to store the column number of features in PVM
%that are in a block
column_no = cell(1,size(point_view_matrix,1));


for i = 1:size(point_view_matrix,1)
    for j = 1:size(PVM,2)
        if length(find(PVM(i:i+2,j)))==3
            PVMb{i} = [PVMb{i},PVM(i:i+2,j)];
            column_no{i} = [column_no{i},j];
        end
    end    
end

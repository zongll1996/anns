clear all;
clc;

% 修改kdtree.cpp文件后需要重新编译
% mex -g kdtree.cpp -I'FLANN\flann\include' -L'FLANN\flann\lib'

% 选择数据集
% vector_type = 'siftsmall';
vector_type = 'sift';
% vector_type = 'gist';

fprintf('start loading data\n');
if strcmp (vector_type, 'siftsmall')
    dataset = fvecs_read('siftsmall\siftsmall_base.fvecs');
    query = fvecs_read('siftsmall\siftsmall_query.fvecs');
    ids = ivecs_read ('siftsmall\siftsmall_groundtruth.ivecs');
elseif strcmp (vector_type, 'sift')
    dataset = fvecs_read('sift\sift_base.fvecs');
    query = fvecs_read('sift\sift_query.fvecs');
    ids = ivecs_read ('sift\sift_groundtruth.ivecs');
elseif strcmp (vector_type, 'gist')
    dataset = fvecs_read('gist/gist_base.fvecs');
    query = fvecs_read('gist/gist_query.fvecs');
    ids = ivecs_read ('gist/gist_groundtruth.ivecs');
else
    fprintf('error data type!');
    return;
end
fprintf('end loading data\n');

% 此处由于调用的是c++函数，返回的index从0开始，所以不用+1
ids_gnd = ids (1, :);

dataset = double(dataset);
query = double(query);

% search nearest nn vectors
nn = 100;

% The number of parallel kd-trees to use. Good values are in the range [1..16]
for tree = [8 16 32]
% for tree = [8]
    % specifies the maximum leafs to visit when searching for neighbours.
    for check = [128 512 1024 2048 8192]
%     for check = [128]
        fprintf('parameters：tree = %d; check = %d\n', tree, check);
        [indices_kdtree,dists_kdtree] = kdtree(dataset, query, nn, tree, check);
        compute_kdtree_stats;
    end
end
 
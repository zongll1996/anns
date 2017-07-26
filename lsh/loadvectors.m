% 根据vector_type类型读入数据
if strcmp (vector_type, 'siftsmall')
    ftrain = 'siftsmall/siftsmall_learn.fvecs';
    fbase = 'siftsmall/siftsmall_base.fvecs';
    fquery = 'siftsmall/siftsmall_query.fvecs';
    fgroundtruth = 'siftsmall/siftsmall_groundtruth.ivecs';
elseif strcmp (vector_type, 'sift')
    ftrain = 'sift/sift_learn.fvecs';
    fbase = 'sift/sift_base.fvecs';
    fquery = 'sift/sift_query.fvecs';
    fgroundtruth = 'sift/sift_groundtruth.ivecs';
elseif strcmp (vector_type, 'gist')
    ftrain = 'gist/gist_learn.fvecs';
    fbase = 'gist/gist_base.fvecs';
    fquery = 'gist/gist_query.fvecs';
    fgroundtruth = 'gist/gist_groundtruth.ivecs';
end
vtrain = fvecs_read (ftrain);
vbase  = fvecs_read (fbase);
vquery = fvecs_read (fquery);

ntrain = size (vtrain, 2);
nbase = size (vbase, 2);
nquery = size (vquery, 2);

% Load the groundtruth
ids = ivecs_read (fgroundtruth);
ids_gnd = ids (1, :) + 1;  % matlab indices start at 1
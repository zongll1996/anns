% Construct ANN ivfpq codes from a learning set
% This structure is used in particular by the IVFADC version
% 
% Usage: ivfpq = ivfpq_new (nsq, nsqbits, v)
% where
%   nsq      number of subquantizers
%   nsqbits  number of bits per subquantizer 
%   v        the set of vectors using for learning the structure
%
% This software is governed by the CeCILL license under French law and
% abiding by the rules of distribution of free software. 
% See http://www.cecill.info/licences.en.html
%
% This package was written by Herve Jegou
% Copyright (C) INRIA 2009-2011
% Last change: February 2011. 

function ivfpq = ivfpq_new (coarsek, nsq, v)

n = size (v, 2);     % number of vectors in the training set
d = size (v, 1);     % vector dimension
niter = 50;

% 粗量化映射到的中心点数目
ivfpq.coarsek = coarsek;

options.K                            = coarsek;
options.max_ite                      = niter;
options.init_random_mode             = 0;
options.normalize_sophisticated_mode = 0;
options.BLOCK_N1                     = 1024;
options.BLOCK_N2                     = 1024;
options.seed                         = 1234543;
options.num_threads                  = 2;
% first learn the coarse quantizer
% 向量集v进行粗量化聚类得到中心点centroids_tmp
ivfpq.coa_centroids = yael_kmeans (v, options);

% compute the residual vectors
% 计算v中的每个向量到中心点最近的向量下标，存到idx中
[idx, dis] = yael_nn (ivfpq.coa_centroids, v);
% 计算余量
v = v - ivfpq.coa_centroids(:, idx);

% learn the product quantizer on the residual vectors
% 为余量做乘积量化
ivfpq.pq = pq_new (nsq, v);


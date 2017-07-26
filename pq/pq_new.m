% Construct ANN pq codes from a learning set
% This structure is used in particular by the ADC version
% 
% Usage: pq = pq_new (nsq,  v)
% where
%   nsq      number of subquantizers (parameter m in the paper)
%   v        the set of vectors used for learning the structure
%
% This software is governed by the CeCILL license under French law and
% abiding by the rules of distribution of free software. 
% See http://www.cecill.info/licences.en.html
%
% This package was written by Herve Jegou
% Copyright (C) INRIA 2009-2011
% Last change: February 2011. 
function pq = pq_new (nsq, v)

n = size (v, 2);     % number of vectors in the training set
d = size (v, 1);     % vector dimension
ds = d / nsq;        % dimension of the subvectors to quantize
nsqbits = 8;         % the number of subquantizers is fixed to 8 in this implementation
ks = 2^nsqbits;      % number of centroids per subquantizer

pq.nsq = nsq;
pq.ks = ks;
pq.ds = ds;
pq.centroids = cell (nsq, 1);

options.K                            = ks;
options.max_ite                      = 100;
options.init_random_mode             = 0;
options.normalize_sophisticated_mode = 0;
options.BLOCK_N1                     = 1024;
options.BLOCK_N2                     = 1024;

options.seed                         = 1234543;
options.num_threads                  = 2;

% 原始向量按维度分为nsq组，每一组分别进行粗量化得到ks即ker个中心点，存储在pq.centroids中
% pq.centroids{q}表示第q组的中心点集合，每个集合中应该有ker个中心点
for q = 1:nsq
    vs = v((q-1) * ds + 1 : q *ds, :);
    pq.centroids{q} = yael_kmeans (vs, options);
end

% This function performs the search using the IVFADC method of a
% set vquery of vectors into a set cbase of codes encoded with pq
%
% Usage: [idx, dis] = ivfpq_search (pq, cbase, vquery, k)
%
% Parameters:
%  ivfpq    the ivfpq structure
%  ivf      the structure containing the vectors footprint
%  vquery   the set of query vectors (one vector per column)
%  k        the number of k nearest neighbors to return
%  w        the number of cells visited for each query (same notation as in the paper)
%
% Output: two matrices of size k*n, where n is the number of query vectors
%   ids     the identifiers (from 1) of the k-nearest neighbors
%           each column corresponds to a query vector. The row r corresponds 
%           to the estimated r-nearest neighbor (according to the algorithm)
%   dis     the *estimated* square distance between the query and the 
%           corresponding neighbor
% 
% Note: very slow implementation compared to our C version (see our paper for reference timings) 
%
% This software is governed by the CeCILL license under French law and
% abiding by the rules of distribution of free software. 
% See http://www.cecill.info/licences.en.html
%
% This package was written by Herve Jegou
% Copyright (C) INRIA 2009-2011
% Last change: February 2011. 
function [ids, dis] = ivfpq_search (ivfpq, ivf, vquery, k, w)
    
nq = size (vquery, 2);
d = size (vquery, 1);
ds = ivfpq.pq.ds;
ks = ivfpq.pq.ks;
nsq = ivfpq.pq.nsq;

distab  = zeros (ks, nsq, 'single');
dis = zeros (nq, k, 'single'); dis(:) = inf;
ids = zeros (nq, k, 'single'); ids(:) = -1;

% find the w nearest neighbors with respect to the coarse quantizer
% 找到vquery各个向量的w个最近的粗量化中心点id，形成w×n的矩阵coaidx
[coaidx, coadis] = yael_nn (ivfpq.coa_centroids, vquery, w);

% 循环遍历每一个查询向量集中的向量
for query = 1:nq

  if mod(query, 500)==0 fprintf('now is %dth vector\n', query); end
    
  % 查询这个向量对应的w个粗量化中心点id，存在w×1的向量qcoaidx中
  %qcoaidx = coaidx((query-1)*w+1:query*w);
  qcoaidx = coaidx (:, query);

  % compute the w residual vectors
  %v = repmat (vquery(:,query), 1, w) - ivfpq.coa_centroids(:,qcoaidx);
  % 用第query个查询向量与w个返回的中心点向量分别做差，得到w个向量的余量存在n×w的矩阵v中
  v = bsxfun (@minus, vquery (:, query), ivfpq.coa_centroids(:,qcoaidx));
  
  % indices and distances of the database vectors associated with the current query
  qidx = [];
  qdis = [];
  
  % 对于每个邻近的粗量化中心点
  for j = 1:w
    % pre-compute the table of squared distance to centroids
    % 计算distab：nsq×ks大小的矩阵，一个向量被分成nsq部分，每一部分到ks个中心点的距离
    for q = 1:nsq
      vsub = v ((q-1)*ds+1:q*ds, j);
      % 第q列存储第q部分到ks个pq中心点的距离
      distab (:,q) = yael_L2sqr (vsub, ivfpq.pq.centroids{q})';
    end 

    % add the tabulated distances to construct the distance estimators
    % distab指的是余量，与query向量相关；而codes指的是原始向量分配到各个pq中心点的id，与base向量相关
    % distab：一个向量余量的nsq部分与ks个中心点的距离；ivf.codes：遍历到的这个粗量化中心点中所存base向量余量的pq量化编码
    % 根据每个粗量化中心点先找base中分配到此粗量化中心点的向量pq编码，然后用这个编码从distab中找出所有分配到此粗量化中心点的base向量到这个query向量之间的距离
    % (n×w)×1的向量，其中n：分配到此coarse中心的base向量个数；w：一个查询向量形成w个余向量
    % n×w其实就是待选向量的个数
    qdis = [qdis ; sumidxtab(distab, ivf.codes{qcoaidx(j)}, 0)];
    % 分配到每个coarse中心点的base向量id
    qidx = [qidx ivf.ids{qcoaidx(j)}];
  end
   % 最终要返回k个邻近的向量，从待选向量中选出k个最小的来，获得这k个临近向量的距离dis1和qidex的索引ids1
   ktmp = min (k, length (qdis));
   [dis1, ids1] = yael_kmin (qdis, ktmp);
   
  % 第query个查询向量的查询结果，占一行
  dis(query, 1:ktmp) = dis1;
  ids(query, 1:ktmp) = qidx(ids1);
end




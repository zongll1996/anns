% This function allocates a set of codes to a set of vectors
% according to the IVFADC method. 
% A structure 'ivf' similar to an inverted file is returned. 
% It is implemented using two cell matlab structures, one for the vector
% identifiers and one for the product quantization codes. 
%
% This software is governed by the CeCILL license under French law and
% abiding by the rules of distribution of free software. 
% See http://www.cecill.info/licences.en.html
%
% This package was written by Herve Jegou
% Copyright (C) INRIA 2009-2011
% Last change: February 2011. 

function ivf = ivfpq_assign (ivfpq, v)

n = size (v, 2);
d = size (v, 1);

% find the indexes for the coarse quantizer
% base向量集中的各个向量到哪个粗量化后中心点最近，以下标形式存储在coaidx中
[coaidx, dumm] = yael_nn (ivfpq.coa_centroids, v);

% apply the product quantization on the residual vectors
% base向量分配到coarse中心点后计算原向量与中心点的余量
v = v - ivfpq.coa_centroids(:, coaidx);
% 利用余量进行乘积量化，再次进行pq分配
c = pq_assign (ivfpq.pq, v);

% prepare the inverted file: count occurences of each coarse centroid
% and prepare the list according to this cell population
% 计算base向量集粗量化分配到1到coarsek各个中心点的个数
ivf.cellpop = hist (double(coaidx), 1:ivfpq.coarsek);
% 对中心点进行排序，使得从小到大增长且分配到相同中心点的向量聚在一起
[coaidx, ids] = sort (coaidx);
% 将c的列按分配到coarse中心点的id排序
c = c(:, ids);

% 分配空间
ivf.ids = cell (ivfpq.coarsek, 1);   % vector identifiers
ivf.codes = cell (ivfpq.coarsek, 1);

% 对于每个粗量化得到的中心点，存储分配到这个中心点的base向量的id
% 以及向量各个部分分配到的pq中心点的id
pos = 1;
for i=1:ivfpq.coarsek
   nextpos = pos+ivf.cellpop(i);
   ivf.ids{i} = ids (pos:nextpos-1);
   % 第i个codes内容表示分配到第i个coarse的pos:nextpos-1个向量进行余量pq量化编码后的结果
   ivf.codes{i} = c (:, pos:nextpos-1);
   pos = nextpos;
end

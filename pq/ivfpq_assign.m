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
% base�������еĸ����������ĸ������������ĵ���������±���ʽ�洢��coaidx��
[coaidx, dumm] = yael_nn (ivfpq.coa_centroids, v);

% apply the product quantization on the residual vectors
% base�������䵽coarse���ĵ�����ԭ���������ĵ������
v = v - ivfpq.coa_centroids(:, coaidx);
% �����������г˻��������ٴν���pq����
c = pq_assign (ivfpq.pq, v);

% prepare the inverted file: count occurences of each coarse centroid
% and prepare the list according to this cell population
% ����base���������������䵽1��coarsek�������ĵ�ĸ���
ivf.cellpop = hist (double(coaidx), 1:ivfpq.coarsek);
% �����ĵ��������ʹ�ô�С���������ҷ��䵽��ͬ���ĵ����������һ��
[coaidx, ids] = sort (coaidx);
% ��c���а����䵽coarse���ĵ��id����
c = c(:, ids);

% ����ռ�
ivf.ids = cell (ivfpq.coarsek, 1);   % vector identifiers
ivf.codes = cell (ivfpq.coarsek, 1);

% ����ÿ���������õ������ĵ㣬�洢���䵽������ĵ��base������id
% �Լ������������ַ��䵽��pq���ĵ��id
pos = 1;
for i=1:ivfpq.coarsek
   nextpos = pos+ivf.cellpop(i);
   ivf.ids{i} = ids (pos:nextpos-1);
   % ��i��codes���ݱ�ʾ���䵽��i��coarse��pos:nextpos-1��������������pq���������Ľ��
   ivf.codes{i} = c (:, pos:nextpos-1);
   pos = nextpos;
end

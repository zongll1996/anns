function T = lshprep(type,Is,B,varargin)
% T = lshprep(TYPE,I,B,...)
%
%    Prepares the set of hash tables T using LSH functions I.
%    The data is converted to unary encoding *implicitly*
%    B is the max. number of items to look at in the union of buckets;
%    default is B=inf (i.e., no limit)
%
%    On return, the hash table T{j} has following fields:
%      type - the LSH scheme used
%      buckets - the identities of non-empty buckets;
%        buckets(i,:) is the key of the i-th bucket
%      bhash - the secondary hash table used to map the buckets;
%        it's a sparse vector, with bhash{i} = j 
%      Index - indices within the full data set; 
%        Index{i} is a vector with indices of elements in i-th bucket
%      I - the functions produced by lshfunc
%      Args - whatever was passed in additional args to lshprep
%      B - the requested maximal number of elements in a single bucket (may be inf)
%      count - the # of indexed elements    
%
% (C) Greg Shakhnarovich, TTI-Chicago  (2008)

if (nargin < 3)
  B = inf;
end

% 哈希表个数
l = length(Is);  % # of HT
% 向量中抽取的维数
k = Is(1).k;


% if (isinf(B))
%   fprintf(2,' B UNLIMITED');
% else
%   fprintf(2,'B=%d,',B);
% end
% fprintf(2,' %d keys %d tables\n',k,l);


% values used in bucket hashing

% 哈希表的构建
for j=1:l
  T(j).type = type; % 记录表类型【都是一样的，不是lsh就是e2lsh】
  T(j).Args = varargin; % 记录可变长变量，这里是空
  T(j).I = Is(j); % 将哈希表的一部分参数赋给I
  T(j).B = B; % 记录每个哈希桶的最大容量
  T(j).count = 0; % 表中向量的个数，最终会等于传入向量总数
  T(j).buckets = []; % 记录非空桶的id，buckets[i]表示存储的第i个非空桶的1×k的key
  % prepare T's table
  T(j).Index = {}; % 记录桶中向量的id，Index{i}表示存储的第i个桶中多个向量id（原始数据中的标号）
  T(j).verbose=1;

  % set up secondary hash table for buckets
  % max. index can be obtained by running lshhash on max. bucket
  % 哈希表中的桶哈希；虽然lshhash返回了两个值[hkey,hpos]，但这里只会取第一个hkey
  % 索引方法：根据二值向量的lshhash得到的key值（单值）寻找此向量对应的桶的id（桶号1,2,3...）
  % 其中数据的意义：此向量对应的桶的id（桶号1,2,3...）就是bhash中的数据
  % 初始化为了保证空间充足，使用二值向量ones(1,k)*255构建，使用lshhash可以得到一个key值（单值）的上界
  % 以后的二值向量通过lshhash得到的key必定在 1-lshhash(ones(1,k)*255) 之间，故可以直接索引得到
  T(j).bhash = cell(lshhash(ones(1,k)*255),1);
end



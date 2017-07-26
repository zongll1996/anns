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

% ��ϣ�����
l = length(Is);  % # of HT
% �����г�ȡ��ά��
k = Is(1).k;


% if (isinf(B))
%   fprintf(2,' B UNLIMITED');
% else
%   fprintf(2,'B=%d,',B);
% end
% fprintf(2,' %d keys %d tables\n',k,l);


% values used in bucket hashing

% ��ϣ��Ĺ���
for j=1:l
  T(j).type = type; % ��¼�����͡�����һ���ģ�����lsh����e2lsh��
  T(j).Args = varargin; % ��¼�ɱ䳤�����������ǿ�
  T(j).I = Is(j); % ����ϣ���һ���ֲ�������I
  T(j).B = B; % ��¼ÿ����ϣͰ���������
  T(j).count = 0; % ���������ĸ��������ջ���ڴ�����������
  T(j).buckets = []; % ��¼�ǿ�Ͱ��id��buckets[i]��ʾ�洢�ĵ�i���ǿ�Ͱ��1��k��key
  % prepare T's table
  T(j).Index = {}; % ��¼Ͱ��������id��Index{i}��ʾ�洢�ĵ�i��Ͱ�ж������id��ԭʼ�����еı�ţ�
  T(j).verbose=1;

  % set up secondary hash table for buckets
  % max. index can be obtained by running lshhash on max. bucket
  % ��ϣ���е�Ͱ��ϣ����Ȼlshhash����������ֵ[hkey,hpos]��������ֻ��ȡ��һ��hkey
  % �������������ݶ�ֵ������lshhash�õ���keyֵ����ֵ��Ѱ�Ҵ�������Ӧ��Ͱ��id��Ͱ��1,2,3...��
  % �������ݵ����壺��������Ӧ��Ͱ��id��Ͱ��1,2,3...������bhash�е�����
  % ��ʼ��Ϊ�˱�֤�ռ���㣬ʹ�ö�ֵ����ones(1,k)*255������ʹ��lshhash���Եõ�һ��keyֵ����ֵ�����Ͻ�
  % �Ժ�Ķ�ֵ����ͨ��lshhash�õ���key�ض��� 1-lshhash(ones(1,k)*255) ֮�䣬�ʿ���ֱ�������õ�
  T(j).bhash = cell(lshhash(ones(1,k)*255),1);
end



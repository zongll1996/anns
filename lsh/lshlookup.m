function [iNN,cand] = lshlookup(x0,x,T,varargin)
% [iNN,cand] = lshlookup(x0,x,T)
%
%   iNN contains indices of matches in T for a single query x0;
%   x is the representation in the feature space; assumes to be a cell
%   array with equal size cells (this is a hack around Matlab's problem
%   with allocating large contiguous chunks of memory);
%   dfun is the dist. function ('l1','l2','cos')
%   
%   returns in iNN the indices of the found NN; cand is the # of 
%   examined candidates (i.e., size of the union of the matching buckets
%   in all tables)
%
% Optional arguments:
%
%   'k' : if given, return this many neighbors (default 1)
%   'sel' : if 'random', select random neighbors matching other
%     criteria. If 'best', select best (closest) matches. Default is 'best'.
%   'r' : max. distance cut-off
%   'distfun', 'distargs' : distance function (and additional args.) to
%     use. Default: L1 if T.type is 'lsh' and L2 if it's 'e2lsh'.
%   'verb' : verbosity (overrides T.verbose)
%
% (C) Greg Shakhnarovich, TTI-Chicago (2008)

% 设置默认参数值
distfun='lpnorm';
switch T(1).type,
 case 'lsh', distargs={1};
 case 'e2lsh', distargs={2};
end
k=1;
r=inf;
sel='best';
f=[];
fargs=[];
verb=T(1).verbose;

% parse args.
for a=1:2:length(varargin)
  eval(sprintf('%s = varargin{a+1};',varargin{a}));
end


l = length(T);

iNN=[];

% find the union of buckets in all tables that match query
for j=1:l
  % look up T_j
  % buck is the # of bucket in T{j}
  % buck(即#)指的是桶的128/129二值向量key
  buck = findbucket(T(j).type,x0,T(j).I);
  % find the bucket in j-th table
  % 二值向量key计算单值key
  key = lshhash(buck);
  % 通过单值key找到对应的桶号【T(j).buckets中对应桶号存放的值可能会命中（等于）此二值向量】
  ihash = T(j).bhash{key}; % possible matching buckets
  if (~isempty(ihash)) % nothing matches
    % 找到桶key与此向量对应二值向量相等的桶号
    b = ihash(find(all(bsxfun(@eq,buck,T(j).buckets(ihash,:)),2)));
    if (~isempty(b))
      % 将找到的桶中的向量id取出
      iNN = [iNN T(j).Index{b}];
    end
  end
end

% delete duplicates
% 所有哈希表中结果取并集
[iNN,iu]=unique(iNN);
cand = length(iNN);

% now iNN has the collection of candidate indices 
% we can start examining them

if (verb > 0)
  fprintf('Examining %d candidates\n',cand);
end

if (~isempty(iNN))
  
  if (strcmp(sel,'best'))

    % 计算出x0到找出的k个向量的所有距离，存到1×k的向量中【此处的k指的是k邻近】
    D=feval(distfun,x0,Xsel(x,iNN),distargs{:});
    % 距离从小到大排序
    [dist,sortind]=sort(D);
    % rNN查询用到的，需传入r参数，找到既满足k邻近又满足距离小于等于r的向量index
    % 如果k不传入，默认为1，即找最邻近
    ind = find(dist(1:min(k,length(dist)))<=r);
    iNN=iNN(sortind(ind));
    
  else % random
    % 在查询结果集中随机找k个向量
    rp=randperm(cand);
    choose=[];
    for i=1:length(rp)
      d = feval(distfun,x0,Xsel(x,iNN(rp(i))),distargs{:});
      if (d <= r)
        choose = [choose iNN(rp(i))];
        if (length(choose) == k)
          break;
        end
      end
    end
    iNN = choose;
  end
  
end
if length(iNN)<k
    iNN = [iNN zeros(1, k-length(iNN))-1];
end



%%%%%%%%%%%%%%%%%%%%%%%%55 
function x=Xsel(X,ind)
% x=Xsel(X,ind)
% selects (i.e. collects) columns of cell array X
% (automatically determining the class, and looking for each column in
% the right cell.)

if (~iscell(X))
  x=X(:,ind);
  return;
end

d=size(X{1},1);

if (strcmp(class(X{1}),'logical'))
  x=false(d,length(ind));
else
  x=zeros(d,length(ind),class(X{1}));
end
sz=0; % offset of the i-th cell in X
collected=0; % offset within x
for i=1:length(X)
  thisCell=find(ind > sz & ind <= sz+size(X{i},2));
  if (~isempty(thisCell))
    x(:,thisCell)=X{i}(:,ind(thisCell)-sz);
  end
  collected=collected+length(thisCell);
  sz=sz+size(X{i},2);      
end

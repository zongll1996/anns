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

% ����Ĭ�ϲ���ֵ
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
  % buck(��#)ָ����Ͱ��128/129��ֵ����key
  buck = findbucket(T(j).type,x0,T(j).I);
  % find the bucket in j-th table
  % ��ֵ����key���㵥ֵkey
  key = lshhash(buck);
  % ͨ����ֵkey�ҵ���Ӧ��Ͱ�š�T(j).buckets�ж�ӦͰ�Ŵ�ŵ�ֵ���ܻ����У����ڣ��˶�ֵ������
  ihash = T(j).bhash{key}; % possible matching buckets
  if (~isempty(ihash)) % nothing matches
    % �ҵ�Ͱkey���������Ӧ��ֵ������ȵ�Ͱ��
    b = ihash(find(all(bsxfun(@eq,buck,T(j).buckets(ihash,:)),2)));
    if (~isempty(b))
      % ���ҵ���Ͱ�е�����idȡ��
      iNN = [iNN T(j).Index{b}];
    end
  end
end

% delete duplicates
% ���й�ϣ���н��ȡ����
[iNN,iu]=unique(iNN);
cand = length(iNN);

% now iNN has the collection of candidate indices 
% we can start examining them

if (verb > 0)
  fprintf('Examining %d candidates\n',cand);
end

if (~isempty(iNN))
  
  if (strcmp(sel,'best'))

    % �����x0���ҳ���k�����������о��룬�浽1��k�������С��˴���kָ����k�ڽ���
    D=feval(distfun,x0,Xsel(x,iNN),distargs{:});
    % �����С��������
    [dist,sortind]=sort(D);
    % rNN��ѯ�õ��ģ��贫��r�������ҵ�������k�ڽ����������С�ڵ���r������index
    % ���k�����룬Ĭ��Ϊ1���������ڽ�
    ind = find(dist(1:min(k,length(dist)))<=r);
    iNN=iNN(sortind(ind));
    
  else % random
    % �ڲ�ѯ������������k������
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

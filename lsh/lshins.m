function T = lshins(T,x,ind)
% T = lshins(T,X)
%
%     insert data (columns of X) into T
% 
% NOTE: LSH will only index the data - not store it! You need to keep
% around the original data, in order to go back from indices to actual
% points, if that's what you want to do.
%
% T = lshins(T,X,IND)
%   instead of assuming that columns of X have indices 1..size(X,2), uses IND
%    
%
% (C) Greg Shakhnarovich, TTI-Chicago (2008)


% fields of T:
% buckets : bukets(j,:) is the hash key of bucket j
% Index : Index{j} contains indices of data in bucket j
% count : count(j) contains the size of bucket j

if (nargin < 3 || isempty(ind))
  ind=1:size(x,2);
end

% 对每一个哈希表执行将向量插入到哈希桶中的操作
% 【注：上述向量指的是原始向量（id）】
% insert in each table
for j=1:length(T)
  
  % the # of buckets before new data
  oldBuckets=size(T(j).buckets,1);
  
  % find, for each data point, the corresp. bucket
  % bucket numbers are represented as arrays of uint8
  buck = findbucket(T(j).type,x,T(j).I);
  % now x(:,n) goes to bucket with key uniqBuck(bID(n))
    
  
  [uniqBuck,ib,bID] = unique(buck,'rows');
  % 按向量在特定k个维度上值是否小于threshold进行分类
  % 每个分类对应一个桶，每个桶用1×k的128/129的二值向量作为key
  % 对于一共size(uniqBuck)【<=n】个桶，每个桶进行桶哈希映射lshhash得到一个key作为桶的key
  % 所以keys是一个size(uniqBuck)×1的向量，存储每个桶的key
  keys = lshhash(uniqBuck);
  
%   if (T(j).verbose > 0)
%     fprintf(2,'%d distinct buckets\n',length(ib));
%   end
  
  % 预分配内存：分配最大内存，在122行进行多余内存的删除
  % allocate space for new buckets -- possibly excessive
  T(j).buckets=[T(j).buckets; zeros(length(ib),T(j).I.k,'uint8')];
  
  newBuckets=0;
  
  % 对经过去除重复后的每一个向量进行插入哈希桶的操作（并不是插入一个，而是插入与此向量相同的一组）
  % 【注：上述向量指的是向量经过阈值处理后对应的128/129二值向量】
  for b=1:length(ib)
    % find which data go to bucket uniqBuck(b)
    % ib中存放的是消除重复后向量的id（行号），每个id可能对应多个相同向量
    % 下面操作即找出所有与ib中的第b个id对应向量相同的向量形成一个向量组
    % 每组向量的id存在thisBucket中，表示这些向量要放入此bucket
    thisBucket = find(bID==bID(ib(b)));
    
    % find out if this bucket already has anything
    % first, which bucket is it?
    ihash = T(j).bhash{keys(b)}; % possible matching buckets
    if (isempty(ihash)) % nothing matches
      isb = [];
    else % may or may not match
      % ihash存储桶的id（桶号1,2,3...）以ihash作为索引找到T(j).buckets里面按行存放的1×k大小的桶的128/129二值向量
      % 这一句是找到uniqBuck中存放的二值向量在T(j).buckets中已经存在的那些id
      % 通过单值key（二值向量lshhash得到）用bhash索引得到若干个桶id（桶号1,2,3...）
      % 然后去看这个二值向量与这些桶中哪个桶中的二值向量相同，找到符合条件的桶id存到isb中（应该是一个）
      isb = ihash(find(all(bsxfun(@eq,uniqBuck(b,:),T(j).buckets(ihash,:)),2)));
    end
    
    % note: this search is the most costly operation
    %isb = find(all(bsxfun(@eq,uniqBuck(b,:),T(j).buckets),2));
    
    if (~isempty(isb)) 
      % adding to an existing bucket.
      oldcount=length(T(j).Index{isb}); % # elements in the bucket prior
                                        % to addition
      % 此处ind(thisBucket) = thisBucket
      newIndex = [T(j).Index{isb}  ind(thisBucket)];
    else
      % 说明在T(j).buckets中没有找到向量应该被放入的桶，那么就增加一个
      % creating new bucket
      newBuckets=newBuckets+1;
      oldcount=0;
      % 上面说过isb是符合条件(向量应该放入)的桶id，没有的话就将isb指向最后一个桶号
      isb = oldBuckets+newBuckets;
      % 将此向量对应的二值向量key存到新创建的桶中
      T(j).buckets(isb,:)=uniqBuck(b,:);
      % 通过 此向量对应的二值向量key经lshhash后得到的 单值key可以映射到的桶id中加入新创建的桶id
      T(j).bhash{keys(b)} = [T(j).bhash{keys(b)}; isb];
      newIndex = ind(thisBucket);
    end
    
    % if there is a bound on bucket capacity, and the bucket is full,
    % keep a random subset of B elements (note: we do this rather than
    % simply skip the new elements since that could introduce bias
    % towards older elements.)
    % There is still a bias since older elements have more chances to get
    % thrown out.
    if (length(newIndex) > T(j).B)
      rp=randperm(length(newIndex));
      newIndex = newIndex(rp(1:T(j).B));
    end
    % ready to put this into the table
    % 实际上就是在 原来的桶号对应向量id 中加入了新加入的向量id
    % 所以newIndex并不是新添加的向量id而是 旧的id+新的id，所以后面count要减去oldcount
    T(j).Index{isb}= newIndex;
    % update distinct element count
    T(j).count = T(j).count + length(newIndex)-oldcount;
    
  end
  % we may not have used all of the allocated bucket space
  % 删除53行多分配的内存，节约内存空间
  T(j).buckets=T(j).buckets(1:(oldBuckets+newBuckets),:);
%   if (T(j).verbose > 0)
%     fprintf(2,'Table %d adding %d buckets (now %d)\n',j,newBuckets,size(T(j).buckets,1));
%     fprintf(2,'Table %d: %d elements\n',j,T(j).count);
%   end
end




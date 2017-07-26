clear all;
clc;
% 1. 读入数据文件
fprintf('start reading data...\n');
% vector_type = 'siftsmall';
vector_type = 'sift';
% vector_type = 'gist';
loadvectors;
d = size (vtrain, 1);

for L = [5 10 20 50]     % 哈希表的个数L
    for k = [16 32 64]     % 哈希表的key的位数k
        fprintf('L = %d; k = %d\n', L, k);
        % 2. 为base向量建立lsh索引结构
        fprintf('start generating index...\n');
        t0 = cputime;
        % range指的是阈值threshold的上界
        lshTable = lsh('lsh',L,k,d,vbase,'range',255);
        indextime = cputime - t0;
        fprintf('lsh generate index time: %gs\n', indextime);

        % 3. 查询
        fprintf('start searching vectors...\n');
        % search nn nearerst neighbour
        nn = 100;
        t0 = cputime;
        searchResult = zeros(size(vquery,2), nn);
        fprintf('number of all vectors is %d\n', size(vquery,2)); 
        for i = 1:size(vquery,2)
            if mod(i, 500) == 0
                fprintf('now is %dth vector\n', i);
            end
            [nnlsh, numcand] = lshlookup(vquery(:,i), vbase, lshTable, 'k', nn, 'distfun', 'lpnorm', 'distargs', {1});
            searchResult(i,:) = nnlsh;
        end
        searchtime = cputime - t0;
        fprintf('lsh search vectors time: %gs; ', searchtime);
        fprintf('number of failures in %d is %d\n', size(vquery,2), size(vquery,2)-sum(sum(searchResult==-1, 2)==0));

        % 4. 计算recall@R，这里需要保证R<=nn
        fprintf('start compute recall...\n');
        R = 100;
        nn_ranks_lsh = zeros (size(vquery,2), 1);
        if R <= nn
            for i = 1:size(vquery,2)
                gnd_ids = ids_gnd(i);
                nn_pos = find (searchResult(i, :) == gnd_ids);
                if length (nn_pos) == 1
                    nn_ranks_lsh (i) = nn_pos;
                else
                    nn_ranks_lsh (i) = nn + 1; 
                end
            end
            nn_ranks_lsh = sort (nn_ranks_lsh);
            
            for i = [1 2 5 10 20 50 100 200 500 1000 2000 5000 10000]
              if i <= nn
                r_at_i = length (find (nn_ranks_lsh <= i & nn_ranks_lsh <= nn)) / size(vquery,2) * 100;
                fprintf ('r@%3d = %.3f\n', i, r_at_i); 
              end
            end
            
        else
            fprintf('wrong! cause R > nn!\n');
        end

        % 查看lsh结构
%         lshstats(lshTable);
        
    end
end

% % 2. 为base向量建立lsh索引结构
% fprintf('start generating index...\n');
% t0 = cputime;
% % range指的是阈值threshold的上界
% % % 哈希表的个数L
% % L = 20;
% % % 哈希表的key的位数k
% % k = 32;
% lshTable = lsh('lsh',L,k,d,vbase,'range',255);
% % lshTable = lsh('e2lsh',50,30,d,vbase,'range',255,'w',-4);
% indextime = cputime - t0;
% fprintf('lsh generate index time: %gs\n', indextime);
% 
% % 3. 查询
% fprintf('start searching vectors...\n');
% % search nn nearerst neighbour
% nn = 100;
% t0 = cputime;
% searchResult = zeros(size(vquery,2), nn);
% fprintf('number of all vectors is %d\n', size(vquery,2)); 
% for i = 1:size(vquery,2)
%     if mod(i, 500) == 0
%         fprintf('now is %dth vector\n', i);
%     end
%     [nnlsh, numcand] = lshlookup(vquery(:,i), vbase, lshTable, 'k', nn, 'distfun', 'lpnorm', 'distargs', {1});
%     searchResult(i,:) = nnlsh;
% end
% searchtime = cputime - t0;
% fprintf('lsh search vectors time: %gs\n', searchtime);
% 
% % 4. 计算recall@R，这里需要保证R<=nn
% fprintf('start compute recall...\n');
% R = 100;
% nn_ranks_lsh = zeros (size(vquery,2), 1);
% if R <= nn
%     for i = 1:size(vquery,2)
%         gnd_ids = ids_gnd(i);
%         nn_pos = find (searchResult(i, :) == gnd_ids);
%         if length (nn_pos) == 1
%             nn_ranks_lsh (i) = nn_pos;
%         else
%             nn_ranks_lsh (i) = nn + 1; 
%         end
%     end
%     nn_ranks_lsh = sort (nn_ranks_lsh);
%     r_at_i = length (find (nn_ranks_lsh <= R)) / size(vquery,2) * 100;
%     fprintf ('Recall@100 = %g%%\n', r_at_i); 
% else
%     fprintf('wrong! cause R > nn!\n');
% end

% 查看lsh结构
% lshstats(lshIndex);

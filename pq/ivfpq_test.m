% 1. 文件读入向量
% dataset = 'siftsmall';
dataset = 'sift';
pq_test_load_vectors;

% 2. 不同参数的ivfpq
k = 100;              % number of elements to be returned
nsq = 8;              % number of subquantizers to be used (m in the paper)
% coarsek = 256;        % number of centroids for the coarse quantizer
% w = 4;                % number of cell visited per query
% pqk = 256;            % pq量化中心点个数，程序中默认的256

for coarsek = [1024 2048 8192]
    
    % 1. 用vtrain向量集训练
    t0 = cputime;
    ivfpq = ivfpq_new (coarsek, nsq, vtrain);
    tpqlearn = cputime - t0;
    fprintf ('learntime = %gs\n', tpqlearn);

    % 2. 将vbase向量分配到训练好的倒排表中
    t0 = cputime;
    ivf = ivfpq_assign (ivfpq, vbase);
    tpqencode = cputime - t0;
    fprintf ('indextime = %gs\n', tpqencode);
    
    for w = [1 8 64]
        fprintf('parameters：coarsek = %d; w = %d\n', coarsek, w);
        
        % 3. 对vquery向量进行进行检索，结果为找到的base向量的index，存储在ids_pqc中
        t0 = cputime;
        [ids_pqc, dis_pqc] = ivfpq_search (ivfpq, ivf, vquery, k, w);
        tpqsearch = cputime - t0;
        fprintf ('searchtime = %gs\n', tpqsearch);

        % 4. 计算Recall
        pq_test_compute_stats
    end
end
            

% % 用vtrain向量集训练
% % Learn the PQ code structure
% t0 = cputime;
% ivfpq = ivfpq_new (coarsek, nsq, vtrain);
% tpqlearn = cputime - t0;
% 
% % 将vbase向量分配到训练好的倒排表中
% % encode the database vectors: ivf is a structure containing two sets of k cells
% % Each cell contains a set of idx/codes associated with a given coarse centroid
% t0 = cputime;
% ivf = ivfpq_assign (ivfpq, vbase);
% tpqencode = cputime - t0;
% 
% % 对vquery向量进行进行检索，结果为找到的base向量的index，存储在ids_pqc中
% %---[ perform the search and compare with the ground-truth ]---
% t0 = cputime;
% [ids_pqc, dis_pqc] = ivfpq_search (ivfpq, ivf, vquery, k, w);
% tpqsearch = cputime - t0;
% 
% fprintf ('IVFADC learn  = %gs; encode = %gs; search = %gs\n', tpqlearn, tpqencode, tpqsearch);
% 
% %---[ Compute search statistics ]---
% pq_test_compute_stats

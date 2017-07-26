% 1. �ļ���������
% dataset = 'siftsmall';
dataset = 'sift';
pq_test_load_vectors;

% 2. ��ͬ������ivfpq
k = 100;              % number of elements to be returned
nsq = 8;              % number of subquantizers to be used (m in the paper)
% coarsek = 256;        % number of centroids for the coarse quantizer
% w = 4;                % number of cell visited per query
% pqk = 256;            % pq�������ĵ������������Ĭ�ϵ�256

for coarsek = [1024 2048 8192]
    
    % 1. ��vtrain������ѵ��
    t0 = cputime;
    ivfpq = ivfpq_new (coarsek, nsq, vtrain);
    tpqlearn = cputime - t0;
    fprintf ('learntime = %gs\n', tpqlearn);

    % 2. ��vbase�������䵽ѵ���õĵ��ű���
    t0 = cputime;
    ivf = ivfpq_assign (ivfpq, vbase);
    tpqencode = cputime - t0;
    fprintf ('indextime = %gs\n', tpqencode);
    
    for w = [1 8 64]
        fprintf('parameters��coarsek = %d; w = %d\n', coarsek, w);
        
        % 3. ��vquery�������н��м��������Ϊ�ҵ���base������index���洢��ids_pqc��
        t0 = cputime;
        [ids_pqc, dis_pqc] = ivfpq_search (ivfpq, ivf, vquery, k, w);
        tpqsearch = cputime - t0;
        fprintf ('searchtime = %gs\n', tpqsearch);

        % 4. ����Recall
        pq_test_compute_stats
    end
end
            

% % ��vtrain������ѵ��
% % Learn the PQ code structure
% t0 = cputime;
% ivfpq = ivfpq_new (coarsek, nsq, vtrain);
% tpqlearn = cputime - t0;
% 
% % ��vbase�������䵽ѵ���õĵ��ű���
% % encode the database vectors: ivf is a structure containing two sets of k cells
% % Each cell contains a set of idx/codes associated with a given coarse centroid
% t0 = cputime;
% ivf = ivfpq_assign (ivfpq, vbase);
% tpqencode = cputime - t0;
% 
% % ��vquery�������н��м��������Ϊ�ҵ���base������index���洢��ids_pqc��
% %---[ perform the search and compare with the ground-truth ]---
% t0 = cputime;
% [ids_pqc, dis_pqc] = ivfpq_search (ivfpq, ivf, vquery, k, w);
% tpqsearch = cputime - t0;
% 
% fprintf ('IVFADC learn  = %gs; encode = %gs; search = %gs\n', tpqlearn, tpqencode, tpqsearch);
% 
% %---[ Compute search statistics ]---
% pq_test_compute_stats

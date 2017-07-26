# anns
　　代码实现了三种ANNS方法：kdtree、lsh、pq，分别位于对应名字的文件夹中<br>
　　注：运行代码之前应将需要使用的数据集放到对应的文件夹下，如基于sift数据集运行kdtree方法则需要将sift文件夹复制到kdtree文件夹下，sift文件夹中内容为：sift_base.fvecs、sift_groundtruth.ivecs、sift_learn.fvecs、sift_query.fvecs四个文件，下载地址为：http://corpus-texmex.irisa.fr/
## kdtree方法的运行方式：
　　使用matlab打开kdtree文件夹下的kdtreemain.m文件，运行即可。<br>
　　可以修改的参数：（参数具体描述参见实验报告）<br>
　　--trees：并行查找kd树的个数<br>
　　--check：查找的最大叶节点个数<br>
　　注：如果修改了调用flann库的c++文件kdtree.cpp，则需要将第五行的语句“% mex -g kdtree.cpp -I'FLANN\flann\include' -L'FLANN\flann\lib'”取消注释，重新编译生成.mexw64文件<br>
## lsh方法的运行方式：
　　使用matlab打开lsh文件夹下的lshmain.m文件，运行即可。<br>
　　可以修改的参数：（参数具体描述参见实验报告）<br>
　　--L：哈希表的个数<br>
　　--k：哈希表key的位数<br>
## pq方法的运行方式：
　　使用matlab打开pq文件夹下的ivfpq_test.m文件，运行即可。<br>
　　可以修改的参数：（参数具体描述参见实验报告）<br>
　　--coarsek：粗量化得到的中心点数<br>
　　--w：搜索过程中粗量化中心点的遍历个数<br>

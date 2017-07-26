#include "mex.h"
#include "flann\flann.hpp"
using namespace flann;

// 入口函数
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[] ) {
    
   	if ( nrhs != 5  ) {
        mexErrMsgTxt( "输入参数不合法……" );
    }

	if( nlhs != 2){
		mexErrMsgTxt("输出必须是两个矩阵");
	}
    
    double *dataset_d = mxGetPr(prhs[0]);
 	double *query_d = mxGetPr(prhs[1]);

	//for(int i=0;i<6;i++)
		//mexPrintf("%f\n",dataset_d[i]);
	int data_colums = mxGetM(prhs[0]);
	int data_rows = mxGetN(prhs[0]);
	int query_colums = mxGetM(prhs[1]);
	int query_rows = mxGetN(prhs[1]);
	int nn = (int)mxGetScalar(prhs[2]);

	//mexPrintf("data_colums=%d; data_rows=%d\n", data_colums, data_rows);
	//mexPrintf("query_colums=%d; query_rows=%d\n", query_colums, query_rows);
	
	/*
	 * The number of parallel kd-trees to use. Good values are in the range [1..16]
	 */
	int tree = (int)mxGetScalar(prhs[3]);

	/* 
	 * specifies the maximum leafs to visit when searching for neighbours.
	 * A higher value for this parameter would give better search precision, but also take more time.
	 */
	int check = (int)mxGetScalar(prhs[4]);

	clock_t start_time, end_time;
	double index_time, search_time;

	//mexPrintf("%d %d %d %d %d\n",data_rows,data_colums,query_rows,query_colums,nn);
	flann::Matrix<double> points = flann::Matrix<double>(dataset_d, data_rows, data_colums);
	flann::Matrix<double> query = flann::Matrix<double>(query_d, query_rows, query_colums);

	flann::Matrix<double> dists(new double[query.rows*nn], query.rows, nn);
	flann::Matrix<int> indices(new int[query.rows*nn], query.rows, nn);

	flann::Index<flann::L2<double> > index(points, flann::KDTreeIndexParams(tree));
	start_time = clock();
	index.buildIndex();
	end_time = clock();
	index_time = (double)(end_time - start_time) / CLOCKS_PER_SEC;
	start_time = clock();
	index.knnSearch(query, indices, dists, nn, flann::SearchParams(check));
	end_time = clock();
	search_time = (double)(end_time - start_time) / CLOCKS_PER_SEC;

	mexPrintf("index time is %lfs, search time is %lfs\n", index_time, search_time);

	plhs[1] = mxCreateDoubleMatrix(nn,query_rows,mxREAL);
	plhs[0] = mxCreateNumericMatrix(nn,query_rows,mxINT32_CLASS,mxREAL);
	memcpy(mxGetPr(plhs[1]),dists.ptr(),mxGetNumberOfElements(plhs[1])*sizeof(double));
	memcpy(mxGetPr(plhs[0]),indices.ptr(),mxGetNumberOfElements(plhs[0])*sizeof(int));
	delete[] dists.ptr();
	delete[] indices.ptr();
}


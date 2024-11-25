#include "mex.h"
#include "matrix.h"
#include "mat.h" // For MAT-file handling

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    if (nrhs != 0) {
        mexErrMsgIdAndTxt("MATLAB:loading:invalidNumInputs", "No inputs required.");
    }

    // Define MAT file name (hardcoded)
    const char *filename = "UFData_Agarose_dataset_1.mat";
    
    // Open the MAT file
    MATFile *pmat = matOpen(filename, "r");
    if (pmat == NULL) {
        mexErrMsgIdAndTxt("MATLAB:loading:fileOpenFailed", "Cannot open MAT file.");
    }

    // Read the correct variable (in this case, 'RData')
    mxArray *data = matGetVariable(pmat, "RData");
    if (data == NULL) {
        matClose(pmat);
        mexErrMsgIdAndTxt("MATLAB:loading:varReadFailed", "Variable 'RData' not found in MAT file.");
    }

    // Return the variable to MATLAB
    plhs[0] = data;

    // Clean up
    matClose(pmat);
}

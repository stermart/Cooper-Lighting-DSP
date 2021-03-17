//
//  Academic License - for use in teaching, academic research, and meeting
//  course requirements at degree granting institutions only.  Not for
//  government, commercial, or other organizational use.
//
//  MaskGenerate_initialize.cpp
//
//  Code generation for function 'MaskGenerate_initialize'
//


// Include files
#include "MaskGenerate_initialize.h"
#include "MaskGenerate_data.h"
#include "_coder_MaskGenerate_mex.h"
#include "rt_nonfinite.h"

// Function Definitions
void MaskGenerate_initialize()
{
  emlrtStack st = { NULL,              // site
    NULL,                              // tls
    NULL                               // prev
  };

  mex_InitInfAndNan();
  mexFunctionCreateRootTLS();
  emlrtBreakCheckR2012bFlagVar = emlrtGetBreakCheckFlagAddressR2012b();
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 0U, 0);
  emlrtEnterRtStackR2012b(&st);
  emlrtFirstTimeR2012b(emlrtRootTLSGlobal);
}

// End of code generation (MaskGenerate_initialize.cpp)

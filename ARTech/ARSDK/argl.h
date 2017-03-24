//
//  argl.h
//  ARTech
//
//  Created by wangyang on 2017/3/23.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#ifndef argl_h
#define argl_h

#include <AR/ar.h>
#include <EZGL.h>

static void arglCameraViewRHf(float para[3][4], GLfloat m_modelview[16], const float scale);
static void arglCameraFrustumRHf(const ARParam *cparam, const float focalmin, const float focalmax, GLfloat m_projection[16]);

static void arglCameraViewRHf(float para[3][4], GLfloat m_modelview[16], const float scale)
{
    m_modelview[0 + 0*4] = para[0][0]; // R1C1
    m_modelview[0 + 1*4] = para[0][1]; // R1C2
    m_modelview[0 + 2*4] = para[0][2];
    m_modelview[0 + 3*4] = para[0][3];
    m_modelview[1 + 0*4] = -para[1][0]; // R2
    m_modelview[1 + 1*4] = -para[1][1];
    m_modelview[1 + 2*4] = -para[1][2];
    m_modelview[1 + 3*4] = -para[1][3];
    m_modelview[2 + 0*4] = -para[2][0]; // R3
    m_modelview[2 + 1*4] = -para[2][1];
    m_modelview[2 + 2*4] = -para[2][2];
    m_modelview[2 + 3*4] = -para[2][3];
    m_modelview[3 + 0*4] = 0.0f;
    m_modelview[3 + 1*4] = 0.0f;
    m_modelview[3 + 2*4] = 0.0f;
    m_modelview[3 + 3*4] = 1.0f;
    if (scale != 0.0f) {
        m_modelview[12] *= scale;
        m_modelview[13] *= scale;
        m_modelview[14] *= scale;
    }
}

static void arglCameraFrustumRHf(const ARParam *cparam, const float focalmin, const float focalmax, GLfloat m_projection[16])
{
    float   icpara[3][4];
    float   trans[3][4];
    float   p[3][3], q[4][4];
    float   widthm1, heightm1;
    int     i, j;
    
    widthm1  = (float)(cparam->xsize - 1);
    heightm1 = (float)(cparam->ysize - 1);
    
    if (arParamDecompMatf(cparam->mat, icpara, trans) < 0) {
        printf("arglCameraFrustum(): arParamDecompMat() indicated parameter error.\n"); // Windows bug: when running multi-threaded, can't write to stderr!
        return;
    }
    for (i = 0; i < 4; i++) {
        icpara[1][i] = heightm1*(icpara[2][i]) - icpara[1][i];
    }
    
    for(i = 0; i < 3; i++) {
        for(j = 0; j < 3; j++) {
            p[i][j] = icpara[i][j] / icpara[2][2];
        }
    }
    q[0][0] = (2.0f * p[0][0] / widthm1);
    q[0][1] = (2.0f * p[0][1] / widthm1);
    q[0][2] = -((2.0f * p[0][2] / widthm1)  - 1.0f);
    q[0][3] = 0.0f;
    
    q[1][0] = 0.0f;
    q[1][1] = -(2.0f * p[1][1] / heightm1);
    q[1][2] = -((2.0f * p[1][2] / heightm1) - 1.0f);
    q[1][3] = 0.0f;
    
    q[2][0] = 0.0f;
    q[2][1] = 0.0f;
    q[2][2] = (focalmax + focalmin)/(focalmin - focalmax);
    q[2][3] = 2.0f * focalmax * focalmin / (focalmin - focalmax);
    
    q[3][0] = 0.0f;
    q[3][1] = 0.0f;
    q[3][2] = -1.0f;
    q[3][3] = 0.0f;
    
    for (i = 0; i < 4; i++) { // Row.
        // First 3 columns of the current row.
        for (j = 0; j < 3; j++) { // Column.
            m_projection[i + j*4] = q[i][0] * trans[0][j] +
            q[i][1] * trans[1][j] +
            q[i][2] * trans[2][j];
        }
        // Fourth column of the current row.
        m_projection[i + 3*4] = q[i][0] * trans[0][3] +
        q[i][1] * trans[1][3] +
        q[i][2] * trans[2][3] +
        q[i][3];
    }
}

#endif /* argl_h */

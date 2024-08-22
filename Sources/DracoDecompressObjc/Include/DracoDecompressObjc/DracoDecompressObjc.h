#ifndef DracoDecompressObjc_h
#define DracoDecompressObjc_h

#include <stdbool.h>

#if __cplusplus
extern "C" {
#endif

bool decompressDracoBuffer(const char* buffer, unsigned long bufferLength, float** positionsOut, unsigned long* positionsLength, unsigned int** indicesOut, unsigned long *indicesLength);

#if __cplusplus
}
#endif

#endif /* DracoDecompressObjc_h */


#ifndef DracoDecompressObjc_h
#define DracoDecompressObjc_h

#include <stdbool.h>

#if __cplusplus
extern "C" {
#endif

bool decompressDracoBuffer
(
 const char* buffer,
 unsigned long bufferLength,
 float** positionsOut,
 unsigned long* positionsLength,
 unsigned int** indicesOut,
 unsigned long* indicesLength,
 float** normalsOut,
 unsigned long* normalsLength,
 float** colorsOut,
 unsigned long* colorsLength,
 float** textureCoordinatesOut,
 unsigned long* textureCoordinatesLength,
 float** weightsOut,
 unsigned long* weightsLength,
 unsigned int** jointsOut,
 unsigned long* jointsLength
);

#if __cplusplus
}
#endif

#endif /* DracoDecompressObjc_h */


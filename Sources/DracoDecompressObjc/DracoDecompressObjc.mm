#import <Foundation/Foundation.h>
#import "Include/DracoDecompressObjc/DracoDecompressObjc.h"

#if __has_include("draco/compression/decode.h")

#include "draco/compression/decode.h"
#include "draco/core/decoder_buffer.h"
#include "draco/mesh/mesh.h"

bool decompressDracoBuffer(const char* buffer, unsigned long bufferLength, float** verticesOut, unsigned long* vertLength, unsigned int** indicesOut, unsigned long *indLength) {
    draco::Decoder decoder;
    draco::DecoderBuffer decoderBuffer;
    decoderBuffer.Init(buffer, bufferLength);

    auto status_or_geometry = decoder.DecodeMeshFromBuffer(&decoderBuffer);
    if (!status_or_geometry.ok()) {
        return false; // Decoding failed
    }

    std::unique_ptr<draco::Mesh> mesh = std::move(status_or_geometry).value();
    *indLength = mesh->num_faces() * 3; // assuming triangles

    // Allocate memory for indices
    *indicesOut = new unsigned int[*indLength];
    if (*indicesOut == nullptr) {
        return false; // Memory allocation failed
    }

    // Extract indices
    for (draco::FaceIndex i(0); i < mesh->num_faces(); ++i) {
        const draco::Mesh::Face& face = mesh->face(i);
        for (int j = 0; j < 3; ++j) {
            (*indicesOut)[i.value() * 3 + j] = face[j].value();
        }
    }

    *vertLength = mesh->num_points() * 3;

    // Allocate memory for vertices
    *verticesOut = new float[*vertLength];
    if (*verticesOut == nullptr) {
        return false; // Memory allocation failed
    }

    const draco::PointAttribute* positionAttribute = mesh->GetNamedAttribute(draco::GeometryAttribute::POSITION);
    for (draco::PointIndex i(0); i < mesh->num_points(); ++i) {
        const draco::AttributeValueIndex val_index = positionAttribute->mapped_index(i);
        positionAttribute->ConvertValue<float, 3>(val_index, &(*verticesOut)[i.value() * 3]);
    }

    return true;
}

#endif


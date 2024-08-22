#import <Foundation/Foundation.h>
#import "Include/DracoDecompressObjc/DracoDecompressObjc.h"

#if __has_include("draco/compression/decode.h")

#import <draco/compression/decode.h>
#import <draco/core/decoder_buffer.h>
#import <draco/mesh/mesh.h>

bool decompressDracoBuffer(
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
                           ) {
  draco::Decoder decoder;
  draco::DecoderBuffer decoderBuffer;
  decoderBuffer.Init(buffer, bufferLength);

  auto status_or_geometry = decoder.DecodeMeshFromBuffer(&decoderBuffer);
  if (!status_or_geometry.ok()) {
    return false; // Decoding failed
  }

  std::unique_ptr<draco::Mesh> mesh = std::move(status_or_geometry).value();
  *indicesLength = mesh->num_faces() * 3; // assuming triangles

  // Allocate memory for indices
  *indicesOut = new unsigned int[*indicesLength];
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

  *positionsLength = mesh->num_points() * 3;

  // Allocate memory for vertices
  *positionsOut = new float[*positionsLength];
  if (*positionsOut == nullptr) {
    return false; // Memory allocation failed
  }

  const draco::PointAttribute* positionAttribute = mesh->GetNamedAttribute(draco::GeometryAttribute::POSITION);
  for (draco::PointIndex i(0); i < mesh->num_points(); ++i) {
    const draco::AttributeValueIndex val_index = positionAttribute->mapped_index(i);
    positionAttribute->ConvertValue<float, 3>(val_index, &(*positionsOut)[i.value() * 3]);
  }

  // Extract normals
  if (normalsOut != nullptr && mesh->GetNamedAttribute(draco::GeometryAttribute::NORMAL) != nullptr) {
    const draco::PointAttribute* normalAttribute = mesh->GetNamedAttribute(draco::GeometryAttribute::NORMAL);
    *normalsLength = mesh->num_points() * 3;
    *normalsOut = new float[*normalsLength];
    if (*normalsOut == nullptr) {
      return false; // Memory allocation failed
    }
    for (draco::PointIndex i(0); i < mesh->num_points(); ++i) {
      const draco::AttributeValueIndex val_index = normalAttribute->mapped_index(i);
      normalAttribute->ConvertValue<float, 3>(val_index, &(*normalsOut)[i.value() * 3]);
    }
  }

  // Extract colors
  if (colorsOut != nullptr && mesh->GetNamedAttribute(draco::GeometryAttribute::COLOR) != nullptr) {
    const draco::PointAttribute* colorAttribute = mesh->GetNamedAttribute(draco::GeometryAttribute::COLOR);
    *colorsLength = mesh->num_points() * 3;
    *colorsOut = new float[*colorsLength];
    if (*colorsOut == nullptr) {
      return false; // Memory allocation failed
    }
    for (draco::PointIndex i(0); i < mesh->num_points(); ++i) {
      const draco::AttributeValueIndex val_index = colorAttribute->mapped_index(i);
      colorAttribute->ConvertValue<float, 3>(val_index, &(*colorsOut)[i.value() * 3]);
    }
  }

  // Extract texture coordinates
  if (textureCoordinatesOut != nullptr && mesh->GetNamedAttribute(draco::GeometryAttribute::TEX_COORD) != nullptr) {
    const draco::PointAttribute* texCoordAttribute = mesh->GetNamedAttribute(draco::GeometryAttribute::TEX_COORD);
    *textureCoordinatesLength = mesh->num_points() * 2; // assuming 2D texture coordinates
    *textureCoordinatesOut = new float[*textureCoordinatesLength];
    if (*textureCoordinatesOut == nullptr) {
      return false; // Memory allocation failed
    }
    for (draco::PointIndex i(0); i < mesh->num_points(); ++i) {
      const draco::AttributeValueIndex val_index = texCoordAttribute->mapped_index(i);
      texCoordAttribute->ConvertValue<float, 2>(val_index, &(*textureCoordinatesOut)[i.value() * 2]);
    }
  }

  // Extract weights
  if (weightsOut != nullptr && mesh->GetNamedAttribute(draco::GeometryAttribute::GENERIC) != nullptr) {
    const draco::PointAttribute* weightAttribute = mesh->GetNamedAttribute(draco::GeometryAttribute::GENERIC);
    *weightsLength = mesh->num_points() * weightAttribute->num_components();
    *weightsOut = new float[*weightsLength];
    if (*weightsOut == nullptr) {
      return false; // Memory allocation failed
    }
    for (draco::PointIndex i(0); i < mesh->num_points(); ++i) {
      const draco::AttributeValueIndex val_index = weightAttribute->mapped_index(i);
      weightAttribute->ConvertValue<float>(val_index, &(*weightsOut)[i.value() * weightAttribute->num_components()]);
    }
  }

  // Extract joints
  if (jointsOut != nullptr && mesh->GetNamedAttribute(draco::GeometryAttribute::GENERIC) != nullptr) {
    const draco::PointAttribute* jointAttribute = mesh->GetNamedAttribute(draco::GeometryAttribute::GENERIC);
    *jointsLength = mesh->num_points() * jointAttribute->num_components();
    *jointsOut = new unsigned int[*jointsLength];
    if (*jointsOut == nullptr) {
      return false; // Memory allocation failed
    }
    for (draco::PointIndex i(0); i < mesh->num_points(); ++i) {
      const draco::AttributeValueIndex val_index = jointAttribute->mapped_index(i);
      jointAttribute->ConvertValue<unsigned int>(val_index, &(*jointsOut)[i.value() * jointAttribute->num_components()]);
    }
  }

  return true;
}

#endif


import Foundation
import DracoDecompressObjc

public struct DracoDecodingResult {
  public let indices: Data
  public let positions: Data
  public let normals: Data?
  public let colors: Data?
  public let textureCoordinates: Data?
  public let weights: Data?
}

public enum DracoDecodingError: Error {
  case failure
}

struct DracoCollection<T> {
  var decodedElements: UnsafeMutablePointer<T>? = nil
  var count: Int = 0

  func data() -> Data? {
    guard let decodedElements else {
      return nil
    }

    return Data(bytes: decodedElements, count: count * MemoryLayout<T>.size)
  }

  var elementSize: Int {
    MemoryLayout<T>.size
  }
}

// TODO: Can we assume data type is Int8?
public func decompressDracoBuffer(_ data: Data) throws -> DracoDecodingResult {
  var stride: Int = 0
  
  var indicesData: Data!
  var positionsData: Data!
  var normalsData: Data? = nil
  var colorsData: Data? = nil
  var textureCoordsData: Data? = nil
  var weightsData: Data? = nil

  let success = data.withUnsafeBytes { rawBufferPointer -> Bool in
    guard let pointer = rawBufferPointer.bindMemory(to: Int8.self).baseAddress else {
      return false
    }

    var positions: DracoCollection<Float> = .init()
    var indices: DracoCollection<UInt32> = .init()

//    var normals: DracoCollection<Float> = .init()
//    var colors: DracoCollection<Float> = .init()
//    var textureCoordinates: DracoCollection<Float> = .init()
//
//    // TODO: Support weights

    let decodeSuccess = DracoDecompressObjc.decompressDracoBuffer(
      pointer,
      UInt(data.count),
      &positions.decodedElements,
      &positions.count,
      &indices.decodedElements,
      &indices.count
    )


    guard let _positionsData = positions.data(), let _indicesData = indices.data() else {
      return false
    }

    positionsData = _positionsData
    indicesData = _indicesData

    guard decodeSuccess else {
      return false
    }

    return true
  }

  guard success else {
    throw DracoDecodingError.failure
  }

  return DracoDecodingResult(
    indices: indicesData,
    positions: positionsData,
    normals: normalsData,
    colors: colorsData,
    textureCoordinates: textureCoordsData,
    weights: weightsData
  )
}

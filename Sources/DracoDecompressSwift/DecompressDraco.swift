import Foundation
import DracoDecompressObjc

public struct DracoDecodingResult {
  public let indices: Data
  public let positions: Data
  public let normals: Data?
  public let colors: Data?
  public let textureCoordinates: Data?
  public let weights: Data?
  public let joints: Data?
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

    return Data(bytes: decodedElements, count: count * MemoryLayout<T>.stride)
  }

  var elementSize: Int {
    MemoryLayout<T>.stride
  }
}

// TODO: Can we assume data type is Int8?
public func decompressDracoBuffer(_ data: Data) throws -> DracoDecodingResult {
  var indicesData: Data!
  var positionsData: Data!
  var normalsData: Data?
  var colorsData: Data?
  var textureCoordinatesData: Data?
  var weightsData: Data?
  var jointsData: Data?

  let success = data.withUnsafeBytes { rawBufferPointer -> Bool in
    guard let pointer = rawBufferPointer.bindMemory(to: Int8.self).baseAddress else {
      return false
    }

    var positions: DracoCollection<Float> = .init()
    var indices: DracoCollection<UInt32> = .init()

    var normals: DracoCollection<Float> = .init()
    var colors: DracoCollection<Float> = .init()
    var textureCoordinates: DracoCollection<Float> = .init()
    var weights: DracoCollection<Float> = .init()
    var joints: DracoCollection<UInt32> = .init()

    let decodeSuccess = DracoDecompressObjc.decompressDracoBuffer(
      pointer,
      UInt(data.count),
      &positions.decodedElements,
      &positions.count,
      &indices.decodedElements,
      &indices.count,
      &normals.decodedElements,
      &normals.count,
      &colors.decodedElements,
      &colors.count,
      &textureCoordinates.decodedElements,
      &textureCoordinates.count,
      &weights.decodedElements,
      &weights.count,
      &joints.decodedElements,
      &joints.count
    )

    guard let _positionsData = positions.data(), let _indicesData = indices.data() else {
      return false
    }

    positionsData = _positionsData
    indicesData = _indicesData

    normalsData = normals.data()
    colorsData = colors.data()
    textureCoordinatesData = textureCoordinates.data()
    weightsData = weights.data()
    jointsData = joints.data()

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
    textureCoordinates: textureCoordinatesData,
    weights: weightsData,
    joints: jointsData
  )
}

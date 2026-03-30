import simd

extension simd_float4x4 {
    /// Extract the translation component from a 4x4 transform matrix
    var translation: SIMD3<Float> {
        SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
    }

    /// Create a translation matrix
    static func translation(_ t: SIMD3<Float>) -> simd_float4x4 {
        var matrix = matrix_identity_float4x4
        matrix.columns.3 = SIMD4<Float>(t.x, t.y, t.z, 1.0)
        return matrix
    }
}

//
//  PointCloud.swift
//  snowPCL
//
//  Created by pi on 2021/12/31.
//

import Foundation
import SceneKit

internal struct PointCloud {
    internal var points: [vector_float3] = []
    internal var framePointsSizes: [Int32] = []
    internal var frameViewpoints: [SCNVector3] = []
}

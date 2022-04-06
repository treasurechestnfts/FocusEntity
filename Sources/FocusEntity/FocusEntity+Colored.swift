//
//  FocusEntity+Colored.swift
//  FocusEntity
//
//  Created by Max Cobb on 8/26/19.
//  Copyright © 2019 Max Cobb. All rights reserved.
//

#if canImport(ARKit) && !targetEnvironment(simulator)
import RealityKit
import UIKit

/// An extension of FocusEntity holding the methods for the "colored" style.
public extension FocusEntity {
    internal func entityStateChanged() {
        guard self.focus.entityStyle != nil else {
            return
        }
        if self.state == .initializing ||
            !self.onPlane {
            self.fillPlane?.isEnabled = false
            if let offPlaneLabel = self.offPlaneLabel,
               let arView = self.arView {
                arView.addSubview(offPlaneLabel)
                NSLayoutConstraint.activate([
                    offPlaneLabel.centerXAnchor.constraint(equalTo: arView.centerXAnchor),
                    offPlaneLabel.centerYAnchor.constraint(equalTo: arView.centerYAnchor),
                ])
            }
            self.onPlaneLabel?.removeFromSuperview()
        } else {
            self.fillPlane?.isEnabled = true
            if let onPlaneLabel = self.onPlaneLabel,
               let arView = self.arView {
                arView.addSubview(onPlaneLabel)
                NSLayoutConstraint.activate([
                    onPlaneLabel.centerXAnchor.constraint(equalTo: arView.centerXAnchor),
                    onPlaneLabel.centerYAnchor.constraint(equalTo: arView.topAnchor, constant: 250),
                ])
            }
            self.offPlaneLabel?.removeFromSuperview()
        }
    }
    
    internal func coloredStateChanged() {
        guard let coloredStyle = self.focus.coloredStyle else {
            return
        }
        var endColor: MaterialColorParameter
        if self.state == .initializing {
            endColor = coloredStyle.nonTrackingColor
        } else {
            endColor = self.onPlane ? coloredStyle.onColor : coloredStyle.offColor
        }
        if let hasModel = self.fillPlane as? HasModel,
           hasModel.model?.materials.count == 0 {
            hasModel.model?.materials = [SimpleMaterial()]
        }
        var modelMaterial = UnlitMaterial(color: .clear)
        if #available(iOS 15, *) {
            switch endColor {
            case .color(let uikitColour):
                modelMaterial.color = .init(tint: uikitColour, texture: nil)
            case .texture(let tex):
                modelMaterial.color = .init(tint: .white, texture: .init(tex))
            @unknown default: break
            }
        } else {
            modelMaterial.baseColor = endColor
            // Necessary for transparency.
            modelMaterial.tintColor = Material.Color.white.withAlphaComponent(0.995)
        }
        if let hasModel = self.fillPlane as? HasModel {
            hasModel.model?.materials[0] = modelMaterial
        }
    }
}
#endif

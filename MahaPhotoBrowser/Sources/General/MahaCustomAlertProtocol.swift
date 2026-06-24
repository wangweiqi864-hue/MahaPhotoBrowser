//
//  MahaCustomAlertProtocol.swift
//  MahaPhotoBrowser
//
//  Created by long on 2022/6/29.
//

import UIKit

public enum MahaCustomAlertStyle {
    case alert
    case actionSheet
}

public protocol MahaCustomAlertProtocol: AnyObject {
    /// Should return an instance of MahaCustomAlertProtocol
    static func alert(title: String?, message: String, style: MahaCustomAlertStyle) -> MahaCustomAlertProtocol
    
    func addAction(_ action: MahaCustomAlertAction)
    
    func show(with parentVC: UIViewController?)
}

public class MahaCustomAlertAction: NSObject {
    public enum Style {
        case `default`
        case tint
        case cancel
        case destructive
    }
    
    public let title: String
    
    public let style: MahaCustomAlertAction.Style
    
    public let handler: ((MahaCustomAlertAction) -> Void)?
    
    deinit {
        mahaDebugPrint("MahaCustomAlertAction deinit")
    }
    
    public init(title: String, style: MahaCustomAlertAction.Style, handler: ((MahaCustomAlertAction) -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
        super.init()
    }
}

/// internal
extension MahaCustomAlertStyle {
    var systemAlertStyle: UIAlertController.Style {
        switch self {
        case .alert:
            return .alert
        case .actionSheet:
            return .actionSheet
        }
    }
}

/// internal
extension MahaCustomAlertAction.Style {
    var systemAlertActionStyle: UIAlertAction.Style {
        switch self {
        case .default, .tint:
            return .default
        case .cancel:
            return .cancel
        case .destructive:
            return .destructive
        }
    }
}

/// internal
extension MahaCustomAlertAction {
    func makeSystemAlertAction() -> UIAlertAction {
        return UIAlertAction(title: title, style: style.systemAlertActionStyle) { _ in
            self.handler?(self)
        }
    }
}

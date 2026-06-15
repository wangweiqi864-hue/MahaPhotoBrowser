//
//  MahaEditorManager.swift
//  MahaPhotoBrowser
//
//  Created by long on 2025/9/25.
//
//  Copyright (c) 2020 Long Zhang <495181165@qq.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

public enum MahaEditorAction {
    case draw(MahaDrawPath)
    case eraser([MahaDrawPath])
    case clip(oldStatus: MahaClipStatus, newStatus: MahaClipStatus)
    case sticker(oldState: MahaBaseStickertState?, newState: MahaBaseStickertState?)
    case mosaic(MahaMosaicPath)
    case filter(oldFilter: MahaFilter?, newFilter: MahaFilter?)
    case adjust(oldStatus: MahaAdjustStatus, newStatus: MahaAdjustStatus)
}

protocol MahaEditorManagerDelegate: AnyObject {
    func editorManager(_ manager: MahaEditorManager, didUpdateActions actions: [MahaEditorAction], redoActions: [MahaEditorAction])
    
    func editorManager(_ manager: MahaEditorManager, undoAction action: MahaEditorAction)
    
    func editorManager(_ manager: MahaEditorManager, redoAction action: MahaEditorAction)
}

class MahaEditorManager {
    private(set) var actions: [MahaEditorAction] = []
    private(set) var redoActions: [MahaEditorAction] = []
    
    weak var delegate: MahaEditorManagerDelegate?
    
    init(actions: [MahaEditorAction] = []) {
        self.actions = actions
        redoActions = actions
    }
    
    func storeAction(_ action: MahaEditorAction) {
        actions.append(action)
        redoActions = actions
        
        deliverUpdate()
    }
    
    func undoAction() {
        guard let preAction = actions.popLast() else { return }
        
        delegate?.editorManager(self, undoAction: preAction)
        deliverUpdate()
    }
    
    func redoAction() {
        guard actions.count < redoActions.count else { return }
        
        let action = redoActions[actions.count]
        actions.append(action)
        
        delegate?.editorManager(self, redoAction: action)
        deliverUpdate()
    }
    
    private func deliverUpdate() {
        delegate?.editorManager(self, didUpdateActions: actions, redoActions: redoActions)
    }
}

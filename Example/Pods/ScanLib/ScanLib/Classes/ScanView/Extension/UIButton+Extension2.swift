//
//  UIButton+Extension.swift
//  SeaKitchen
//
//

import UIKit
import RxSwift
import RxCocoa

extension UIButton {
    //只有文字
    convenience init(onlyTitle: String, titleColor: UIColor, font: UIFont,
                     alignmentH: ContentHorizontalAlignment? = .center, alignmentV: ContentVerticalAlignment? = .center,
                     backgroundColor: UIColor? = .clear){
        self.init(frame: .zero)
        self.setTitle(onlyTitle, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = font
        self.contentHorizontalAlignment = alignmentH ?? .center
        self.contentVerticalAlignment = alignmentV ?? .center
        self.backgroundColor = backgroundColor
        self.titleLabel?.lineBreakMode = .byClipping
        
    }
    
    //只有图片
    convenience init(onlyImage: UIImage?, alignmentH: ContentHorizontalAlignment? = .left, alignmentV: ContentVerticalAlignment? = .center, backgroundColor: UIColor? = .clear) {
        self.init(frame: .zero)
        self.setImage(onlyImage, for: .normal)
        self.contentHorizontalAlignment = alignmentH ?? .left
        self.contentVerticalAlignment = alignmentV ?? .center
        self.backgroundColor = backgroundColor
    }
    
    //图文都有
    convenience init(title: String, titleColor: UIColor, font: UIFont, image: UIImage?, alignmentH: ContentHorizontalAlignment? = .left, alignmentV: ContentVerticalAlignment? = .center, backgroundColor: UIColor? = .clear) {
        self.init(frame: .zero)
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = font
        self.setImage(image, for: .normal)
        self.contentHorizontalAlignment = alignmentH ?? .left
        self.contentVerticalAlignment = alignmentV ?? .center
        self.backgroundColor = backgroundColor
        self.titleLabel?.lineBreakMode = .byClipping //系统辅助功能，粗体文本之后字体计算宽度错误，这个属性解决这个问题
       
    }
    
}

//MARK: Rx扩展是否可用的属性
extension Reactive where Base: UIButton {
    public var normalText: ControlProperty<String?> {
        return base.rx.controlProperty(
            editingEvents: UIControl.Event.valueChanged,
            getter: { button in
                button.title(for: .normal)
            },
            setter: { button, value in
                button.setTitle(value, for: .normal)
            }
        )
    }
    
    public var isEnableDefault: Binder<Bool> {
        return Binder(base) { view, enable in
            view.isEnabled = enable
           // view.backgroundColor = enable ? MyColor.ThemeColor : MyColor.BlackAlpha10
        }
    }
}


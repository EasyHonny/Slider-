//
//  SliderView.swift
//  SliderView
//
//  Created by EasyHoony on 2016/10/12.
//  Copyright © 2016年 EasyHoony. All rights reserved.
//

import UIKit

public protocol SliderViewDelegate: NSObjectProtocol {
    
    func slider(sliderView: SliderView, didSelectItemAtIndex index: Int)
    
}

@IBDesignable public class SliderView: UIView {
    
    public weak var delegate: SliderViewDelegate?
    /// 选择项
    @IBInspectable public var titles               = ["Off", "3s", "10s", "30s"] {
        didSet {
            reloadData()
        }
    }
    /// 拖动的半径
    @IBInspectable public var thumbRadius: CGFloat = 8 {
        didSet {
            
        }
    }
    /// slider宽度
    @IBInspectable public var lineWidth: CGFloat   = 10 {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    /// 字体大小
    @IBInspectable public var fontSize: CGFloat    = 12 {
        didSet {
            _titleLayers.forEach { (textLayer) in
                textLayer.fontSize = fontSize
            }
        }
    }
    /// 选中文字颜色
    @IBInspectable public var selectedTextColor    = UIColor(red:0.40, green:0.60, blue:0.99, alpha:1.00) {
        didSet {
            for i in 0..<_titleLayers.count {
                let titleLayer = _titleLayers[i]
                if i == _selectedIndex {
                    titleLayer.foregroundColor = selectedTextColor.cgColor
                }
            }
        }
    }
    @IBInspectable public var selectedRoundColor   = UIColor.white {
        didSet {
            for i in 0..<_roundLayers.count {
                let roundLayer = _roundLayers[i]
                if i == _selectedIndex {
                    roundLayer.fillColor = selectedRoundColor.cgColor
                }
            }
        }
    }
    /// 正常文字颜色
    @IBInspectable public var normalTextColor      = UIColor.black {
        didSet {
            for i in 0..<_titleLayers.count {
                let titleLayer = _titleLayers[i]
                if i != _selectedIndex {
                    titleLayer.foregroundColor = normalTextColor.cgColor
                }
            }
        }
    }
    @IBInspectable public var normalRoundColor   = UIColor.black {
        didSet {
            for i in 0..<_roundLayers.count {
                let roundLayer = _roundLayers[i]
                if i != _selectedIndex {
                    roundLayer.fillColor = normalRoundColor.cgColor
                }
            }
        }
    }
    /// 背景色
    @IBInspectable public var progressBackgroundColor = UIColor(red:0.85, green:0.84, blue:0.85, alpha:1.00) {
        didSet {
            _backgroundLayer?.colors = [progressBackgroundColor.cgColor, progressBackgroundColor.cgColor]
        }
    }
    /// 进度颜色
    @IBInspectable public var progressColor   = UIColor(red:0.40, green:0.60, blue:0.99, alpha:1.00) {
        didSet {
            _progressLayer?.colors = [progressColor.cgColor, progressColor.cgColor]
        }
    }
    // 标记字
    private var _titleLayers = [CATextLayer]()
    // 点路径
    private var _roundLayers = [CAShapeLayer]()
    // 点
    private var _thumbLayer: CALayer!
    // 背景渐变色
    private var _backgroundLayer: CAGradientLayer!
    // 进度条渐变色
    private var _progressLayer: CAGradientLayer!
    // 背景
    private var _backgroundMaskLayer: CAShapeLayer!
    // 进度条
    private var _progressMaskLayer: CAShapeLayer!
    
    fileprivate var _selectedIndex = 0
    public var selectedIndex: Int {
        set {
            _selectedIndex = newValue
            reloadData()
        }
        get {
            return _selectedIndex
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _commitIn()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commitIn()
    }
    
    private func _commitIn() {
        isUserInteractionEnabled = true
        // 蒙板背景
        _backgroundMaskLayer               = CAShapeLayer()
        _backgroundMaskLayer.contentsScale = UIScreen.main.scale
        _backgroundMaskLayer.anchorPoint   = CGPoint(x: 0.5, y: 0.5)
        _backgroundMaskLayer.lineCap       = kCALineCapRound
        _backgroundMaskLayer.fillColor     = UIColor.clear.cgColor
        _backgroundMaskLayer.strokeColor   = UIColor(red:0.17, green:0.18, blue:0.21, alpha:1.00).cgColor
        // slider 背景宽度 10
        _backgroundMaskLayer.lineWidth = 10
        // 背景渐变色
        _backgroundLayer = CAGradientLayer()
        _backgroundLayer.mask = _backgroundMaskLayer
        _backgroundLayer.contentsScale = UIScreen.main.scale
        _backgroundLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        _backgroundLayer.locations = [0, 1]
        _backgroundLayer.startPoint = CGPoint(x: 0, y: 0)
        _backgroundLayer.endPoint = CGPoint(x: 1, y: 0)
        _backgroundLayer.colors = [progressBackgroundColor.cgColor, progressBackgroundColor.cgColor]
        layer.addSublayer(_backgroundLayer)
        
        // 进度条
        _progressMaskLayer               = CAShapeLayer()
        _progressMaskLayer.contentsScale = UIScreen.main.scale
        _progressMaskLayer.anchorPoint   = CGPoint(x: 0.5, y: 0.5)
        _progressMaskLayer.lineCap       = kCALineCapRound
        _progressMaskLayer.fillColor     = UIColor.clear.cgColor
        _progressMaskLayer.strokeColor   = UIColor(red:0.17, green:0.18, blue:0.21, alpha:1.00).cgColor
        _progressMaskLayer.lineWidth = 10
        _progressMaskLayer.strokeEnd = 0.5
        // 进度条渐变色
        _progressLayer      = CAGradientLayer()
        _progressLayer.mask = _progressMaskLayer
        _progressLayer.contentsScale = UIScreen.main.scale
        _progressLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        _progressLayer.locations = [0, 1]
        _progressLayer.colors = [progressColor.cgColor, progressColor.cgColor]
        layer.addSublayer(_progressLayer)
        // 拖动圆点
        _thumbLayer = CALayer()
        _thumbLayer.contentsScale = UIScreen.main.scale
        _thumbLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        // 拖动半径16
        _thumbLayer.bounds = CGRect(origin: .zero, size: CGSize(width: thumbRadius * 2, height: thumbRadius * 2))
        _thumbLayer.backgroundColor = progressColor.cgColor
        _thumbLayer.cornerRadius = thumbRadius
        layer.addSublayer(_thumbLayer)
        // 平移手势
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler(panGestureRecognizer:))))
       // 触摸手势
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizerHandler(tapGestureRecognizer:))))
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        reloadData()
    }
    
    func tapGestureRecognizerHandler(tapGestureRecognizer: UIPanGestureRecognizer) {
        let point = tapGestureRecognizer.location(in: self)
        switch tapGestureRecognizer.state {
        case .ended:
            touchEnd(point: point, isClick: true)
        default:
            break
        }
    }
    
    func panGestureRecognizerHandler(panGestureRecognizer: UIPanGestureRecognizer) {
        let point = panGestureRecognizer.location(in: self)
        let width = bounds.width / CGFloat(_titleLayers.count - 1)
        let positionX = point.x < 0 ? 0 : point.x > bounds.width ? bounds.width : point.x
        switch panGestureRecognizer.state {
        case .began, .changed:
            CATransaction.setDisableActions(true)
            _progressMaskLayer.strokeEnd = point.x / bounds.width
            _thumbLayer.position = CGPoint(x: positionX, y: _backgroundLayer.frame.midY)
            CATransaction.setDisableActions(false)
        case .cancelled:
            _progressMaskLayer.strokeEnd = width * CGFloat(_selectedIndex) / bounds.width
            _thumbLayer.position = CGPoint(x: positionX, y: _backgroundLayer.frame.midY)
        case .ended:
            touchEnd(point: point, isClick: true)
        default:
            break
        }
    }
    
    func touchEnd(point: CGPoint, isClick: Bool = false) {
        let width = bounds.width / CGFloat(_titleLayers.count - 1)
        
        for i in 0..<_titleLayers.count {
            let positionX = width * CGFloat(i)
            if abs(positionX - point.x) < width / 2 {
                _selectedIndex = i
                _progressMaskLayer.strokeEnd = positionX / bounds.width
                break
            }
        }
        _thumbLayer.position = CGPoint(x: width * CGFloat(selectedIndex), y: _backgroundLayer.frame.midY)
        _updateColor()
        if isClick {
            delegate?.slider(sliderView: self, didSelectItemAtIndex: selectedIndex)
        }
    }
    
    public override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        _updateMask()
        _backgroundLayer?.bounds = CGRect(x: 0, y: 0, width: bounds.width + lineWidth, height: lineWidth)
        _backgroundLayer?.position = CGPoint(x: bounds.width / 2, y: thumbRadius)
        
        _progressLayer?.bounds = CGRect(x: 0, y: 0, width: bounds.width + lineWidth, height: lineWidth)
        _progressLayer?.position = CGPoint(x: bounds.width / 2, y: thumbRadius)
        
        reloadData()
    }
    
    private func _updateMask() {
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: bounds.width, y: 0)
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        _backgroundMaskLayer?.path = path.cgPath
        _backgroundMaskLayer?.position = CGPoint(x: lineWidth / 2, y: lineWidth / 2)
        _progressMaskLayer?.path = path.cgPath
        _progressMaskLayer?.position = CGPoint(x: lineWidth / 2, y: lineWidth / 2)
    }
    
    public func reloadData() {
        // 清空
        if titles.count != _titleLayers.count {
            // 移除
            _titleLayers.forEach({ (layer) in
                layer.removeFromSuperlayer()
            })
            _roundLayers.forEach({ (layer) in
                layer.removeFromSuperlayer()
            })
            _titleLayers = []
            _roundLayers = []
            
            titles.forEach { (text) in
                let textLayer           = CATextLayer()
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.anchorPoint   = CGPoint(x: 0.5, y: 0.5)
                textLayer.fontSize      = fontSize
                textLayer.font          = UIFont.boldSystemFont(ofSize: fontSize).fontName as CFTypeRef?
                textLayer.alignmentMode = kCAAlignmentCenter
                textLayer.masksToBounds = false
                self.layer.addSublayer(textLayer)
                _titleLayers.append(textLayer)
                
                let roundLayer              = CAShapeLayer()
                roundLayer.contentsScale    = UIScreen.main.scale
                roundLayer.anchorPoint      = CGPoint(x: 0.5, y: 0.5)
                self.layer.insertSublayer(roundLayer, above: _thumbLayer!)
                _roundLayers.append(roundLayer)
            }
        }
        
        let width = bounds.width / CGFloat(_titleLayers.count - 1)
        for i in 0..<_titleLayers.count {
            let titleLayer = _titleLayers[i]
            let roundLayer = _roundLayers[i]
            
            titleLayer.string = titles[i]
            titleLayer.foregroundColor = i == selectedIndex ? selectedTextColor.cgColor : normalTextColor.cgColor
            roundLayer.backgroundColor = i == selectedIndex ? selectedRoundColor.cgColor : normalRoundColor.cgColor
            
            let roundWidth = _backgroundLayer.bounds.height - 2
            roundLayer.position = CGPoint(x: width * CGFloat(i), y: _backgroundLayer.frame.midY)
            roundLayer.bounds = CGRect(origin: .zero, size: CGSize(width: roundWidth, height: roundWidth))
            roundLayer.cornerRadius = roundLayer.bounds.height / 2
            
            titleLayer.position = CGPoint(x: width * CGFloat(i), y: _backgroundLayer.frame.maxY + 10 + fontSize / 2)
            titleLayer.bounds = CGRect(origin: .zero, size: CGSize(width: bounds.width, height: fontSize * 1.2))
        }
        _thumbLayer.position = CGPoint(x: width * CGFloat(selectedIndex), y: _backgroundLayer.frame.midY)
        
        touchEnd(point: CGPoint(x: bounds.width / CGFloat(_titleLayers.count - 1) * CGFloat(selectedIndex), y: _backgroundLayer.frame.midY))
    }
    
    private func _updateColor() {
        for i in 0..<_titleLayers.count {
            let titleLayer = _titleLayers[i]
            let roundLayer = _roundLayers[i]
            titleLayer.foregroundColor = i == selectedIndex ? selectedTextColor.cgColor : normalTextColor.cgColor
            roundLayer.backgroundColor = i < selectedIndex ? selectedRoundColor.cgColor : normalRoundColor.cgColor
        }
    }
    
}

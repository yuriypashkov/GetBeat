//
//  CustomActivityIndicator.swift
//  GetBeat
//
//  Created by Yuriy Pashkov on 1/22/21.
//

import UIKit

class CustomActivityIndicator: UIView {
    
    let circle1 = UIView()
    let circle2 = UIView()
    let circle3 = UIView()
    var circleArray: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        circleArray = [circle1, circle2, circle3]
        
        for circle in circleArray {
            circle.frame = CGRect(x: -20, y: 5, width: 20, height: 20)
            circle.layer.cornerRadius = 10
            circle.backgroundColor = .white
            circle.alpha = 0
            
            addSubview(circle)
        }
    }
    
    func animate() {
        var delay: Double = 0
        stopped = false
        for circle in circleArray {
            animateCircle(circle, delay: delay)
            delay += 0.95
        }
    }
    
    private var stopped = true
    
    private func animateCircle(_ circle: UIView, delay: Double) {
        UIView.animate(withDuration: 0.8, delay: delay, options: .curveLinear) {
            circle.alpha = 1
            circle.frame = CGRect(x: 35, y: 5, width: 20, height: 20)
        } completion: { completed in
            UIView.animate(withDuration: 1.3, delay: 0, options: .curveLinear) {
                circle.frame = CGRect(x: 85, y: 5, width: 20, height: 20)
            } completion: { (completed) in
                UIView.animate(withDuration: 0.8, delay: 0, options: .curveLinear) {
                    circle.alpha = 0
                    circle.frame = CGRect(x: 140, y: 5, width: 20, height: 20)
                } completion: { (completed) in
                    circle.frame = CGRect(x: -20, y: 5, width: 20, height: 20)
                    if self.stopped { return } else {
                        self.animateCircle(circle, delay: 0)
                    }
                }
            }
        }
    }
    
    func stopAnimate() {
        stopped = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

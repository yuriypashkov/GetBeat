//
//  WelcomeViewController.swift
//  GetBeat
//
//  Created by Yuriy Pashkov on 2/9/21.
//

import UIKit

enum TouchMethod {
    case tap
    case longTap
}

class WelcomeViewController: UIViewController {

    // MARK: - IB outlets
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var longTapView: UIView!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var playViewImageCell: UIImageView!
    @IBOutlet weak var longTapImageCell: UIImageView!
    @IBOutlet weak var playTapLabel: UILabel!
    @IBOutlet weak var longTapLabel: UILabel!
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
        drawSmallLine()
    }
    
    // Повесить какой-то RemoveFromSuperView() на ViewDisappear, иначе анимации повторно запускаются
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 2.0) {
            self.playViewImageCell.alpha = 1.0
            self.playTapLabel.alpha = 1.0
        } completion: { (result) in
            self.drawFingerTap(touchMethod: .tap, mainView: self.playView)
            UIView.animate(withDuration: 2.0, delay: 2.0) {
                self.longTapImageCell.alpha = 1.0
                self.longTapLabel.alpha = 1.0
            } completion: { (result) in
                self.drawFingerTap(touchMethod: .longTap, mainView: self.longTapView)
            }

        }

    }
    
    // MARK: - Other methods
    private func setupElements() {
        playView.layer.cornerRadius = 10
        longTapView.layer.cornerRadius = 10
        agreeButton.layer.cornerRadius = 5
        playViewImageCell.layer.cornerRadius = 10
        playViewImageCell.alpha = 0
        longTapImageCell.alpha = 0
        longTapImageCell.layer.cornerRadius = 10
        playTapLabel.text = "Обычный тап по треку запустит его воспроизведение, или же поставит его на паузу (если трек уже воспроизводится)."
        longTapLabel.text = "Длительное зажатие трека вызовет контекстное меню с дополнительной информацией о бите и списком возможных действий с ним."
        playTapLabel.alpha = 0
        longTapLabel.alpha = 0
    }
    
    private func drawSmallLine() {

        let path = UIBezierPath(roundedRect: CGRect(x: view.frame.size.width / 2 - 20, y: 16, width: 40, height: 4), cornerRadius: 3)
//        let path = UIBezierPath()
//        let x: CGFloat = view.frame.size.width / 2 - 20
//        let y: CGFloat = 16
//        path.move(to: CGPoint(x: x, y: y))
//        path.addLine(to: CGPoint(x: x + 40, y: y))

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.systemGray6.cgColor
        shapeLayer.fillColor = UIColor.systemGray6.cgColor
        shapeLayer.lineWidth = 1
        
        view.layer.addSublayer(shapeLayer)
    }
    
    private func drawFingerTap(touchMethod: TouchMethod, mainView: UIView) {
        let image = UIImageView(image: UIImage(named: "tapWhite3"))
        image.frame = CGRect(x: 100, y: 80, width: 32, height: 32)
        image.alpha = 0
        mainView.addSubview(image)
        image.layer.anchorPoint = CGPoint(x: 0, y: 0)
        UIView.animate(withDuration: 1.0) {
            image.frame.origin.x = 140
            image.frame.origin.y = 140
            image.alpha = 1
        } completion: { (result) in
            UIView.animate(withDuration: 0.5) {
                var rotationAndPerspectiveTransform = CATransform3DIdentity
                rotationAndPerspectiveTransform.m34 = 1.0 / 500
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 25.0 * .pi / 180.0, 1, 0, 0)
                image.layer.transform = rotationAndPerspectiveTransform
            } completion: { (result) in
                switch touchMethod {
                case .tap:
                    UIView.animate(withDuration: 0.5) {
                        image.transform = .identity
                    }
                    self.showPlayIcon()
                case .longTap:
                    //print("Long tap")
                    image.image = UIImage(named: "tapWhite2")
                    self.showMenuSheme()
                }
            }

        }
    }
    
    private func showPlayIcon() {
        let playImage = UIImageView(image: UIImage(systemName: "music.note"))
        playImage.frame = CGRect()
        playImage.tintColor = .white
        playImage.alpha = 1
        playImage.translatesAutoresizingMaskIntoConstraints = false
        playView.addSubview(playImage)
        let constraints = [
            playImage.leadingAnchor.constraint(equalTo: playViewImageCell.safeAreaLayoutGuide.leadingAnchor, constant: 18),
            playImage.bottomAnchor.constraint(equalTo: playViewImageCell.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            playImage.widthAnchor.constraint(equalToConstant: 24),
            playImage.heightAnchor.constraint(equalToConstant: 24)
        ]
        NSLayoutConstraint.activate(constraints)
        animateViewUp(someView: playImage)
    }
    
    private func animateViewUp(someView: UIView) {
        UIView.animate(withDuration: 1.5, delay: 0, options: .repeat) {// currentTime in
            someView.transform = CGAffineTransform(translationX: someView.frame.origin.x, y: someView.frame.origin.y - 40)
            someView.alpha = 0
        }
    }
    
    private func showMenuSheme() {
        let menuImage = UIImageView(image: UIImage(named: "menuScheme"))
        menuImage.frame = CGRect()
        menuImage.alpha = 0
        menuImage.layer.cornerRadius = 5
        menuImage.translatesAutoresizingMaskIntoConstraints = false
        longTapView.addSubview(menuImage)
        let constraints = [
            menuImage.leadingAnchor.constraint(equalTo: longTapImageCell.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            menuImage.bottomAnchor.constraint(equalTo: longTapImageCell.safeAreaLayoutGuide.bottomAnchor, constant: -4),
            menuImage.widthAnchor.constraint(equalToConstant: 112),
            menuImage.heightAnchor.constraint(equalToConstant: 80)
        ]
        NSLayoutConstraint.activate(constraints)
        UIView.animate(withDuration: 1.5) {
            menuImage.alpha = 0.9
        } completion: { (resule) in
            //self.blinkView(someView: menuImage)
        }

        
    }
    
    private func blinkView(someView: UIView) {
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse]) {
            someView.alpha = 1.0
        }
    }
    
    @IBAction func agreeButtonTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

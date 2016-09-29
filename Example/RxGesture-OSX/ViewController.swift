//
//  ViewController.swift
//  RxGesture-OSX
//
//  Created by Marin Todorov on 3/24/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Cocoa

import RxSwift
import RxCocoa
import RxGesture

class MacViewController: NSViewController {

    let infoList = [
        "Click the square",
        "Right click the square",
        "Click any button (left or right)",
        "Drag the square around",
        "Rotate the square with your trackpad, or click if you do not have a trackpad"
    ]
    
    let codeList = [
        "myView.rx_gesture(.Click).subscribeNext {...}",
        "myView.rx_gesture(.RightClick).subscribeNext {...}",
        "myView.rx_gesture(RxGestureTypeOptions.all()).subscribeNext {...}",
        "myView.rx_gesture(.Pan(.Changed), .Pan(.Ended)).subscribeNext {...}",
        "myView.rx_gesture(.Rotate(.Changed), .Rotate(.Ended), .Click).subscribeNext {...}"
    ]
    
    @IBOutlet weak var myView: NSView!
    @IBOutlet weak var myViewText: NSTextField!
    @IBOutlet weak var info: NSTextField!
    @IBOutlet weak var code: NSTextField!
    
    fileprivate let nextStep😁 = PublishSubject<Void>()
    fileprivate let bag = DisposeBag()
    fileprivate var stepBag = DisposeBag()

    override func viewWillAppear() {
        super.viewWillAppear()
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        
        myView.wantsLayer = true
        myView.layer?.backgroundColor = NSColor.red.cgColor
        myView.layer?.cornerRadius = 5
        
        nextStep😁.scan(0, accumulator: {acc, _ in
            return acc < 4 ? acc + 1 : 0
        })
        .startWith(0)
        .subscribeNext(step)
        .addDisposableTo(bag)
    }
    
    func step(_ step: Int) {
        //release previous recognizers
        stepBag = DisposeBag()
        
        info.stringValue = "\(step+1). \(infoList[step])"
        code.stringValue = codeList[step]
        
        //add current step recognizer
        switch step {
        case 0: //left click recognizer
            myView.rx_gesture(.Click).subscribeNext {[weak self] _ in
                guard let `self` = self else {return}
                
                self.myView.layer!.backgroundColor = NSColor.blueColor().CGColor
                
                let anim = CABasicAnimation(keyPath: "backgroundColor")
                anim.fromValue = NSColor.redColor().CGColor
                anim.toValue = NSColor.blueColor().CGColor
                self.myView.layer!.addAnimation(anim, forKey: nil)

                self.nextStep😁.onNext()
            }.addDisposableTo(stepBag)
            
        case 1: //right click recognizer
            myView.rx_gesture(.RightClick).subscribeNext {[weak self] _ in
                guard let `self` = self else {return}
                
                self.myView.layer!.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)

                let anim = CABasicAnimation(keyPath: "transform")
                anim.duration = 0.5
                anim.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
                anim.toValue = NSValue(CATransform3D: CATransform3DMakeScale(1.5, 1.5, 1.5))
                self.myView.layer!.addAnimation(anim, forKey: nil)
                
                self.nextStep😁.onNext()
            }.addDisposableTo(stepBag)
            
        case 2: //any button
            myView.rx_gesture(.Click, .RightClick).subscribeNext {[weak self] _ in
                guard let `self` = self else {return}
                
                self.myView.layer!.transform = CATransform3DIdentity
                self.myView.layer!.backgroundColor = NSColor.redColor().CGColor
                
                let anim = CABasicAnimation(keyPath: "transform")
                anim.duration = 0.5
                anim.fromValue = NSValue(CATransform3D: CATransform3DMakeScale(1.5, 1.5, 1.5))
                anim.toValue = NSValue(CATransform3D: CATransform3DIdentity)
                self.myView.layer!.addAnimation(anim, forKey: nil)
                
                self.nextStep😁.onNext()
            }.addDisposableTo(stepBag)
            
        case 3: //pan
            
            //
            // NB!: In this version of `RxGesture` under OSX you need to observe for .Changed and .Ended
            // on the same call to rx_gesture - once NSGestureRecognizer supports rx_event in RxCocoa
            // you can also observe them on separate calls - don't forget to switch on the recognizer `state`
            //
            
            myView.rx_gesture(.Pan(.Changed), .Pan(.Ended)).subscribeNext {[weak self] gesture in
                guard let `self` = self else {return}
                
                switch gesture {
                case .Pan(let data):
                    if let state = (data.recognizer as? NSGestureRecognizer)?.state {
                        switch state {
                        case .Changed:
                            self.myViewText.stringValue = String(format: "(%.f, %.f)", arguments: [data.translation.x, data.translation.y])
                            self.myView.layer!.transform = CATransform3DMakeTranslation(data.translation.x, data.translation.y, 0.0)
                        
                        case .Ended:
                            self.myViewText.stringValue = ""
                            
                            let anim = CABasicAnimation(keyPath: "transform")
                            anim.duration = 0.5
                            anim.fromValue = NSValue(CATransform3D: self.myView.layer!.transform)
                            anim.toValue = NSValue(CATransform3D: CATransform3DIdentity)
                            self.myView.layer!.addAnimation(anim, forKey: nil)
                            self.myView.layer!.transform = CATransform3DIdentity
                            
                            self.nextStep😁.onNext()
                        default: break
                        }
                    }
                default: break
                }
            }.addDisposableTo(stepBag)
            
        case 4: //rotate or click
            
            myView.rx_gesture(.Rotate(.Changed), .Rotate(.Ended), .Click).subscribeNext {[weak self] gesture in
                guard let `self` = self else {return}
                
                switch gesture {
                case .Rotate(let data):
                    if let state = (data.recognizer as? NSGestureRecognizer)?.state {
                        switch state {
                        case .Changed:
                            self.myViewText.stringValue = String(format: "angle: %.2f", data.rotation)
                            self.myView.layer!.transform = CATransform3DMakeRotation(data.rotation, 0, 0, 1)
                            
                        case .Ended:
                            self.myViewText.stringValue = ""
                            
                            let anim = CABasicAnimation(keyPath: "transform")
                            anim.duration = 0.5
                            anim.fromValue = NSValue(CATransform3D: self.myView.layer!.transform)
                            anim.toValue = NSValue(CATransform3D: CATransform3DIdentity)
                            self.myView.layer!.addAnimation(anim, forKey: nil)
                            self.myView.layer!.transform = CATransform3DIdentity
                            
                            self.nextStep😁.onNext()
                        default: break
                        }
                    }
                case .Click:
                    self.myViewText.stringValue = ""
                    
                    let anim = CABasicAnimation(keyPath: "transform")
                    anim.duration = 0.5
                    anim.fromValue = NSValue(CATransform3D: self.myView.layer!.transform)
                    anim.toValue = NSValue(CATransform3D: CATransform3DIdentity)
                    self.myView.layer!.addAnimation(anim, forKey: nil)
                    self.myView.layer!.transform = CATransform3DIdentity
                    
                    self.nextStep😁.onNext()
                default: break
                }
            }.addDisposableTo(stepBag)
            
        default: break
        }
        
        print("active gestures: \(myView.gestureRecognizers.count)")
    }

}


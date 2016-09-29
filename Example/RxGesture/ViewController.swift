//
//  ViewController.swift
//  RxGesture
//
//  Created by Marin Todorov on 03/22/2016.
//  Copyright (c) 2016 Marin Todorov. All rights reserved.
//

import UIKit

import RxSwift
import RxGesture

let infoList = [
    "Tap the red square",
    "Swipe the square down",
    "Swipe horizontally (e.g. left or right)",
    "Do a long press",
    "Drag the square to a different location",
    "Rotate the square",
    "Do either a tap, long press, or swipe in any direction"
]

let codeList = [
    "myView.rx_gesture(.Tap).subscribeNext {...}",
    "myView.rx_gesture(.SwipeDown).subscribeNext {...}",
    "myView.rx_gesture(.SwipeLeft, .SwipeRight).subscribeNext {",
    "myView.rx_gesture(.LongPress).subscribeNext {...}",
    "myView.rx_gesture(.Pan(.Changed), .Pan(.Ended)]).subscribeNext {...}",
    "myView.rx_gesture(.Rotate(.Changed), .Rotate(.Ended)]).subscribeNext {...}",
    "myView.rx_gesture().subscribeNext {...}"
]

class ViewController: UIViewController {

    @IBOutlet var myView: UIView!
    @IBOutlet var myViewText: UILabel!
    @IBOutlet var info: UILabel!
    @IBOutlet var code: UITextView!
    
    fileprivate let nextStep😁 = PublishSubject<Void>()
    fileprivate let bag = DisposeBag()
    fileprivate var stepBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nextStep😁.scan(0, accumulator: {acc, _ in
            return acc < 6 ? acc + 1 : 0
        })
        .startWith(0)
        .subscribeNext(step)
        .addDisposableTo(bag)
    }

    func step(_ step: Int) {
        //release previous recognizers
        stepBag = DisposeBag()
                
        info.text = "\(step+1). \(infoList[step])"
        code.text = codeList[step]
        
        //add current step recognizer
        switch step {
        case 0: //tap recognizer
            myView.rx_gesture(.tap).subscribeNext {[weak self] _ in
                guard let this = self else {return}
                UIView.animate(withDuration: 0.5, animations: {
                    this.myView.backgroundColor = UIColor.blue
                    this.nextStep😁.onNext()
                })
            }.addDisposableTo(stepBag)
            
        case 1: //swipe down
            myView.rx_gesture(.swipeDown).subscribeNext {[weak self] _ in
                guard let this = self else {return}
                UIView.animate(withDuration: 0.5, animations: {
                    this.myView.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
                    this.nextStep😁.onNext()
                })
            }.addDisposableTo(stepBag)
            
        case 2: //swipe horizontally
            myView.rx_gesture(.swipeLeft, .swipeRight).subscribeNext {[weak self] _ in
                guard let this = self else {return}
                UIView.animate(withDuration: 0.5, animations: {
                    this.myView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                    this.nextStep😁.onNext()
                })
            }.addDisposableTo(stepBag)

        case 3: //long press
            myView.rx_gesture(.longPress).subscribeNext {[weak self] _ in
                guard let this = self else {return}
                UIView.animate(withDuration: 0.5, animations: {
                    this.myView.transform = CGAffineTransform.identity
                    this.nextStep😁.onNext()
                })
            }.addDisposableTo(stepBag)

        case 4: //panning
            myView.rx_gesture(.pan(.Changed)).subscribeNext {[weak self] gesture in
                guard let this = self else {return}
                switch gesture {
                case .pan(let data):
                    this.myViewText.text = "(\(data.translation.x), \(data.translation.y))"
                    this.myView.transform = CGAffineTransform(translationX: data.translation.x, y: data.translation.y)
                default: break
                }
            }.addDisposableTo(stepBag)

            myView.rx_gesture(.pan(.Ended)).subscribeNext {[weak self] gesture in
                guard let this = self else {return}
                switch gesture {
                case .pan(_):
                    UIView.animate(withDuration: 0.5, animations: {
                        this.myViewText.text = nil
                        this.myView.transform = CGAffineTransform.identity
                        this.nextStep😁.onNext()
                    })
                default: break
                }
            }.addDisposableTo(stepBag)
            
        case 5: //rotating
            myView.rx_gesture(.rotate(.Changed)).subscribeNext {[weak self] gesture in
                guard let this = self else {return}
                switch gesture {
                case .rotate(let data):
                    this.myViewText.text = String(format: "angle: %.2f", data.rotation)
                    this.myView.transform = CGAffineTransform(rotationAngle: data.rotation)
                default: break
                }
            }.addDisposableTo(stepBag)
            
            myView.rx_gesture(.rotate(.Ended)).subscribeNext {[weak self] gesture in
                guard let this = self else {return}
                switch gesture {
                case .rotate(_):
                    UIView.animate(withDuration: 0.5, animations: {
                        this.myViewText.text = nil
                        this.myView.transform = CGAffineTransform.identity
                        this.nextStep😁.onNext()
                    })
                default: break
                }
            }.addDisposableTo(stepBag)
            
        case 6: //any gesture
            myView.rx_gesture().subscribeNext {[weak self] _ in
                guard let this = self else {return}
                UIView.animate(withDuration: 0.5, animations: {
                    this.myView.backgroundColor = UIColor.red
                    this.nextStep😁.onNext()
                })
            }.addDisposableTo(stepBag)

        default: break
        }
        
        print("active gestures: \(myView.gestureRecognizers!.count)")
    }
}

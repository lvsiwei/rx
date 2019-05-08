//
//  ViewController.swift
//  IconFont
//
//  Created by lsw on 2019/5/7.
//  Copyright © 2019 lsw. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Toast_Swift

class ViewController: UIViewController {
    
    let preView = UILabel()
    let fontPick = UIPickerView()
    let input = UITextField()
    let inputW = UITextField()
    let inputH = UITextField()
    let inputScale = UITextField()
    let gBtn = UIButton.init(type: .system)

    var att = NSMutableAttributedString.init()
    
    var fontName = "Zapfino"
    var pxWidth : CGFloat = 200
    var pxHeight : CGFloat = 200
    
    let bag = DisposeBag.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createSubViews()
        
         weak var weakSelf = self
        
        input.rx.text.orEmpty.subscribe { (e) in
            weakSelf?.setupRender()
        }.disposed(by: bag)
       
        input.rx.text.orEmpty.map {
            $0.count>0
        }.bind(to: gBtn.rx.isEnabled).disposed(by: bag)
        
        let data = Observable.just(UIFont.familyNames)
         data.bind(to: fontPick.rx.itemTitles){ (row, element) in
          return String.init(element)
        }.disposed(by: bag)
        
        fontPick.rx.modelSelected(String.self).asObservable().subscribe { (e) in
            weakSelf?.fontName = e.element?.first! ?? "Zapfino"
            weakSelf?.setupRender()
        }.disposed(by: bag)
        
        inputW.rx.text.map { (s) -> CGFloat in
            let double = Double(s ?? "")
            return CGFloat(double ?? 200)
        }.subscribe { (e) in
            weakSelf?.pxWidth = e.element ?? 200
        }.disposed(by: bag)
        
        inputH.rx.text.map { (s) -> CGFloat in
            let double = Double(s ?? "")
            return CGFloat(double ?? 200)
            }.subscribe { (e) in
                weakSelf?.pxHeight = e.element ?? 200
            }.disposed(by: bag)
    }
    
    func generateIconImage(){
        let  minValue = min(pxWidth, pxHeight)
        let scale = CGFloat(Double(inputScale.text ?? "0.5") ?? 0.5)
        let  fontMaxWidth = Int(minValue*scale)
        let count = input.text?.count ?? 0
        let fontSingleWidth  = fontMaxWidth/count
        var font = UIFont.init(name: fontName, size: 40)
        font = font?.withSize(CGFloat(fontSingleWidth))
        
        att.setAttributes([NSAttributedString.Key.font:font ?? UIFont.systemFont(ofSize: 40)], range: NSRange.init(location: 0, length: input.text?.count ?? 0) )
        
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: pxWidth, height: pxHeight), false,2)
        UIColor.white.setFill()
        let size = att.size()
        att.draw(in: CGRect.init(x: pxWidth/2-size.width/2, y: pxHeight/2-size.height/2, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
        UIGraphicsEndImageContext()
    }
    
    @objc func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        guard error == nil else {
            self.view.makeToast("保存失败")
            return
        }
        self.view.makeToast("保存成功!")
    }
    
    
    func setupRender(){
        if let text = input.text {
            att = NSMutableAttributedString.init(string:text , attributes: [NSAttributedString.Key.font:UIFont.init(name: fontName, size: 40) ?? UIFont.systemFont(ofSize: 40)])
            preView.attributedText = att
        }
    }

    func createSubViews (){
        preView.backgroundColor = UIColor.lightGray
        self.view.addSubview(preView)
        preView.textAlignment = .center
        preView.adjustsFontSizeToFitWidth = true
        preView.snp.makeConstraints { (m) in
            m.width.equalTo(200)
            m.height.equalTo(100);
            m.top.equalToSuperview().offset(60)
            m.centerX.equalToSuperview()
        }
        
        self.view.addSubview(input)
        input.placeholder = "内容"
        input.borderStyle = UITextField.BorderStyle.roundedRect
        input.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
            m.height.equalTo(40);
            m.top.equalTo(preView.snp_bottom).offset(20)
        }
        
        self.view.addSubview(inputW)
        inputW.placeholder = "图片宽"
        inputW.borderStyle = UITextField.BorderStyle.roundedRect
        inputW.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
            m.height.equalTo(40);
            m.top.equalTo(input.snp_bottom).offset(20)
        }
        
        self.view.addSubview(inputH)
        inputH.placeholder = "图片高"
        inputH.borderStyle = UITextField.BorderStyle.roundedRect
        inputH.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
            m.height.equalTo(40);
            m.top.equalTo(inputW.snp_bottom).offset(20)
        }
        
        self.view.addSubview(inputScale)
        inputScale.placeholder = "文字占图片比列"
        inputScale.borderStyle = UITextField.BorderStyle.roundedRect
        inputScale.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
            m.height.equalTo(40);
            m.top.equalTo(inputH.snp_bottom).offset(20)
        }
        
        self.view.addSubview(fontPick)
        fontPick.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
            m.height.equalTo(100);
            m.top.equalTo(inputScale.snp_bottom).offset(20)
        }
        
        gBtn.setTitle("生成", for: .normal)
        self.view.addSubview(gBtn)
        gBtn.snp.makeConstraints { (m) in
            m.width.equalTo(100)
            m.height.equalTo(44)
            m.bottom.equalToSuperview().offset(-30)
            m.centerX.equalToSuperview()
        }
        gBtn.rx.tap.subscribe { (e) in
            self.generateIconImage()
        }.disposed(by: bag)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}


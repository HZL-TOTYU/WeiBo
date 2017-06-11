//
//  ComposeViewController.swift
//  WeiBo
//
//  Created by 渠晓友 on 2017/6/8.
//  Copyright © 2017年 xiaoyouPrince. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {
    
    // MARK: - 懒加载属性
    fileprivate lazy var titleView : ComposeTitleView = ComposeTitleView(frame: CGRect(x: 0, y: 0, width: kScreenW / 2, height: 40))
    fileprivate lazy var images : [UIImage] = [UIImage]()
    fileprivate lazy var emotionVC : EmotionController = EmotionController {[unowned self] (emtion) in
        self.insertEmotionIntoTextView(emtion)
    }
    
    // MARK: - 控件属性
    @IBOutlet weak var textView: ComposeTextView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var picPickerView: PicPickerView!
    
    // MARK: - 约束
    @IBOutlet weak var toolBarBottomCons: NSLayoutConstraint!
    @IBOutlet weak var picPickerViewHCons: NSLayoutConstraint!

    
    // MARK: - 系统调用
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNav()
        
        addNotifications()
        
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.delegate = self
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
    }
    
    // 移除监听
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func insertEmotionIntoTextView(_ emotion : Emotion){
        
        Dlog(emotion)
        
        // 空表情 不行
        if emotion.isEmpty {
            return
        }
        
        // 删除表情
        if emotion.isRemove {
            
            textView.deleteBackward()
        }
        
        //emoji表情，直接插入
        if (emotion.emojiCode != nil) {
            
            /**
             let textRange = textView.selectedTextRange!
             textView.replace(textRange, withText: emotion.emojiCode!)
             */
            
            textView.insertText(emotion.emojiCode!)
        }
        
    }
    
}


// MARK: - 设置UI
extension ComposeViewController{
    
    
    /// 设置导航栏
    fileprivate func setupNav(){
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelItemClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发布", style: .plain, target: self, action: #selector(commitItemClick))
        navigationItem.rightBarButtonItem?.isEnabled = false

        navigationItem.titleView = titleView
        
    }
    
   
}


// MARK: - 事件监听
extension ComposeViewController{
    
    
    /// 取消 item 点击
    @objc fileprivate func cancelItemClick(){
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 发送 item 点击
    @objc fileprivate func commitItemClick(){
        
    }
    
    
    /// 添加图片按钮点击
    ///
    /// - Parameter sender: 对应按钮
    @IBAction func picPickerBtnClick(_ sender: Any) {
        
        textView.resignFirstResponder()
        
        picPickerViewHCons.constant = kScreenH * 0.65
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    /// emotionBtn点击事件处理
    @IBAction func emotionBtnClick() {
        
        textView.resignFirstResponder()
        
        textView.inputView = textView.inputView != nil ? nil : emotionVC.view
        
        textView.becomeFirstResponder()
    }
    
    
    /// 设置通知中心监听
    fileprivate func addNotifications(){
        
        // 1.监听键盘弹出和收回
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrame(noti:)), name: .UIKeyboardWillChangeFrame, object: nil)
        
        // 2.添加和删除图片
        NotificationCenter.default.addObserver(self, selector: #selector(picPickerAddPhoto), name:picPickerAddPhotoNote, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(picPickerDeletePhoto(note:)), name:picPickerDeletePhotoNote, object: nil)
    
    }
    
    
    
    
    /// 键盘弹出方法
    ///
    /// - Parameter noti: 通知
    @objc fileprivate func keyboardDidChangeFrame(noti : Notification){
        
        let duration = noti.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        let endFrame = (noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        toolBarBottomCons.constant = kScreenH - endFrame.origin.y
        UIView.animate(withDuration: duration) { 
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    /// 添加图片
    @objc fileprivate func picPickerAddPhoto(){
        
        
        // 1.推出图片控制器
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            return
        }
        
        let ipc = UIImagePickerController()
        
        ipc.sourceType = .photoLibrary
        
        ipc.delegate = self
        
        present(ipc, animated: true, completion: nil)
        
    }
    
    /// 删除图片
    @objc fileprivate func picPickerDeletePhoto(note : Notification){
        
        //  1.删除不需要照片，从数据源中删除，重新赋值
        guard let image = note.object as? UIImage else {
            return
        }
        
        guard let index = self.images.index(of: image)else {
            return
        }
        
        self.images.remove(at: index)
        
        picPickerView.images = self.images
   
    }
    
}

// MARK: - 图片选择控制器的代理方法
extension ComposeViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        Dlog(info)
        
        // 得到原图
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // 传给picPickerView做数据源
        images.append(image)
        picPickerView.images = images
        
        // 推出ipc
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}



// MARK: - textView 的代理方法
extension ComposeViewController : UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {

        self.textView.label.isHidden = textView.hasText
        navigationItem.rightBarButtonItem?.isEnabled = textView.hasText
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        textView.resignFirstResponder()
        
        // 隐藏picPickerView
        picPickerViewHCons.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}

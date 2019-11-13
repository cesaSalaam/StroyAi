//
//  chatController.swift
//  StoryAi
//
//  Created by Cesa Salaam on 4/20/19.
//  Copyright © 2019 Cesa Salaam. All rights reserved.
//

import UIKit
import Toolbar
import SnapKit
import ReverseExtension

class chatController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate  {
    let containerView = UIView()
    let toolbar: Toolbar = Toolbar()
    var textView: UITextView?
    var item0: ToolbarItem?
    var item1: ToolbarItem?
    var toolbarBottomConstraint: NSLayoutConstraint?
    var constraint: NSLayoutConstraint?
    
    var badStoryLine = StoryAiService.storyAI.storyLine(change: true)
    var goodStoryLine = StoryAiService.storyAI.storyLine(change: false)
    
    var storyLine = [String]()
    
    var tellStory = true
    
    //Messages
    var TableView = UITableView()
    var messages = [Message]()
    
    var isMenuHidden: Bool = false {
        didSet {
            if oldValue == isMenuHidden {
                return
            }
            self.toolbar.layoutIfNeeded()
            UIView.animate(withDuration: 0.3) {
                self.toolbar.layoutIfNeeded()
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        
        self.view.addSubview(containerView)
        containerView.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.view.snp.bottomMargin)
            make.right.equalTo(self.view)
            make.left.equalTo(self.view)
            make.top.equalTo(self.view.snp.topMargin)
        }
        //setup background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.chatBackgroundEnd.cgColor, UIColor.chatBackgroundStart.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        containerView.layer.addSublayer(gradientLayer)
        
        //add tool bar
        containerView.addSubview(toolbar)
        self.toolbarBottomConstraint = self.toolbar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)
        self.toolbarBottomConstraint?.isActive = true
        let bottomView = UIView()
        bottomView.backgroundColor = .chatBackgroundEnd
        containerView.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(containerView)
            make.left.equalTo(containerView)
            make.top.equalTo(toolbar.snp.bottom)
            make.height.equalTo(100)
        }
        
        //add table view
        containerView.addSubview(TableView)
        TableView.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(toolbar.snp.top)
            make.right.equalTo(containerView)
            make.left.equalTo(containerView)
            make.top.equalTo(containerView)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.storyLine = self.badStoryLine
        print("this is the current story line: \(self.storyLine)")
        //add back button
        let backButton = UIButton()
        backButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        backButton.clipsToBounds = true
        backButton.layer.cornerRadius = 25
        backButton.setImage(UIImage(named: "icon_close"), for: .normal)
        backButton.addTarget(self, action: #selector(backHome), for: .touchUpInside)
        containerView.addSubview(backButton)
        backButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(containerView.snp.top).offset(15)
            make.height.equalTo(50)
            make.width.equalTo(50)
            make.centerX.equalTo(containerView)
        }
        
        //setup tool bar
        let textView: UITextView = UITextView(frame: .zero)
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        textView.textColor = .white
        self.textView = textView
        textView.layer.cornerRadius = 10
        item0 = ToolbarItem(customView: textView)
        item1 = ToolbarItem(title: "SEND", target: self, action: #selector(send))
        item1!.tintColor = .blue
        item1!.setEnabled(true, animated: false)
        toolbar.setItems([item0!, item1!], animated: false)
        toolbar.backgroundColor = .black
        
        let toolbarWrapperView = UIView()
        toolbarWrapperView.backgroundColor = .grayBlue
        toolbar.insertSubview(toolbarWrapperView, at: 1)
        toolbarWrapperView.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(toolbar)
            make.right.equalTo(toolbar)
            make.left.equalTo(toolbar)
            make.top.equalTo(toolbar)
        }
        
        let gestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hide))
        self.view.addGestureRecognizer(gestureRecognizer)
        
        //setup messages table view
        TableView.dataSource = self
        TableView.delegate = self
        TableView.re.delegate = self
        
        TableView.tableFooterView = UIView()
        TableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserTableViewCell")
        TableView.register(UINib(nibName: "TextResponseTableViewCell", bundle: nil), forCellReuseIdentifier: "TextResponseTableViewCell")
        TableView.register(UINib(nibName: "ForecastResponseTableViewCell", bundle: nil), forCellReuseIdentifier: "ForecastResponseTableViewCell")
        TableView.estimatedRowHeight = 56
        TableView.separatorStyle = .none
        TableView.rowHeight = UITableView.automaticDimension
        TableView.backgroundColor = .clear
        
        
        TableView.re.scrollViewDidReachTop = { scrollView in
            print("scrollViewDidReachTop")
        }
        TableView.re.scrollViewDidReachBottom = { scrollView in
            print("scrollViewDidReachBottom")
        }
        
        //send welcome message
        sendWelcomeMessage()
        startStory()
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        self.toolbar.setNeedsUpdateConstraints()
    }
    
    @objc func backHome() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[messages.count - (indexPath.row + 1)]
        
       var AIcounter = 0
        
        for item in messages{
            if item.type == .botText{
                AIcounter += 1
            }
        }
        
        switch message.type {
        case .user:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! UserTableViewCell
            cell.configure(with: message)
            StoryAiService.storyAI.sentimentAnalysis(userInput: message.text, completionHandler: { value in
                if value == true{
                    self.storyLine = self.goodStoryLine
                    self.tellStory = true
                }else{
                    self.storyLine = self.badStoryLine
                    self.tellStory = true
                }
            })
            
            return cell
        case .botText:
            AIcounter += 1
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextResponseTableViewCell", for: indexPath) as! TextResponseTableViewCell
            cell.configure(with: message)
            return cell
        }
        
    }
    
    @objc func hide() {
        self.textView?.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        moveToolbar(up: true, notification: notification)
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        moveToolbar(up: false, notification: notification)
    }
    
    @objc func send() {
        if self.textView!.text != "" {
            
            //user message
            let message = Message(text: self.textView!.text!, date: Date(), type: .user)
            sendMessage(message)
            
            //reset
            self.textView?.text = nil
            if let constraint: NSLayoutConstraint = self.constraint {
                self.textView?.removeConstraint(constraint)
            }
            self.toolbar.setNeedsLayout()
        }
        
    }
    
    // MARK:- send message
    func sendMessage(_ message: Message) {
        messages.append(message)
        TableView.beginUpdates()
        TableView.re.insertRows(at: [IndexPath(row: messages.count - 1, section: 0)], with: .automatic)
        TableView.endUpdates()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.isMenuHidden = true
        self.tellStory = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("editing ended")
        self.tellStory = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size: CGSize = textView.sizeThatFits(textView.bounds.size)
        if let constraint: NSLayoutConstraint = self.constraint {
            textView.removeConstraint(constraint)
        }
        self.constraint = textView.heightAnchor.constraint(equalToConstant: size.height)
        self.constraint?.priority = UILayoutPriority.defaultHigh
        self.constraint?.isActive = true
    }
    
    func moveToolbar(up: Bool, notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        let animationDuration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardHeight = up ? -(userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height : 0
        
        // Animation
        self.toolbarBottomConstraint?.constant = keyboardHeight
        UIView.animate(withDuration: animationDuration, animations: {
            self.toolbar.layoutIfNeeded()
        }, completion: nil)
        self.isMenuHidden = up
    }
    
    // MARK:- welcome message
    
    func sendWelcomeMessage() {
        let firstTime = true
        if firstTime {
            let text = StoryAiService.storyAI.intro
            let message = Message(text: text, date: Date(), type: .botText)
            messages.append(message)
        }
    }
    

    var counter = 0

    func startStory(){
        print("story line length: \(storyLine.count)")
        if !tellStory{return}
        print("here: \(self.counter)")
        
        if counter == 0{
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if self.tellStory {
                
                let text = self.storyLine[0]
                let message = Message(text: text, date: Date(), type: .botText)
                self.messages.append(message)
                self.TableView.beginUpdates()
                self.TableView.re.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .automatic)
                self.TableView.endUpdates()// replay first showAnimation
            }
            
        }
    }
        self.counter = 1
    if counter == 1{
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                if self.tellStory {
                    self.counter += 1
                    print("story length after change: \(self.storyLine.count)")
                    let text = self.storyLine[1]
                    let message = Message(text: text, date: Date(), type: .botText)
                    self.messages.append(message)
                    self.TableView.beginUpdates()
                    self.TableView.re.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .automatic)
                    self.TableView.endUpdates()// replay first showAnimation
                    print("counter: \(self.counter)")
                }
                
                }
                
        }
        self.counter = 2
        if counter == 2{
        DispatchQueue.main.asyncAfter(deadline: .now() + 20.0) {
                    if self.tellStory {
                        let text = self.storyLine[2]
                        let message = Message(text: text, date: Date(), type: .botText)
                        self.messages.append(message)
                        self.TableView.beginUpdates()
                        self.TableView.re.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .automatic)
                        self.TableView.endUpdates()// replay first showAnimation
            }
            
            }
            
        }
        self.counter = 3
        if counter == 3{
            DispatchQueue.main.asyncAfter(deadline: .now() + 35.0) {
                if self.tellStory {
                    let text = self.storyLine[3]
                    let message = Message(text: text, date: Date(), type: .botText)
                    self.messages.append(message)
                    self.TableView.beginUpdates()
                    self.TableView.re.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .automatic)
                    self.TableView.endUpdates()// replay first showAnimation
                }
            }
            
        }
        self.counter = 4
        if counter == 4{
        DispatchQueue.main.asyncAfter(deadline: .now() + 45.0) {
            if self.tellStory {
                self.counter += 1
                let text = self.storyLine[4]
                let message = Message(text: text, date: Date(), type: .botText)
                self.messages.append(message)
                self.TableView.beginUpdates()
                self.TableView.re.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .automatic)
                self.TableView.endUpdates()// replay first showAnimation
            }
        }
    }
        self.counter = 5
        if counter == 5{
            DispatchQueue.main.asyncAfter(deadline: .now() + 45.0) {
                if self.tellStory {
                    self.counter += 1
                    let text = self.storyLine[5]
                    let message = Message(text: text, date: Date(), type: .botText)
                    self.messages.append(message)
                    self.TableView.beginUpdates()
                    self.TableView.re.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .automatic)
                    self.TableView.endUpdates()// replay first showAnimation
                }
            }
        }
        
    }
    
    func delay(delay: Double, closure: @escaping () -> ()) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            closure()
        }
    }
    
    }
    




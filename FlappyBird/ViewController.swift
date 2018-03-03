//
//  ViewController.swift
//  FlappyBird
//
//  Created by 　若原　昌史 on 2018/02/24.
//  Copyright © 2018年 WakaharaMasashi. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        let scene = GameScene(size:skView.frame.size)
        skView.presentScene(scene)
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var prefersStatusBarHidden:Bool{
        get{
            return true
        }
    }

}


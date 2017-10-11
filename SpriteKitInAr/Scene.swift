//
//  Scene.swift
//  SpriteKitInAr
//
//  Created by Liyanjun on 2017/10/10.
//  Copyright © 2017年 liyanjun. All rights reserved.
//

import SpriteKit
import ARKit

class Scene: SKScene {
    
    var playing = false//是否在play
    
    //计时器
    var timer = Timer()
    
    //分数
    var score = 0
    
    override func didMove(to view: SKView) {
        // Setup your scene here
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func displayMenu(){
        /**
         SKLabelNode: 一种 label 來使用的 node
         name???
         */
        
        let logoLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        logoLabel.fontSize = 50.0
        
        logoLabel.text = "Game Over!"
        logoLabel.verticalAlignmentMode = .center
        logoLabel.horizontalAlignmentMode = .center
        
        logoLabel.position = CGPoint(x: frame.midX, y: frame.midY + logoLabel.frame.size.height)
        
        logoLabel.name = "Menu"
        self.addChild(logoLabel)
        
        let infoLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        infoLabel.fontSize = 50.0
        
        infoLabel.text = "你被炸飞了"
        infoLabel.verticalAlignmentMode = .center
        infoLabel.horizontalAlignmentMode = .center
        
        infoLabel.position = CGPoint(x: frame.midX, y: frame.midY - infoLabel.frame.size.height)
        
        infoLabel.name = "Menu"
        self.addChild(infoLabel)
        
        //      最高分
        let higthtScore = SKLabelNode(fontNamed: "AvenirNext-Bold")
        higthtScore.fontSize = 50.0
        
        higthtScore.text = "最高分：\(UserDefaults.standard.integer(forKey: "HighestScore"))"
        higthtScore.verticalAlignmentMode = .center
        higthtScore.horizontalAlignmentMode = .center
        
        higthtScore.position = CGPoint(x: frame.midX, y: infoLabel.frame.midY - higthtScore.frame.size.height * 2 )
        
        higthtScore.name = "Menu1" //??
        self.addChild(higthtScore)
        
        
        //点击屏幕从新开始
        let beginAgain = SKLabelNode(fontNamed: "AvenirNext-Bold")
        beginAgain.fontSize = 30.0
        beginAgain.text = "点击屏幕从新开始"
        beginAgain.verticalAlignmentMode = .center
        beginAgain.horizontalAlignmentMode = .center
        
        beginAgain.position = CGPoint(x: frame.midX, y: higthtScore.frame.midY - beginAgain.frame.size.height*2)
        
        beginAgain.name = "Menu1"
        self.addChild(beginAgain)
    }
    
    //添加炸弹
    
    func addBomd()  {
        
        guard let sceneView = self.view as? ARSKView else {
                        return
        }
        
        //判断镜头的位置
        if let currentFrame = sceneView.session.currentFrame {
            
            let xOffset = Float(arc4random_uniform(UInt32(10)))/10 - 1.5
            
            let zOffset = Float(arc4random_uniform(UInt32(30)))/10 + 0.5
            
            var transFrame = matrix_identity_float4x4
            
            transFrame.columns.3.x = currentFrame.camera.transform.columns.3.x - xOffset
            transFrame.columns.3.z = currentFrame.camera.transform.columns.3.z - zOffset
            transFrame.columns.3.y = currentFrame.camera.transform.columns.3.y
            
            let archor = ARAnchor(transform: transFrame)
            
            
            sceneView.session.add(anchor: archor)
            
        }
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(explode), userInfo: nil, repeats: false)
        
    }
    
    @objc func explode(){
        
        //游戏结束
        
        timer.invalidate()//暂停计时器
        
        if UserDefaults.standard.integer(forKey: "HighestScore") < score {
            
            UserDefaults.standard.set(score, forKey: "HighestScore")
        }
        
        //数一下有是多少炸弹
        for node in children{
            if let node = node as? SKLabelNode, node.name == "Bomb"{
               node.text = "💥"
                
               node.name = "Menu"
                
                let scaleExlode = SKAction.scale(to: 30, duration: 1.0)
                
                node.run(scaleExlode, completion: {
                    self.displayMenu()
                    self.score = 0
                    self.playing = false
                })
                
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if !playing {
            playing = true
            for lable in children {
                lable.removeFromParent()//移除炸弹
            }
            self.addBomd()
        
        }else{
            //如果在游戏中
            //判断是否第一次点击屏幕
            guard let location = touches.first?.location(in: self) else{
               return
            }
            
            //查看所有子节点是否在范围内
            
            for node in children{
                
                timer.invalidate() //
                score += 1 // 分数加一
                
                
                if node.contains(location),node.name == "Bomb"{
                    //让他在0.5秒消失
                    
                    let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                    node.run(fadeOut, completion: {
                        node.removeFromParent()
                        //添加新的炸弹
                        self.addBomd()
                    })


                }
            }
            
            
        }
        
        
    }
}

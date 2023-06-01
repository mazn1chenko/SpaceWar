//
//  GameViewController.swift
//  SpaceWar
//
//  Created by m223 on 30.05.2023.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var gameScene: GameScene!
    var pauseViewController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pauseViewController = storyboard?.instantiateViewController(withIdentifier: "PauseViewController")
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                
                gameScene = (scene as! GameScene)
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func showVC(_ viewController: UIViewController){
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = view.bounds
        
        
    }
    
    @IBAction func pauseButtonPress(_ sender: UIButton) {
        gameScene.pauseButtonPressed(sender: sender)
        
        showVC(pauseViewController)
    }
    
}

//
//  GameScene.swift
//  ZombiConga
//
//  Created by Jorge Rebollo J on 24/07/16.
//  Copyright (c) 2016 RGStudio. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    
    let zombieAnimation: SKAction
    
    //Optimización de bajadas de fps (evitar lack)
    var lastUpdatedTime : NSTimeInterval = 0 //Última actualización de pantalla en método update
    var dt : NSTimeInterval = 0 //Delta Time desde la última actualización
    
    let zombiePixelsPerSecond : CGFloat = 500.0
    let zombieAnglesPerSecond : CGFloat = 1.0 * π
    
    var velocity = CGPointZero
    var lastTouchLocation =  CGPointZero
    
    let playableArea : CGRect
    
    let catSound = SKAction.playSoundFileNamed("hitCat", waitForCompletion: false)
    let enemySound = SKAction.playSoundFileNamed("hitCatLady", waitForCompletion: false)
    
    var isInvisible:Bool
    
    let catPixelsPerSecond: CGFloat = 500.0
    
    var zombielives = 5
    var congaCount = 0
    let objective = 25
    var isGameOver = false
    
    let backgroundPixelsPerSecond: CGFloat = 200.0
    
    let backgroundLayer = SKNode()
    
    let livesLabel: SKLabelNode
    let catsLabel: SKLabelNode
    
    override init(size:CGSize) {
        let maxAspectRatio:CGFloat = 16.0 / 9.0
        let playableHeight = size.width / maxAspectRatio
        var playableMargin = size.height
        if playableHeight <= size.height {
            playableMargin = (size.height - playableHeight) / 2.0
        }
        playableArea = CGRectMake(0, playableMargin, size.width, playableHeight)
        
        //Array con imagenes para animar al zombie
        var zombieTextures:[SKTexture] = []
        for i in 1...4 {
            zombieTextures.append(SKTexture(imageNamed:"zombie\(i)"))
        }
        zombieTextures.append(zombieTextures[2])
        zombieTextures.append(zombieTextures[1])
        
        zombieAnimation = SKAction.repeatActionForever(SKAction.animateWithTextures(zombieTextures, timePerFrame: 0.15))
        
        isInvisible = false
        
        livesLabel = SKLabelNode(fontNamed: "Copperplate")
        catsLabel = SKLabelNode(fontNamed: "Copperplate")
        
        super.init(size:size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        //Este fragmento se ejecuta cuando se crea la pantalla y aquí se configuran las variables de la escena.
        
        backgroundColor = SKColor.whiteColor()
        
        backgroundLayer.zPosition = -1
        addChild(backgroundLayer)
        for i in 0...1 {
            let background = backgroundNode()
            background.position = CGPointMake(CGFloat(i) * background.size.width, 0)
            background.anchorPoint = CGPointZero
            background.zPosition = -1
            background.name = "background"
            backgroundLayer.addChild(background)
        }
        
        zombie.position = CGPointMake(300, 300)
        zombie.xScale = 1
        zombie.yScale = 1
        zombie.zPosition = 100
        
        //zombie.runAction(zombieAnimation)
        backgroundLayer.addChild(zombie)
        
        //spawnEnemy()
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnEnemy), SKAction.waitForDuration(2.5)])))
        
        //spawnCat()
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnCat), SKAction.waitForDuration(1.0)])))
        
        //let sizeBackground = background.size
        //print("El tamaño del fondo es: \(sizeBackground)")
        
        playBackgroundMusic("backgroundMusic.mp3")
        
        livesLabel.position = CGPointMake(50, CGRectGetMaxY(playableArea)-50)
        livesLabel.fontSize = 100
        livesLabel.verticalAlignmentMode = .Top
        livesLabel.horizontalAlignmentMode = .Left
        addChild(livesLabel)
        
        catsLabel.position = CGPointMake(CGRectGetMaxX(playableArea)-50, CGRectGetMaxY(playableArea)-50)
        catsLabel.fontSize = 100
        catsLabel.verticalAlignmentMode = .Top
        catsLabel.horizontalAlignmentMode = .Right
        addChild(catsLabel)
        
        updateHUD()
    }
    
    /////// El update se hace 60 veces por segundo. Codificar este método adecuadamente para mantener el rendimiento ///////
    override func update(currentTime: CFTimeInterval) {
        if lastUpdatedTime > 0 {
            dt = currentTime - lastUpdatedTime
            //print("Delta time: \(dt)")
        } else {
            dt = 0
        }
        
        lastUpdatedTime = currentTime
        //print("La última actualización ha sido hace \(dt*1000) milisegundos")
        
        checkBounds()
        
        /*if (zombie.position - lastTouchLocation).lenght() < zombiePixelsPerSecond * CGFloat (dt) {
            velocity = CGPointZero
            stopZombie()
        } else {*/
            moveSprite(zombie, velocity: velocity)
            rotateSprite(zombie, direction: velocity)
        //}
        
        //Formar al gato en la conga
        moveConga()
        moveBackground()
        
        if zombielives <= 0 && !isGameOver {
            isGameOver = true
            backgroundAudioPlayer.stop()
            let gameOverScene = GameOverScene(size:size, hasWon: false)
            gameOverScene.scaleMode = scaleMode
            
            let transition = SKTransition.flipVerticalWithDuration(1.0)
            view?.presentScene(gameOverScene, transition: transition)
        }
        
        if congaCount >= objective && !isGameOver {
            isGameOver = true
            backgroundAudioPlayer.stop()
            let gameOverScene = GameOverScene(size:size, hasWon: true)
            gameOverScene.scaleMode = scaleMode
            
            let transition = SKTransition.flipVerticalWithDuration(1.0)
            view?.presentScene(gameOverScene, transition: transition)
        }
    }
    
    func moveSprite(sprite:SKSpriteNode, velocity:CGPoint) {
        // espacio = velocidad * tiempo (S = V*t)
        let amount = velocity * CGFloat (dt)
        //print("Cantidad de movimiento: \(amount)")
        sprite.position += amount
    }
    
    func moveZombieLocation(location:CGPoint) {
        //Cantidad de movimiento que hay que incrementar al zombie para posicionarlo donde se ha tocado la pantalla
        let offset = location - zombie.position
        
        let direction = offset.normalize() //Un vector unitario de movimiento
        velocity = direction * zombiePixelsPerSecond
        
        animateZombie()
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        lastTouchLocation = touchLocation
        moveZombieLocation(touchLocation)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first! as UITouch
        let location = touch.locationInNode(backgroundLayer)
        sceneTouched(location)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first! as UITouch
        let location = touch.locationInNode(backgroundLayer)
        sceneTouched(location)
    }
    
    func checkBounds() {
        let bottomLeft = backgroundLayer.convertPoint(CGPointMake(0, CGRectGetMinY(playableArea)), fromNode: self)
        let upperRight = backgroundLayer.convertPoint(CGPointMake(size.width, CGRectGetMaxY(playableArea)), fromNode: self)
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.x >= upperRight.x {
            zombie.position.x = upperRight.x
            velocity.x = -velocity.x
        }
        if zombie.position.y >= upperRight.y {
            zombie.position.y = upperRight.y
            velocity.y = -velocity.y
        }
    }
    
    func rotateSprite(sprite:SKSpriteNode, direction:CGPoint) {
        let shortestAngle = shortesAngleBetween(sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(zombieAnglesPerSecond * CGFloat(dt), abs(shortestAngle))
        sprite.zRotation += amountToRotate * shortestAngle.sign()
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name =  "enemy"
        enemy.position = self.backgroundLayer.convertPoint(CGPointMake(size.width + enemy.size.width/2, CGFloat.random(CGRectGetMinY(playableArea) +  enemy.size.height/2, max:CGRectGetMaxY(playableArea) - enemy.size.height/2)), fromNode: self)
        
        backgroundLayer.addChild(enemy)
        
        let actionTraslation = SKAction.moveTo(self.backgroundLayer.convertPoint(CGPointMake(-enemy.size.width/2, enemy.position.y), fromNode: self), duration: 2.5)
        let actionRemove = SKAction.removeFromParent()
        
        enemy.runAction(SKAction.sequence([actionTraslation, actionRemove]))
        
        /*
        //let actionFirstMove = SKAction.moveTo(CGPointMake(size.width/2, CGRectGetMinY(playableArea)+enemy.size.height/2), duration: 2.0)
        let actionFirstMove = SKAction.moveByX(-enemy.size.width/2-size.width/2, y: -CGRectGetHeight(playableArea)/2+enemy.size.height/2, duration: 1.5)
        
        let actionPrint = SKAction.runBlock() {
            print("He llegado abajo")
        }
        
        let actionWait = SKAction.waitForDuration(0.3)
        
        //let actionSecondMove = SKAction.moveTo(CGPointMake(-enemy.size.width/2, enemy.position.y), duration: 2.0)
        let actionSecondMove = SKAction.moveByX(-enemy.size.width/2-size.width/2, y: CGRectGetHeight(playableArea)/2-enemy.size.height/2, duration: 1.5)
        
        //let actionFirstMoveReversed = actionFirstMove.reversedAction()
        
        //let actionSecondMoveReversed =  actionSecondMove.reversedAction()
        
        let sequenceHalf = SKAction.sequence([actionFirstMove, actionPrint, actionWait, actionSecondMove])
        
        let sequenceHAlfReversed =  sequenceHalf.reversedAction()
        
        let sequence = SKAction.sequence([sequenceHalf, sequenceHAlfReversed])
        
        let actionRepeat = SKAction.repeatActionForever(sequence)
        
        //let sequence  = SKAction.sequence([actionFirstMove, actionPrint, actionWait, actionSecondMove, actionSecondMoveReversed, actionPrint, actionWait, actionFirstMoveReversed])
        //enemy.runAction(sequence)
        enemy.runAction(actionRepeat)
        */
    }
    
    func spawnCat () {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        //cat.position = (CGPointMake(300, 300))
        cat.position = self.backgroundLayer.convertPoint(CGPointMake(
            CGFloat.random(CGRectGetMinX(playableArea), max:CGRectGetMaxX(playableArea)),
            CGFloat.random(CGRectGetMinY(playableArea), max:CGRectGetMaxY(playableArea))), fromNode: self)
        cat.setScale(0)
        backgroundLayer.addChild(cat)
        
        let appear = SKAction.scaleTo(1, duration: 1.0)
        //let wait = SKAction.waitForDuration(8.0)
        
        //Bloque rotación
        cat.zRotation = -π/16.0 //Rotar aproximadamente 11 grados en sentido de las manecillas del reloj
        let rotationLeft = SKAction.rotateByAngle(π/8.0, duration: 0.25) //Rotamos 22 grados en stendido contrario a las manecillas del reloj
        let rotationright = rotationLeft.reversedAction() //Rotamos 22 grados en sentido de las manecillas del reloj
        let fullRotation = SKAction.sequence([rotationLeft, rotationright])
        //let rotationWait = SKAction.repeatAction(fullRotation, count:16) //El repeat tiene una vigencia para que se logre ejecutar en la secuencia: disappear y remove. Pero cumple con el total de tiempo que requiere el movimiento. 0.25 s para rotationLeft, 0.25 s para rotationRight, es igual a 0.5 s para fullRotation. El tiempo de fullRotation por 16 veces, nos da el tiempo del rotationWait como resultado, osea 8 segundos.

        //Bloque escalado
        let scaleUp = SKAction.scaleBy(1.25, duration: 0.25)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence([scaleUp, scaleDown])
        
        //Bloque de espera
        let group = SKAction.group([fullRotation, fullScale])
        let groupWait = SKAction.repeatAction(group, count:16)
        
        let disappear = SKAction.scaleTo(0, duration: 1.0)
        let remove = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([appear, groupWait, disappear, remove])
        cat.runAction(sequence)
    }
    
    func animateZombie() {
        if zombie.actionForKey("animation") == nil {
            zombie.runAction(zombieAnimation, withKey: "animation")
        }
    }
    
    func stopZombie() {
        zombie.removeActionForKey("animation")
    }
    
    func zombieHitsCat(cat: SKSpriteNode) {
        //cat.removeFromParent()
        runAction(catSound)
        cat.name = "conga"
        cat.removeAllActions()
        cat.setScale(1.0)
        cat.zRotation =  0.0
        
        let greenCat = SKAction.colorizeWithColor(SKColor.greenColor(), colorBlendFactor: 1.0, duration: 0.5)
        cat.runAction(greenCat)
        
        congaCount += 1
        updateHUD()
    }
    
    func zombieHitsEnemy(enemy:SKSpriteNode) {
        //enemy.removeFromParent()
        runAction(enemySound)
        
        loseCats()
        //Eliminar vida a zombie
        zombielives -= 1
        updateHUD()
        
        self.isInvisible = true
        let blinkTimes = 12.0
        let blinkDuration = 4.0
        //Acción personalizada de parpadeo
        let blinkAction = SKAction.customActionWithDuration(blinkDuration) { (node, elapsedTime) in
            let slice = blinkDuration / blinkTimes
            let reminder = Double(elapsedTime) % slice
            node.hidden = reminder > slice / 2
        }
        
        let setHidden = SKAction.runBlock {
            self.zombie.hidden =  false
            self.isInvisible = false
        }
        
        zombie.runAction(SKAction.sequence([blinkAction, setHidden]) )
    }
    
    func checkCollisions() {
        //Comprobar colisión con gatos
        var hitCats: [SKSpriteNode] = []
        backgroundLayer.enumerateChildNodesWithName("cat") { (node, _) in
            let cat = node as! SKSpriteNode
            
            let distance = distanceBetweenPoints(self.zombie.position, point2: cat.position)
            let zombieSize = min(self.zombie.frame.size.width, self.zombie.frame.size.height)/2
            let catSize = max(cat.frame.size.width, cat.frame.size.height)/2
            
            if distance < zombieSize + catSize {
                hitCats.append(cat)
            }
        }
        
        for cat in hitCats {
            zombieHitsCat(cat)
        }
        
        if self.isInvisible {
            return
        }
        
        //Comprobar colisión con enemigos
        var hitEnemies: [SKSpriteNode] = []
        backgroundLayer.enumerateChildNodesWithName("enemy") { (node, _) in
            let enemy = node as! SKSpriteNode
            
            let distance = distanceBetweenPoints(self.zombie.position, point2: enemy.position)
            let zombieSize = min(self.zombie.frame.size.width, self.zombie.frame.size.height)/2
            let enemySize = min(enemy.frame.size.width, enemy.frame.size.height)/2
            
            if distance < zombieSize + enemySize  {
                hitEnemies.append(enemy)
            }
        }
        
        for enemy in hitEnemies {
            zombieHitsEnemy(enemy)
        }
    }
    
    //Método que ejecuta las acciones una vez evaluadas dentro del game loop. Esto lleva a cabo las acciones antes del renderizado y los mostrará en el siguiente Update
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    func moveConga() {
        var congaPosition = zombie.position
        
        backgroundLayer.enumerateChildNodesWithName("conga") { (node, _) in
            if !node.hasActions() {
                let actionDuration = 0.2
                
                //Moviendo un punto de una posición a otra
                let offset = congaPosition - node.position
                let director = offset.normalize()
                let amountToMovePerSecond = director * self.catPixelsPerSecond
                let totalAmountToMove = amountToMovePerSecond * CGFloat(actionDuration)
                
                let actionMove =  SKAction.moveByX(totalAmountToMove.x, y: totalAmountToMove.y, duration: actionDuration)
                let actionRotate = SKAction.rotateByAngle(offset.angle - node.zRotation, duration: actionDuration)
                node.runAction(SKAction.group([actionMove, actionRotate]))
            }
            
            congaPosition = node.position
        }
    }
    
    func loseCats() {
        var lostCatsCount = 0
        
        backgroundLayer.enumerateChildNodesWithName("conga") { (node, stop) in //stop indica que el segundo parámetro regula el flujo de enumerate
            var randomCatPosition = node.position
            randomCatPosition.x += CGFloat.random(-150, max:150)
            randomCatPosition.y += CGFloat.random(-150, max:150)
            
            node.name = ""
            
            let rotation = SKAction.rotateByAngle(6*π, duration: 1.0) //2π es una vuelta completa
            let translate = SKAction.moveTo(randomCatPosition, duration: 1.0)
            let disappear = SKAction.scaleTo(0, duration: 1.0)
            
            let groupActions = SKAction.group([rotation, translate, disappear])
            
            let fullSequence = SKAction.sequence([groupActions, SKAction.removeFromParent()])
            
            node.runAction(fullSequence)
            
            lostCatsCount += 1
            self.congaCount -= 1
            self.updateHUD()
            
            if lostCatsCount >= 3 {
                stop.memory = true
            }
        }
    }
    
    func backgroundNode() -> SKSpriteNode {
        let background = SKSpriteNode()
        background.anchorPoint = CGPointZero
        background.name = "background"
        
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPointZero
        background1.position = CGPointZero
        background.addChild(background1)
        
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPointZero
        background2.position = CGPointMake(background1.size.width, 0)
        background.addChild(background2)
        
        background.size = CGSizeMake(background1.size.width + background2.size.width, background1.size.height)
        return background
    }
    
    func moveBackground() {
        let velocity = CGPointMake(-self.backgroundPixelsPerSecond, 0)
        let amountToMove = velocity * CGFloat(self.dt)
        backgroundLayer.position += amountToMove
        
        backgroundLayer.enumerateChildNodesWithName("background") { (node, _) in
            let background = node as! SKSpriteNode
            
            let backgroundLayerPosition = self.backgroundLayer.convertPoint(background.position, toNode: self)
            
            if backgroundLayerPosition.x <= -background.size.width {
                background.position = CGPointMake(background.position.x + 2 * background.size.width, 0)
            }
        }
    }
    
    func updateHUD() {
        livesLabel.text = "Vidas: \(zombielives)"
        catsLabel.text = "Objetivo: \(congaCount)/\(objective)"
    }
}

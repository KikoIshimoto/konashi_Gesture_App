//
//  ViewController.swift
//  konashi-swift-sample
//
//  Created by Wataru Kiryu on 11/11/15.
//  Copyright © 2015 kiryuxxu. All rights reserved.
//

import UIKit
import CoreMotion
let motionManager = CMMotionManager()
class ViewController: UIViewController {
    fileprivate var myLabel: UILabel!
    let pin = KonashiDigitalIOPin.digitalIO1
    let pin2 = KonashiDigitalIOPin.digitalIO2
    var timer = Timer();
    let motion = CMMotionManager()
    var labelK1 = UILabel()
    var labelK2 = UILabel()
    var labelK3 = UILabel()
    var labelK4 = UILabel()
    var acc_x = 0.0
    var acc_y = 0.0
    var acc_z = 0.0
    var sumacc_x = 0.0
    var sumacc_y = 0.0
    var sumacc_z = 0.0
    var sumCount = 1.0;
    var juageFlag = false
    var count = 0;
    var wrigthText = ""
    var wrigthCount = 0
    let sampleNum = 10;
    let sampleData = 100;
    let fileSelect = UIStepper()
    var saveFileName = UILabel()
    var ENum = 4;
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fileSelect.maximumValue = Double(ENum)
        fileSelect.minimumValue = 0
        fileSelect.stepValue = 1;
        fileSelect.layer.position = CGPoint(x: 250, y: 50)
        fileSelect.value = 0
        saveFileName = UILabel(frame: CGRect(x: 0,y: 0,width: 100,height: 50))
        saveFileName.backgroundColor = UIColor.orange
        saveFileName.layer.masksToBounds = true
        saveFileName.textColor = UIColor.white
        saveFileName.shadowColor = UIColor.gray
        saveFileName.font = UIFont.systemFont(ofSize: CGFloat(15))
        saveFileName.textAlignment = NSTextAlignment.center
        saveFileName.layer.position = CGPoint(x: 250,y: 80)
        saveFileName.text = "gesture0.txt"
        fileSelect.addTarget(self, action: #selector(ViewController.onClickMyStepper(_:)), for: UIControlEvents.valueChanged)
        
        self.view.addSubview(saveFileName)
        self.view.addSubview(fileSelect)
        
        motionManager.accelerometerUpdateInterval = 0.1
        let measurementSW = makeButton(1,on:"計測中",off:"待機中")
        measurementSW.isOn = false
        self.view.addSubview(measurementSW)
        let measurementSW2 = makeButton3(1,on:"ジャスチャ保存",off:"ジャスチャ認識待機")
        measurementSW2.isOn = false
        self.view.addSubview(measurementSW2)
        myLabel = UILabel(frame: CGRect(x: 0,y: 0,width: 150,height: 150))
        myLabel.backgroundColor = UIColor.orange
        myLabel.layer.masksToBounds = true
        myLabel.layer.cornerRadius = 75.0
        myLabel.textColor = UIColor.white
        myLabel.shadowColor = UIColor.gray
        myLabel.font = UIFont.systemFont(ofSize: CGFloat(30))
        myLabel.textAlignment = NSTextAlignment.center
        myLabel.layer.position = CGPoint(x: self.view.bounds.width/2,y: 200)
        myLabel.text = "On"
        
        
        
        let debugLabel = makeLabel(CGPoint(x: 30, y: 500), text: "****", rect: CGRect(x: 0, y: 0, width: 50, height: 30))
        self.view.addSubview(debugLabel)
        
        self.view.addSubview(myLabel)
        let countLabel = makeLabel(CGPoint(x: 50, y: 70), text: "data0.txt" , rect:CGRect(x: 0, y: 0, width: 300, height: 50))
        self.view.addSubview(countLabel)
        
        let button = makeButton2(2, on: "演算中", off: "演算する")
        self.view.addSubview(button)
        
        motionManager.startDeviceMotionUpdates( to: OperationQueue.current!, withHandler:{
            deviceManager, error in
            countLabel.text = "data" + self.wrigthCount.description + ".txt"
            let accel: CMAcceleration = deviceManager!.userAcceleration
            
            self.acc_x = accel.x
            self.acc_y = accel.y
            self.acc_z = accel.z
            
            let xm = self.acc_x - self.sumacc_x / self.sumCount
            let ym = self.acc_y - self.sumacc_y / self.sumCount
            let zm = self.acc_z - self.sumacc_z / self.sumCount
            self.sumacc_x += self.acc_x
            self.sumacc_y += self.acc_y
            self.sumacc_z += self.acc_z
            self.sumCount += 1
            
            if(measurementSW.isOn == true)
            {
                if(self.count > 10)
                {
                    self.wrigthText += self.count.description + "," + self.acc_x.description + ","
                    self.wrigthText += self.acc_y.description + "," + self.acc_z.description + "\n"
                }
                self.count += 1;
                if(self.count == self.sampleData + 10)
                {
                    let file_name = "data" + self.wrigthCount.description + ".txt"
                    let text = self.wrigthText //保存する内容
                    
                    if let dir : NSString = NSSearchPathForDirectoriesInDomains( FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true ).first as NSString? {
                        
                        let path_file_name = dir.appendingPathComponent( file_name )
                        
                        do {
                            
                            try text.write( toFile: path_file_name, atomically: false, encoding: String.Encoding.utf8 )
                            
                        } catch {
                            //エラー処理
                        }
                    }
                    self.count = 0;
                    measurementSW.isOn = false
                    self.wrigthCount += 1;
                    self.myLabel.text = "待機中"
                    self.wrigthText = ""
                    self.myLabel.backgroundColor = UIColor.gray
                }
                if(self.wrigthCount == self.sampleNum)
                {
                    self.wrigthCount = 0;
                }
            }else{
                if((abs(xm) > 0.5 || abs(ym) > 0.5 || abs(zm) > 0.5 || self.juageFlag == true) && self.flag == true)
                {
                    self.juageFlag = true
                    if(self.count != self.sampleData)
                    {
                        
                        self.update([self.acc_x,self.acc_y,self.acc_z])
                        
                        self.accpd();
                        self.accpg();
                        self.accpr();
                        self.accpa();
                        self.count += 1
                    }
                    else{
                        var EG:[Double:Int] = [:]
                        print(EG)
                        for i in 0...self.ENum
                        {
                            let file_name = "gesture" + i.description + ".txt"
                            print(file_name)
                            if let dir : NSString = NSSearchPathForDirectoriesInDomains( FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true ).first as NSString?
                            {
                                
                                let path_file_name = dir.appendingPathComponent( file_name )
                                
                                do {
                                    
                                    let text = try NSString( contentsOfFile: path_file_name, encoding: String.Encoding.utf8.rawValue )
                                    let data = text.components(separatedBy: "\n")
                                    
                                    
                                    let tempPd = data[0].components(separatedBy: ",")
                                    let uPd = data[11].components(separatedBy: ",")
                                    let tempPg = data[1].components(separatedBy: ",")
                                    let uPg = data[12].components(separatedBy: ",")
                                    let tempPr = data[2].components(separatedBy: ",")
                                    let uPr = data[13].components(separatedBy: ",")
                                    var tempPa:[[String]] = []
                                    var uPa:[[String]] = []
                                    for i in 3..<11
                                    {
                                        tempPa.append(data[i].components(separatedBy: ","))
                                        uPa.append(data[i+11].components(separatedBy: ","))
                                    }
                                    debugPrint(tempPd)
                                    debugPrint(tempPg)
                                    debugPrint(tempPr)
                                    debugPrint(tempPa)
                                    debugPrint(i)
                                    var temp = 0.0;
                                        for t in 0..<3
                                        {
                                            temp += pow(self.Pd[t] - Double(tempPd[t+1])!,2) / pow(Double(uPd[t+1])! , 2)
                                            temp += pow(self.Pg[t] - Double(tempPg[t+1])!,2) / pow(Double(uPg[t+1])! , 2)
                                            temp += pow(self.Pr[t] - Double(tempPr[t+1])!,2) / pow(Double(uPr[t+1])! , 2)
                                            for n in 0..<8
                                            {
                                                temp += pow(self.Pa[t][n] - Double(tempPa[n][t+1])!,2) / pow(Double(uPa[n][t+1])! , 2)
                                            }
                                        }
                                    EG[temp] = i
                                    self.count = 0
                                    self.juageFlag = false
                                } catch {
                                    //エラー処理
                                }
                            }
                        }
                        
                        debugPrint(EG)
                        debugPrint()
                        var minimam:Double = Double.infinity
                        for eg in EG
                        {
                            minimam = min(minimam, eg.0)
                        }

                        let send1:UInt8 = UInt8(EG[minimam]! + 0x30)
                        let head:UInt8 = String("H").utf8.first! as UInt8
                        let id:UInt8 = String("A").utf8.first! as UInt8
                        let tm:UInt8 = String("0").utf8.first! as UInt8
                        print(self.Pd)
                        print(self.Pg)
                        print(self.Pr)
                        print(self.Pa)
                        debugLabel.text = EG[minimam]!.description
                        debugPrint(EG[minimam])
                        self.reset()
                        if (!Konashi.isReady()) {
                            return
                        }
                        Konashi.uartWrite(head)
                        Konashi.uartWrite(id)
                        Konashi.uartWrite(tm)
                        Konashi.uartWrite(send1)
                    }
                }
            }
        })
        
        /*
        let slider1 = makeSlider(CGPointMake(self.view.frame.midX, 400),max: 50)
        slider1.addTarget(self, action: #selector(ViewController.onChangeValueMySlider1), forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(slider1)
        labelK1 = makeLabel(CGPointMake(30, 400), text: "K1")
        self.view.addSubview(labelK1)
        
        
        let slider2 = makeSlider(CGPointMake(self.view.frame.midX, 440),max: 50)
        slider2.addTarget(self, action: #selector(ViewController.onChangeValueMySlider2), forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(slider2)
        labelK2 = makeLabel(CGPointMake(30, 440), text: "K2")
        self.view.addSubview(labelK2)
        
        
        let slider3 = makeSlider(CGPointMake(self.view.frame.midX, 480),max: 50)
        slider3.addTarget(self, action: #selector(ViewController.onChangeValueMySlider3), forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(slider3)
        labelK3 = makeLabel(CGPointMake(30, 480), text: "K3")
        self.view.addSubview(labelK3)
        
        
        let slider4 = makeSlider(CGPointMake(self.view.frame.midX, 520),max: 20)
        slider4.addTarget(self, action: #selector(ViewController.onChangeValueMySlider4), forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(slider4)
        labelK4 = makeLabel(CGPointMake(30, 520), text: "K4")
        self.view.addSubview(labelK4)
        */
        Konashi.initialize()
        Konashi.shared().readyHandler = {
            
            Konashi.pinMode(self.pin, mode: KonashiPinMode.output)
            Konashi.pwmMode(self.pin2, mode: KonashiPWMMode.enable)
            Konashi.pwmPeriod(self.pin2 ,period:10000)
            Konashi.pwmDuty(self.pin2 ,duty:5000)
            Konashi.uartBaudrate(KonashiUartBaudrate.rate115K2)
            Konashi.uartMode(KonashiUartMode.enable)
            debugPrint("start")
            
        }
        var dat:[UInt8] = [0,0,0]
        /*Konashi.shared().uartRxCompleteHandler = {(data) in
            let d = Konashi.readUartData()
            /*dat[0] = Konashi.uartRead()
            if(dat[0] == 0x48)//H
            {
                dat[1] = Konashi.uartRead()
                dat[2] = Konashi.uartRead()
                print(NSString(bytes: dat, length: 3, encoding:  NSASCIIStringEncoding))
            }
            */
            let string = NSString(data: d, encoding: NSUTF8StringEncoding)
            //let str = string as! String
            if(string!.containsString("H"))
            {
                let str:String = string as! String
                let s = str.componentsSeparatedByString("\n")
                var ans = ""
                for t in s
                {
                    if(t != "")
                    {
                        ans = t
                    }
                }
                print(ans)
                debugLabel.text = ans
            }
        }*/
        Konashi.find()
        
        
        self.view.backgroundColor = UIColor.cyan
    }
    /*
     @IBAction func onChangeSwitch(sender: UISwitch) {
     if (!Konashi.isReady()) {
     return
     }
     Konashi.digitalWrite(self.pin, value: sender.on ? KonashiLevel.High : KonashiLevel.Low)
     }*/
    
    /*
     @IBAction func ledSlider(sender: UISlider) {
     if (!Konashi.isReady()) {
     return
     }
     Konashi.pwmLedDrive(self.pin2, dutyRatio: Int32(sender.value * 100 ))
     }*/
    /*
     @IBAction func serial(sender: UIButton) {
     if (!Konashi.isReady()) {
     return
     }
     Konashi.uartWrite(10)
     }*/
    func makeSlider(_ point:CGPoint,max:Float) -> UISlider
    {
        // Sliderを作成する.
        let mySlider = UISlider(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        mySlider.layer.position = point//CGPointMake(self.view.frame.midX, 500)
        mySlider.backgroundColor = UIColor.white
        mySlider.layer.cornerRadius = 10.0
        mySlider.layer.shadowOpacity = 0.5
        mySlider.layer.masksToBounds = false
        
        // 最小値と最大値を設定する.
        mySlider.minimumValue = 0
        mySlider.maximumValue = max
        
        // Sliderの位置を設定する.
        mySlider.value = 0
        
        // Sliderの現在位置より右のTintカラーを変える.
        mySlider.maximumTrackTintColor = UIColor.gray
        
        // Sliderの現在位置より左のTintカラーを変える.
        mySlider.minimumTrackTintColor = UIColor.black
        return mySlider
    }
    func makeLabel(_ point:CGPoint,text:String,rect:CGRect = CGRect(x: 0, y: 0, width: 60, height: 50)) -> UILabel
    {
        let myLabel: UILabel = UILabel(frame: rect)
        
        // 背景をオレンジ色にする.
        myLabel.backgroundColor = UIColor.orange
        
        // 枠を丸くする.
        myLabel.layer.masksToBounds = true
        
        // コーナーの半径.
        myLabel.layer.cornerRadius = 20.0
        
        // Labelに文字を代入.
        myLabel.text = text
        
        // 文字の色を白にする.
        myLabel.textColor = UIColor.white
        
        // 文字の影の色をグレーにする.
        myLabel.shadowColor = UIColor.gray
        
        // Textを中央寄せにする.
        myLabel.textAlignment = NSTextAlignment.center
        
        // 配置する座標を設定する.
        myLabel.layer.position = point//CGPoint(x: self.view.bounds.width/2,y: 200)
        return myLabel
    }/*
    internal func onChangeValueMySlider1(sender : UISlider){
        labelK1.text = String(sender.value)
        if (!Konashi.isReady()) {
            return
        }
        let sendData:Int16 = Int16(sender.value * 10)
        let head:UInt8 = String("H").utf8.first! as UInt8
        let id:UInt8 = String("1").utf8.first! as UInt8
        
        Konashi.uartWrite(head)
        Konashi.uartWrite(id)
        Konashi.uartWrite(highByte(sendData))
        Konashi.uartWrite(lowByte(sendData))
        
        Konashi.pwmLedDrive(self.pin2, dutyRatio: Int32(sender.value * 2 ))
        
    }
    internal func onChangeValueMySlider2(sender : UISlider){
        
        labelK2.text = String(sender.value)
        let sendData:Int16 = Int16(sender.value * 10)
        let head:UInt8 = String("H").utf8.first! as UInt8
        let id:UInt8 = String("2").utf8.first! as UInt8
        
        Konashi.uartWrite(head)
        Konashi.uartWrite(id)
        Konashi.uartWrite(highByte(sendData))
        Konashi.uartWrite(lowByte(sendData))
    }
    internal func onChangeValueMySlider3(sender : UISlider){
        
        labelK3.text = String(sender.value)
        let sendData:Int16 = Int16(sender.value * 10)
        let head:UInt8 = String("H").utf8.first! as UInt8
        let id:UInt8 = String("3").utf8.first! as UInt8
        
        Konashi.uartWrite(head)
        Konashi.uartWrite(id)
        Konashi.uartWrite(highByte(sendData))
        Konashi.uartWrite(lowByte(sendData))
    }
    internal func onChangeValueMySlider4(sender : UISlider){
        
        labelK4.text = String(sender.value)
        let sendData:Int16 = Int16(sender.value * 10)
        let head:UInt8 = String("H").utf8.first! as UInt8
        let id:UInt8 = String("4").utf8.first! as UInt8
        
        Konashi.uartWrite(head)
        Konashi.uartWrite(id)
        Konashi.uartWrite(highByte(sendData))
        Konashi.uartWrite(lowByte(sendData))
    }*/
    internal func onClickMyStepper(_ sender : UIStepper)
    {
        saveFileName.text = "gesture" + Int(sender.value).description + ".txt"
    }
    func makeButton(_ tag:Int,on:String,off:String) -> UISwitch
    {
        
        // Swicthを作成する.
        let mySwicth: UISwitch = UISwitch()
        mySwicth.layer.position = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height - 200)
        
        // Swicthの枠線を表示する.
        mySwicth.tintColor = UIColor.black
        
        // SwitchをOnに設定する.
        mySwicth.isOn = true
        
        // SwitchのOn/Off切り替わりの際に、呼ばれるイベントを設定する.
        mySwicth.addTarget(self, action: #selector(ViewController.onClickMySwicth(_:)), for: UIControlEvents.valueChanged)
        return mySwicth
    }
    func makeButton3(_ tag:Int,on:String,off:String) -> UISwitch
    {
        
        // Swicthを作成する.
        let mySwicth: UISwitch = UISwitch()
        mySwicth.layer.position = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height - 250)
        
        // Swicthの枠線を表示する.
        mySwicth.tintColor = UIColor.black
        
        // SwitchをOnに設定する.
        mySwicth.isOn = true
        
        // SwitchのOn/Off切り替わりの際に、呼ばれるイベントを設定する.
        mySwicth.addTarget(self, action: #selector(ViewController.onClickMySwicth2(_:)), for: UIControlEvents.valueChanged)
        return mySwicth
    }
    func makeButton2(_ tag:Int,on:String,off:String) -> UIButton
    {
        
        // Buttonを生成する.
        let myButton = UIButton()
        
        // サイズを設定する.
        myButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
        
        // 背景色を設定する.
        myButton.backgroundColor = UIColor.red
        
        // 枠を丸くする.
        myButton.layer.masksToBounds = true
        
        // タイトルを設定する(通常時).
        myButton.setTitle("ジェスチャーデータを作る", for: UIControlState())
        myButton.setTitleColor(UIColor.white, for: UIControlState())
        
        // タイトルを設定する(ボタンがハイライトされた時).
        myButton.setTitle("ジェスチャーデータを作る", for: UIControlState.highlighted)
        myButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
        
        // コーナーの半径を設定する.
        myButton.layer.cornerRadius = 20.0
        
        // ボタンの位置を指定する.
        myButton.layer.position = CGPoint(x: 50, y:100)
        
        // タグを設定する.
        myButton.tag = 1
        
        // イベントを追加する.
        myButton.addTarget(self, action: #selector(ViewController.onClickMyButton(_:)), for: .touchUpInside)
        
        // ボタンをViewに追加する.
        return myButton
    }
    var pCount = 0
    internal func onClickMyButton(_ sender: UIButton){
        for i in 0..<sampleNum
        {
            var text = ""
            let file_name = "data" + i.description + ".txt"
            
            if let dir : NSString = NSSearchPathForDirectoriesInDomains( FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true ).first as NSString? {
                
                let path_file_name = dir.appendingPathComponent( file_name )
                
                do {
                    text = try NSString( contentsOfFile: path_file_name, encoding: String.Encoding.utf8.rawValue ) as String
                    let data = text.components(separatedBy: "\n")
                    reset()
                    for data_acc in data
                    {
                        if(data_acc == "")
                        {
                            break
                        }
                        let tempData = data_acc.components(separatedBy: ",")
                        update([Double(tempData[1])!,Double(tempData[2])!,Double(tempData[3])!])
                        
                        accpd();
                        accpg();
                        accpr();
                        accpa();
                        pCount += 1
                    }
                    let file_name = "temp" + i.description + ".txt"
                    var text = ""
                    text += "Pd," + Pd[0].description + "," + Pd[1].description + "," + Pd[2].description + "\n"
                    text += "Pg," + Pg[0].description + "," + Pg[1].description + "," + Pg[2].description + "\n"
                    text += "Pr," + Pr[0].description + "," + Pr[1].description + "," + Pr[2].description + "\n"
                    for  t in 0..<8 {
                        text += "Pa[" + t.description + "]," + Pa[0][t].description + "," + Pa[1][t].description + "," + Pa[2][t].description + "\n"
                    }
                    
                    if let dir : NSString = NSSearchPathForDirectoriesInDomains( FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true ).first as NSString? {
                        
                        let path_file_name = dir.appendingPathComponent( file_name )
                        
                        do {
                            
                            try text.write( toFile: path_file_name, atomically: false, encoding: String.Encoding.utf8 )
                            
                        } catch {
                            //エラー処理
                        }
                    }
                    
                } catch {
                    //エラー処理
                }
            }
        }
        var ans:[[Double]] = [[Double]](repeating: [Double](repeating: 0, count: 22), count: 3)
        for i in 0..<sampleNum {
            let file_name = "temp" + i.description + ".txt"
            
            if let dir : NSString = NSSearchPathForDirectoriesInDomains( FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true ).first as NSString? {
                
                let path_file_name = dir.appendingPathComponent( file_name )
                
                do {
                    
                    let text = try NSString( contentsOfFile: path_file_name, encoding: String.Encoding.utf8.rawValue )
                    //print( text )
                    let data = text.components(separatedBy: "\n")

                    for t in 0..<11
                    {
                        if(data[t] == "")
                        {
                            break
                        }
                        let tempData = data[t].components(separatedBy: ",")
                        
                        for d in 1..<4
                        {
                            ans[d-1][t] += Double(tempData[d])!
                        }
                    }
                } catch {
                    //エラー処理
                }
            }
        }
        /*
        print(ans[0])
        print(ans[1])
        print(ans[2])*/
        for d in 0..<3 {
            for i in 0..<11
            {
                ans[d][i] /= Double(sampleNum)
            }
        }
        
        for i in 0..<sampleNum {
            let file_name = "temp" + i.description + ".txt"
            
            if let dir : NSString = NSSearchPathForDirectoriesInDomains( FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true ).first as NSString? {
                
                let path_file_name = dir.appendingPathComponent( file_name )
                
                do {
                    
                    let text = try NSString( contentsOfFile: path_file_name, encoding: String.Encoding.utf8.rawValue )
                    //print( text )
                    let data = text.components(separatedBy: "\n")
                    
                    for t in 0..<11
                    {
                        print(data[t])
                        if(data[t] == "")
                        {
                            break
                        }
                        let tempData = data[t].components(separatedBy: ",")
                        
                        for d in 1..<4
                        {
                            ans[d-1][t+11] += pow(Double(tempData[d])! - ans[d-1][t],2)
                        }
                    }
                } catch {
                    //print("エラー処理")
                }
            }
        }
        for d in 0..<3 {
            for i in 0..<11
            {
                ans[d][i+11] /= Double(sampleNum)
                ans[d][i+11] = pow(ans[d][i+11], 0.5)
            }
        }
        print("")
        print(ans[0])
        print(ans[1])
        print(ans[2])
        let file_name = "gesture" + Int(fileSelect.value).description + ".txt"
        print(file_name)
        var text = ""
        for i in 0..<2
        {
            text += "Pd," + ans[0][0 + i * 11].description + "," + ans[1][0 + i * 11].description + "," + ans[2][0 + i * 11].description + "\n"
            text += "Pg," + ans[0][1 + i * 11].description + "," + ans[1][1 + i * 11].description + "," + ans[2][1 + i * 11].description + "\n"
            text += "Pr," + ans[0][2 + i * 11].description + "," + ans[1][2 + i * 11].description + "," + ans[2][2 + i * 11].description + "\n"
            for  t in 0..<8 {
                text += "Pa[" + t.description + "]," + ans[0][t + i * 11].description + "," + ans[1][t + i * 11].description + "," + ans[2][t + i * 11].description + "\n"
            }
        }
        if let dir : NSString = NSSearchPathForDirectoriesInDomains( FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true ).first as NSString? {
            
            let path_file_name = dir.appendingPathComponent( file_name )
            
            do {
                
                try text.write( toFile: path_file_name, atomically: false, encoding: String.Encoding.utf8 )
                
                print(text)
            } catch {
                //エラー処理
            }
        }
        reset()
    }
    internal func onClickMySwicth(_ sender: UISwitch){
        
        if sender.isOn {
            myLabel.text = "計測中"
            myLabel.backgroundColor = UIColor.orange
        }
        else {
            myLabel.text = "待機中"
            myLabel.backgroundColor = UIColor.gray
        }
    }
    var flag = false
    internal func onClickMySwicth2(_ sender: UISwitch){
        
        flag = sender.isOn
    }
    
    func highByte(_ x:Int16)->UInt8{return UInt8(x>>8)}
    func lowByte(_ x:Int16)->UInt8{return UInt8(x&(255))}
    
    
    func update(_ a :[Double]) {
        for i in 0..<a.count {
            prev_acc[i] = acc[i];
            acc[i] = a[i];
        }
    //count ++;
    }
    func reset() {
        for i in 0 ..< 3
        {
            Pd[i] = 0.0;
            Pg[i] = 0.0
            Pr[i] = 0.0
            vmax[i] = 0;
            vmin[i] = 0;
            hmax[i] = 1;
            hmin[i] = 0;
            pCount = 0
            for j in 0..<8 {
                Pa[i][j] = 0.0
                ;
            }
        }
        return ;
    }
    func map2(_ input:Double, inMin:Double, inMax:Double, outMin:Double, outMax:Double) -> Double {
    // check it's within the range
        if (inMin<inMax)
        {
            if (input <= inMin)
            {
                return outMin
            }
            if (input >= inMax)
            {
                return outMax
            }
        }
        else {  // cope with input range being backwards.
            if (input >= inMin)
            {
                return outMin
            }
            if (input <= inMax)
            {
                
                return outMax;
            }
        }
        // calculate how far into the range we are
        let scale = (input-inMin)/(inMax-inMin);
        // calculate the output.
        return outMin + scale*(outMax-outMin);
    }
    var acc:[Double] = [0,0,0];
    var prev_acc:[Double] = [0,0,0];
    
    var Pd:[Double]  = [Double](repeating: 0, count: 3)
    var Pg:[Double]  = [Double](repeating: 0, count: 3)
    var Pr:[Double]  = [Double](repeating: 0, count: 3)
    var Pa:[[Double]]  = [[Double]](repeating: [0,0,0,0,0,0,0,0], count: 3)
    func accpd() {
        for i  in 0..<3
        {
            let v1 = CGVector(dx: acc[i], dy: acc[(i+1) % 3])//new C2Dvec(acc[i], acc[(i+1) % 3]);
            var v2 = CGVector(dx: prev_acc[i], dy: prev_acc[(i+1) % 3])
            //v2.vSet(accx[i+1],accy[i+1]);
            v2 = v2 - v1
            Pd[i] = abs(v2) + Pd[i];
        }
        return;
    }
    
    func accpg() {
        var m = 0.0;
        var u = 0.0;
    
        for i in 0..<3
        {
            let v1 = CGVector(dx: acc[i], dy: acc[(i+1) % 3])//new C2Dvec(acc[i], acc[(i+1) % 3]);
            let v2 = CGVector(dx: prev_acc[i], dy: prev_acc[(i+1) % 3])
            m = Double(v1.dx*v2.dy-v1.dy*v2.dx)
            if (0 >= m)
            {
                u = 1
            }else if (0 < m)
            {
                u = 0;
            }
            Pg[i] = u + Pg[i];
        }
        return;
    }
    var vmax:[Double] = [0, 0, 0]
    var vmin:[Double] = [0, 0, 0]
    var hmax:[Double] = [0, 0, 0]
    var hmin:[Double] = [0, 0, 0]
    func accpr()
    {
        for i in 0..<3
        {
            let v1 = CGVector(dx: acc[i], dy: acc[(i+1) % 3])//new C2Dvec(acc[i], acc[(i+1) % 3]);
            
            vmax[i] = max(Double(v1.dx),vmax[i])
            vmin[i] = min(Double(v1.dx),vmin[i])
            hmax[i] = max(Double(v1.dy),hmax[i])
            vmin[i] = min(Double(v1.dy),hmin[i])
            Pr[i] = (vmax[i]-vmin[i])/(hmax[i]-hmin[i]);
        }
        return;
    }
    
    
    func fussy(_ x:Double, n:Int) -> Double
    {
        if (n != 0) {
            let offset = 45.0 * Double(n) - 180.0;
            var f1 = (x - offset) + 45.0;
            var f2 = -(x - offset) + 45.0;
    
            f1 = max(f1 , 0)
            f1 = min(f1 , 45)
            
            f2 = max(f2 , 0)
            f2 = min(f2 , 45)
    
            var ans = 0.0;
    
            if (f1 < f2){
                ans = f1;
            }else if (f2 < f1){
                ans = f2;
            }
    
    //printf("%f \n",offset);
            return map2(ans, inMin: 0.0, inMax: 45.0, outMin: 0.0, outMax: 1.0);
        } else {
            var f = 0.0;
            if (x < -135)
            {
                f = -(x + 180) + 45
            }
            else if (x > 135)
            {
                f = (x - 180) + 45;
            }
            let ans = f;
    
            return map2(ans, inMin: 0.0, inMax: 45.0, outMin: 0.0, outMax: 1.0);
        }
    }
    func accpa() {
        for i in 0..<3 {
            for j in 0..<8{
                let rd = atan2(acc[i], acc[(i+1)%3]);
                let c = rd*180/3.14159265359;
                let fa = fussy(c, n: j);
                Pa[i][j] += fa;
            }
        }
    }

    
}

func abs (_ v1:CGVector) -> Double
{
    return pow(Double(v1.dx*v1.dx + v1.dy*v1.dy) , 0.5);
}
func - (v1:CGVector , v2:CGVector) -> CGVector
{
    return CGVector(dx: v1.dx-v2.dx, dy: v1.dy - v2.dy)
}

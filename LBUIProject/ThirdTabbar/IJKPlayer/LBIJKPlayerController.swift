//
//  LBIJKPlayerController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/30.
//

import UIKit
import IJKMediaFramework
import WebKit


class LBIJKPlayerController: UIViewController {
    
    var ijkPlayer: IJKFFMoviePlayerController?
    
    lazy var imageView = UIImageView()
    
    lazy var webView: WKWebView = {
        let wb = WKWebView.init(frame: .zero)
        let path = Bundle.main.path(forResource: "testExcel", ofType: "xlsx")
        let url = URL.init(fileURLWithPath: path!)
        let requet = URLRequest.init(url: url)
        wb.load(requet)
        return wb
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "IJKPlayer 播放器"
        let rtspUrl = "rtsp://121.37.68.98:554/rtp/31011500011320001339_31011500011320001339"
        let m3u8Url = "http://220.161.87.62:8800/hls/0/index.m3u8"
        startPlayVideo(url: URL.init(string: rtspUrl))
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.lessThanOrEqualTo(200)
        }
        
//        view.addSubview(webView)
//        webView.snp.makeConstraints { make in
//            make.left.right.bottom.equalToSuperview()
//            make.top.equalTo(playerView.snp_bottom)
//        }
        
        let start = UIBarButtonItem.init(title: "startRecord", style: .done, target: self, action: #selector(startRecord))
        let end = UIBarButtonItem.init(title: "endRecord", style: .done, target: self, action: #selector(endRecordButtonClicked))
        self.navigationItem.rightBarButtonItems = [start, end]
    }
    
    
    @objc private func startRecord(){
//        let image = ijkPlayer.thumbnailImageAtCurrentTime()
//        imageView.image = image
        ijkPlayer?.startRecord(withFileName: fileVideoPath)
    }
    
    @objc private func endRecordButtonClicked() {
        ijkPlayer?.stopRecord()
        ijkPlayer?.shutdown()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            [weak self] in
            self?.startPlayVideo(url: URL.init(fileURLWithPath: self?.fileVideoPath ?? ""))
        })
    }
    
    func startPlayVideo(url: URL?) {
        guard let url = url else { return }
        print("LBLOg url is \(url.absoluteString)")
        ijkPlayer = IJKFFMoviePlayerController(contentURL: url, with: nil)
        ijkPlayer?.scalingMode = .fill
        ijkPlayer?.prepareToPlay()
        ijkPlayer?.view.frame = .init(x: 0, y: 0, width: BLT_SCREEN_WIDTH, height: 320)
        view.addSubview(ijkPlayer!.view)
    }

    lazy var fileVideoPath: String = {
        return snapShotDirectory.appending("/").appending("snap.mp4")
    }()
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ijkPlayer?.shutdown()
    }
    
    private lazy var snapShotDirectory: String = {
        let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let snapshotDir = (documentDir as NSString).appendingPathComponent("ZGSnapshot")
        if !FileManager.default.fileExists(atPath: snapshotDir) {
            do {
                try FileManager.default.createDirectory(atPath: snapshotDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating snapshot directory: \(error)")
                return documentDir
            }
        }
        return snapshotDir
    }()

}


class PlayerViewController: UIViewController {
    
    var player: IJKFFMoviePlayerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "http://220.161.87.62:8800/hls/0/index.m3u8")
        player = IJKFFMoviePlayerController(contentURL: url, with: nil)
        player.view.frame = self.view.bounds
        player.scalingMode = .aspectFill
        self.view.addSubview(player.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player.prepareToPlay()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player.shutdown()
    }
}


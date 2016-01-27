import UIKit
import AVFoundation
import AVKit

class MovieContainer: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.userInteractionEnabled = false
        self.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.4)
    }

    lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer()
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

        return playerLayer
    }()

    lazy var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .White)
        view.autoresizingMask = [.FlexibleRightMargin, .FlexibleLeftMargin, .FlexibleBottomMargin, .FlexibleTopMargin]

        return view
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var shouldRegisterForNotifications = true
    var player: AVPlayer? {
        didSet {
            if self.shouldRegisterForNotifications {
                self.layer.addSublayer(self.playerLayer)
                self.addSubview(self.loadingIndicator)

                let loadingHeight = self.loadingIndicator.frame.size.height
                let loadingWidth = self.loadingIndicator.frame.size.width
                self.loadingIndicator.frame = CGRect(x: (self.frame.size.width - loadingWidth) / 2, y: (self.frame.size.height - loadingHeight) / 2, width: loadingWidth, height: loadingHeight)

                self.player?.addObserver(self, forKeyPath: "status", options: [], context: nil)
                self.shouldRegisterForNotifications = false
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let image = self.image else { return }
        self.frame = image.centeredFrame()

        var playerLayerFrame = image.centeredFrame()
        playerLayerFrame.origin.x = 0
        playerLayerFrame.origin.y = 0
        self.playerLayer.frame = playerLayerFrame
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let player = object as? AVPlayer else { return }

        if player.status == .ReadyToPlay {
            self.stopPlayerAndRemoveObserverIfNecessary()
            player.play()
        }
    }

    func stopPlayerAndRemoveObserverIfNecessary() {
        if self.shouldRegisterForNotifications == false {
            self.loadingIndicator.stopAnimating()
            self.player?.pause()
            self.player?.removeObserver(self, forKeyPath: "status")
            self.shouldRegisterForNotifications = true
        }
    }
}

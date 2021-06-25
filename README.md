# DUTrimVideoView
# example
class ViewController: UIViewController,VideoTrimViewDelegate {
    func rangeSliderValueChanged(trimView: DUTrimVideoView, rangeSlider: DURangeSlider) {
        
    }
    let vm = CachingViewModel()
    
    func add() {
        let url = URL(fileURLWithPath:  Bundle.main.path(forResource: "video", ofType: "mp4")!)
        let trimView = DUTrimVideoView(asset: AVAsset(url: url), frame: CGRect(x: 20, y: 200, width: self.view.frame.width-40, height: 100),viewModel: vm)
        trimView.delegate = self
        let rangeSlider = trimView.rangeSlider!
        rangeSlider.leftThumbImage = UIImage(named: "trim-right")
        rangeSlider.rightThumbImage = UIImage(named: "trim-left")
        rangeSlider.thumbWidth = 30
        rangeSlider.thumbHeight = 30
        
        self.view.addSubview(trimView)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let btn = UIButton(type: .infoLight, primaryAction: UIAction(handler: { (a) in
            self.view.subviews.filter({$0 is DUTrimVideoView }).first?.removeFromSuperview()
            
            self.add()
        }))
        btn.frame = CGRect(origin: .zero, size: CGSize(width: 50, height: 50))
        btn.center = self.view.center
        self.view.addSubview(btn)
    }


}

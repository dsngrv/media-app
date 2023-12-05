//
//  ViewController.swift
//  MediaApp
//
//  Created by Дмитрий Снигирев on 05.12.2023.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    private var audioPlayer: AVAudioPlayer!
    private var isPlaying = false
    private let viewModel = TracksModel()
    private lazy var currentTrack = 0
    private lazy var currentCover = 0
    private var timer = Timer()
    
    //MARK: - UI Elements
    
    private lazy var background: CAGradientLayer = {
        let background = CAGradientLayer()
        background.frame = view.bounds
        background.colors = [
            UIColor.systemPink.cgColor,
            UIColor.systemPurple.cgColor
        ]
        background.type = .radial
        background.locations = [ 0.2, 1 ]
        background.startPoint = CGPoint(x: 0.5, y: 0.5)
        background.endPoint = CGPoint(x: 1, y: 1)
        return background
    }()
    
    private lazy var coverImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.borderWidth = 4.0
        image.layer.borderColor = UIColor.white.cgColor
        return image
    }()
    
    private lazy var trackNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = " "
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        label.alpha = 0.7
        return label
    }()
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        slider.tintColor = .white
        slider.maximumTrackTintColor = .lightGray
        slider.alpha = 0.7
        slider.addTarget(self, action: #selector(changeSlider), for: .valueChanged)
        return slider
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "play.circle"), for: .normal)
        button.tintColor = .white
        button.alpha = 0.7
        button.contentMode = .scaleAspectFill
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var previousTrackButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "backward.end.circle"), for: .normal)
        button.tintColor = .white
        button.alpha = 0.7
        button.contentMode = .scaleAspectFill
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.addTarget(self, action: #selector(previousAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextTrackButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "forward.end.circle"), for: .normal)
        button.tintColor = .white
        button.alpha = 0.7
        button.contentMode = .scaleAspectFill
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var stopButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "stop.circle"), for: .normal)
        button.tintColor = .white
        button.alpha = 0.7
        button.contentMode = .scaleAspectFill
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.addTarget(self, action: #selector(stopAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.text = " "
        label.textColor = .white
        label.alpha = 0.7
        return label
    }()
    
    private lazy var timeDiffLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.text = " "
        label.textColor = .white
        label.alpha = 0.7
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        let mytext = NSMutableAttributedString(string: "Композиции, использованные в демонстрационном проекте, распространяются по свободной лицензии. Обложки для композиций сгенерированы нейросетью Kandinsky 3.0", attributes: [ NSAttributedString.Key.paragraphStyle: style ])
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = mytext
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupAudioPlayer()
        setupLayout()
    }
    
    
    //MARK: - Buttons and Slider Actions
    @objc private func playAction() {
        if audioPlayer.isPlaying {
            audioPlayer.stop()
            playPauseButton.setImage(UIImage(systemName: "play.circle"), for: .normal)     
        } else {
            audioPlayer.play()
            playPauseButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
            createTimer()
            slider.maximumValue = Float(audioPlayer.duration)
        }
    }
    
    @objc private func stopAction() {
        if audioPlayer.isPlaying {
            audioPlayer.stop()
            audioPlayer.currentTime = 0
            playPauseButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        } else {
            audioPlayer.currentTime = 0
        }
    }
    
    @objc private func previousAction() {
        audioPlayer.stop()
        playPauseButton.setImage(UIImage.init(systemName: "play.circle"), for: .normal)
        currentTrack -= 1
        currentCover -= 1
        if currentTrack == -1 && currentCover == -1 {
            currentTrack = viewModel.countTracks - 1
            currentCover = viewModel.countCovers - 1
        }
        setupAudioPlayer()
    }
    
    @objc private func nextAction() {
        audioPlayer.stop()
        playPauseButton.setImage(UIImage.init(systemName: "play.circle"), for: .normal)
        currentCover += 1
        currentTrack += 1
        if currentTrack == viewModel.countTracks && currentCover == viewModel.countCovers {
            currentTrack = 0
            currentCover = 0
        }
        setupAudioPlayer()
    }
    
    @objc private func updateTime() {
        let currentTimePlaying = audioPlayer.currentTime
        let minutes = Int(currentTimePlaying / 60)
        let seconds = Int(currentTimePlaying.truncatingRemainder(dividingBy: 60))
        timeLabel.text = NSString(format: "%02d:%02d", minutes, seconds) as String
        
        let diffTimePlaying = audioPlayer.currentTime - audioPlayer.duration
        let diffMinutes = Int(diffTimePlaying / 60)
        let diffSeconds = Int(-diffTimePlaying.truncatingRemainder(dividingBy: 60))
        timeDiffLabel.text = NSString(format: "%02d:%02d", diffMinutes, diffSeconds) as String
        
        slider.setValue(Float(self.audioPlayer.currentTime), animated: true)
    }
    
    @objc private func changeSlider() {
        audioPlayer.currentTime = TimeInterval(slider.value)
    }
    
    //MARK: - Private funcs

    private func setupAudioPlayer() {
        
        guard let track = Bundle.main.url(forResource: viewModel.trackURL[currentTrack], withExtension: "mp3") else { return }
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: track)
            trackNameLabel.text = viewModel.trackURL[currentTrack]
            coverImage.image = viewModel.coversURL[currentCover]
            audioPlayer.delegate = self
            setupAudioSession()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    private func setupAudioSession() {
        
        let audioSession = AVAudioSession()
        
        do {
            try audioSession.setCategory(.playback)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    private func createTimer() {
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        }
    
    private func setupLayout() {
        view.layer.addSublayer(background)
        [coverImage, trackNameLabel, slider, playPauseButton, previousTrackButton, nextTrackButton, stopButton, timeLabel, timeDiffLabel, descriptionLabel].forEach{view.addSubview($0)}
        
        NSLayoutConstraint.activate([
            
            coverImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            coverImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            coverImage.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            coverImage.bottomAnchor.constraint(equalTo: trackNameLabel.topAnchor, constant: -32),
            
            trackNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 16),
            trackNameLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            trackNameLabel.heightAnchor.constraint(equalToConstant: 20),
            
            slider.topAnchor.constraint(equalTo: trackNameLabel.bottomAnchor, constant: 16),
            slider.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            slider.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            timeLabel.topAnchor.constraint(equalTo: slider.bottomAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: slider.leadingAnchor),
            
            timeDiffLabel.topAnchor.constraint(equalTo: slider.bottomAnchor),
            timeDiffLabel.trailingAnchor.constraint(equalTo: slider.trailingAnchor),
            
            playPauseButton.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 16),
            playPauseButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 24),
            playPauseButton.heightAnchor.constraint(equalToConstant: 48),
            playPauseButton.widthAnchor.constraint(equalToConstant: 48),
            
            stopButton.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 16),
            stopButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -24),
            stopButton.heightAnchor.constraint(equalToConstant: 48),
            stopButton.widthAnchor.constraint(equalToConstant: 48),
            
            previousTrackButton.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 16),
            previousTrackButton.trailingAnchor.constraint(equalTo: stopButton.leadingAnchor, constant: -32),
            previousTrackButton.heightAnchor.constraint(equalToConstant: 48),
            previousTrackButton.widthAnchor.constraint(equalToConstant: 48),
            
            nextTrackButton.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 16),
            nextTrackButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 32),
            nextTrackButton.heightAnchor.constraint(equalToConstant: 48),
            nextTrackButton.widthAnchor.constraint(equalToConstant: 48),
            
            descriptionLabel.topAnchor.constraint(equalTo: playPauseButton.bottomAnchor, constant: 32),
            descriptionLabel.widthAnchor.constraint(equalToConstant: 300),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 150),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)

        ])
    }
}

extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playPauseButton.setImage(UIImage(systemName: "play.circle"),for: .normal)
    }
}

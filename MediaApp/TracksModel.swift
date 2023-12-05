//
//  TracksModel.swift
//  MediaApp
//
//  Created by Дмитрий Снигирев on 05.12.2023.
//

import Foundation
import UIKit

final class TracksModel{
    let trackURL: [String] = [
        "Chiptune",
        "Rio Samba",
        "Trap",
        "Dark Force",
        "Gamer"
    ]
    
    var countTracks: Int {trackURL.count}
    
    let coversURL: [UIImage?] = [
        UIImage(named: "ChiptuneCover"),
        UIImage(named:"RioSambaCover"),
        UIImage(named:"TrapCover"),
        UIImage(named:"DarkForceCover"),
        UIImage(named:"GamerCover")
    ]
    
    var countCovers: Int {coversURL.count}
    
}
